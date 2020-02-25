#!/bin/bash
#======================================================================================================
# Name:         makemap.sh
# Description:  Create files for a 3D model environment that can be loaded into the MARS simulator.
# Dependencies: None.
#======================================================================================================


# Delete any temporary files that might have been left over from running rasterize.sh.
DELETE_TMP_FILES=true

# Define tmp and output directories.
DIR_TMP=tmp
DIR_OUTPUT=output
DIR_TEMPLATES=templates/map

# By default, don't overwrite existing rasterize files.
overwrite=false

#########################
# READ INPUT PARAMETERS #
#########################
while getopts ":n:h:d:r:t:i:o" opt; do
  case $opt in
    n) map_name="$OPTARG"
    ;;
    h) size_height_map="$OPTARG"
    ;;
    d) size_diffusion_map="$OPTARG"
    ;;
    r) pdal_resolution="$OPTARG"
    ;;
    t) pdal_output_type="$OPTARG"
    ;;
    i) xyz_filename="$OPTARG"
    ;;
    o) overwrite=true
    ;;
    \?) printf "\nInvalid option -$OPTARG\n\n" >&2
    exit 1
    ;;
  esac
done

# Check if a model environment name has been set.
if [ -z "$map_name" ]
then
    printf "\nUse the -n option to set the name of the model environment.\n\n"
    exit 1
fi

# Get name of xyz file without its extension.
# Use this name as the directory name where created files will be outputted to.
filename=$(basename -- "$xyz_filename")
filename="${filename%.*}"

# Define target directories where created files will be saved.
target_tmp_dir="$DIR_TMP/$filename"
target_output_dir="$DIR_OUTPUT/$filename"

# Check if options are set to blank.
# Build the rasterize.sh option substrings that will be used to construct the bash script invokation string.
if [ -z "$xyz_filename" ]
then
    xyz_filename=""
else
    xyz_filename="-i $xyz_filename"
fi

if [ -z "$size_height_map" ]
then
    size_height_map=""
else
    size_height_map="-h $size_height_map"
fi

if [ -z "$size_diffusion_map" ]
then
    size_diffusion_map=""
else
    size_diffusion_map="-d $size_diffusion_map"
fi

if [ -z "$pdal_resolution" ]
then
    pdal_resolution=""
else
    pdal_resolution="-r $pdal_resolution"
fi

if [ -z "$pdal_output_type" ]
then
    pdal_output_type=""
else
    pdal_output_type="-t $pdal_output_type"
fi

# Check if height and diffisusion map files have already been created.
# If not, create them by invoking the rasterize.sh bash script.
# If they already exist but overwrite is set to true then invoke rasterize.sh anyway.
if [ $overwrite = true ] || [ ! -f "$DIR_OUTPUT/$filename/heightmap.png" ] || [ ! -f "$DIR_OUTPUT/$filename/diffusion.png" ] || [ ! -f "$DIR_OUTPUT/$filename/bbox.json" ] ; then
    # Delete output files that may still remain from a previous script execution.
    if [ "$(find "$target_output_dir" -mindepth 1 -print -quit 2>/dev/null)" ]; then
        rm $target_output_dir/*
    fi

    bash rasterize.sh $size_height_map $size_diffusion_map $pdal_resolution $pdal_output_type $xyz_filename
fi


######################################
# BOUNDING BOX AND COORDINATE VALUES #
######################################

# Fetch bounding box data stored in json file and calculate width, height, and depth.
bbox_json=$(cat "$target_output_dir/bbox.json" | jq .)


# Get dimensions.
width=$(echo $bbox_json | jq .width)
height=$(echo $bbox_json | jq .height)
depth=$(echo $bbox_json | jq .depth)

# Get longest edge (width or height).
if (( $(echo "$width > $height" | bc -l) )); then
    longest_side=$width
else
    longest_side=$height
fi

# Calculate tex scale.
tex_scale=$(bc <<< "scale=10; 1 / $longest_side")
tex_scale="0$tex_scale"

# Get center coordinates.
coord_center_x=$(echo $bbox_json | jq .centerx)
coord_center_y=$(echo $bbox_json | jq .centery)
coord_center_z=$(echo $bbox_json | jq .centerz)

# Get shifted z position for model environment origin.
position_z=$(echo $bbox_json | jq .posz)

#################################################
# CREATE MODEL ENVIRONMENT FILES FROM TEMPLATES #
#################################################

# Create README from template.
sed "s/{BOUNDING_BOX_X}/$width/g" "$DIR_TEMPLATES/README.md.template" \
    | sed "s/{BOUNDING_BOX_Y}/$height/g" \
    | sed "s/{BOUNDING_BOX_Z}/$depth/g" \
    | sed "s/{COORDINATE_CENTER_X}/$coord_center_x/g" \
    | sed "s/{COORDINATE_CENTER_Y}/$coord_center_y/g" \
    | sed "s/{COORDINATE_CENTER_Z}/$coord_center_z/g" \
    | sed "s/{WIDTH}/$longest_side/g" \
    | sed "s/{HEIGHT}/$longest_side/g" \
    | sed "s/{SCALE}/$depth/g" \
    | sed "s/{TEX_SCALE}/$tex_scale/g" \
    > "$target_output_dir/README.md"

# Create heightmap.yml from template.
sed "s/{MAP_NAME}/$map_name/g" "$DIR_TEMPLATES/heightmap.yml.template" \
    | sed "s/{POSITION_Z}/$position_z/g" \
    | sed "s/{WIDTH}/$longest_side/g" \
    | sed "s/{HEIGHT}/$longest_side/g" \
    | sed "s/{SCALE}/$depth/g" \
    | sed "s/{TEX_SCALE}/$tex_scale/g" \
    > "$target_output_dir/heightmap.yml"

# Create fragment shader from template.
sed "s/{WIDTH}/$longest_side/g" "$DIR_TEMPLATES/fragment_shader.yml.template" \
    | sed "s/{HEIGHT}/$longest_side/g" \
    > "$target_output_dir/fragment_shader.yml"

# Create manifest from template.
sed "s/{MAP_NAME}/$map_name/g" "$DIR_TEMPLATES/manifest.xml.template" \
    | sed "s/{AUTHOR}/$(whoami)/g" \
    > "$target_output_dir/manifest.xml"

# Copy over vertex shader.
cp "$DIR_TEMPLATES/vertex_shader.yml" "$target_output_dir/vertex_shader.yml"

# Copy over ground.bobj.
cp "$DIR_TEMPLATES/ground.bobj" "$target_output_dir/ground.bobj"


# Delete all the temporary files created by the script.
if [ $DELETE_TMP_FILES = true ] ; then
    # Remove boundary box json file.
    # Commented out. Could be useful as a reference.
    # rm $target_output_dir/bbox.json

    # Remove auxiliary files.
    if [ -f "$target_output_dir/heightmap.png.aux.xml" ]; then rm $target_output_dir/heightmap.png.aux.xml; fi
    if [ -f "$target_output_dir/diffusion.png.aux.xml" ]; then rm $target_output_dir/diffusion.png.aux.xml; fi
fi
