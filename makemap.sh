#!/bin/bash
#======================================================================================================
# Name:         makemap.sh
# Description:  Create files for a 3D model environment that can be loaded into the MARS simulator.
# Dependencies: None.
#======================================================================================================


DIR_OUTPUT=output

#########################
# READ INPUT PARAMETERS #
#########################
while getopts ":n:h:d:r:t:i:" opt; do
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
if [ ! -f "$DIR_OUTPUT/$filename/heightmap.png" ] || [ ! -f "$DIR_OUTPUT/$filename/diffusion.png" ] ; then
    bash rasterize.sh $size_height_map $size_diffusion_map $pdal_resolution $pdal_output_type $xyz_filename
fi

# TODO, sed template files and output them into new files.

# README.md.template
# manifest.xml.template
# heightmap.yml.template
# Shaders: vertex_shaders.yml and fragment_shader.yml.template
# ground.bobj
