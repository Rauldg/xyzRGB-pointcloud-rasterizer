#!/bin/bash
#======================================================================================================
# Name:         mapper.sh
# Description:  Reads a DSM point cloud file and outputs height and diffusion map image files.
#
# Dependencies: LAStools, PDAL, GDAL, python-gdal, and ImageMagick.
#               The following version were used while developing this script:
#               - GDAL 2.2.3, released 2017/11/20
#               - ImageMagick 6.9.7-4 Q16 x86_64 20170114
#======================================================================================================

# Requirements:
# sudo apt install liblas-bin
# http://lastools.org/
# https://github.com/LAStools/LAStools

# sudo apt install pdal

# sudo apt install python-gdal

# Target sizes for height map and diffusion map image file outputs.
SIZE_HEIGHT_MAP=512
SIZE_DIFFUSION_MAP=4096

DIR_TMP=tmp
DIR_OUTPUT=output

# Expected dgalinfo string output pattern for size info.
REGEX_SIZE=".*Size is ([0-9]+), ([0-9]+).*"


###########
# CLEANUP #
###########

# Delete temporary files that the script creates.
# They may be left over from abruptly stopping the script during a previous run.
if [ -d $DIR_TMP ]; then rm -Rf $DIR_TMP; fi

# Recreate the tmp directory where temporary files will be saved.
mkdir $DIR_TMP

# Create output directory if it doesn't exist already.
if [ ! -d output ]; then mkdir output; fi


###################
# CREATE DTM FILE #
###################

# Use LAStools to parse the xyzRGB pointcloud ASCII format data into a laz format file.
printf "\nParsing xyzRGB pointcloud file to LAZ...\n"
txt2las -parse xyzRGB -i $1 -o $DIR_TMP/pointcloud.laz

# Use PDAL to create the GTiff DTM file.
printf "Creating GTiff DTM...\n"
pdal pipeline pipelines/dtm.json

# Use GDAL to fetch the size of the DTM.
gdalinfo_stdout="$(gdalinfo $DIR_TMP/dtm.tif 2>&1)"


##################
# FETCH DTM SIZE #
##################

# Use GDAL to fetch the width and height of the DTM.
if [[ $gdalinfo_stdout =~ $REGEX_SIZE ]]
then
    width="${BASH_REMATCH[1]}"
    height="${BASH_REMATCH[2]}"
fi


###############################
# DEFINE SIZE OF OUTPUT FILES #
###############################

# Define the size of the heightmap output.
# Either width or height needs to be set to SIZE_HEIGHT_MAP.
# Pick the one that is the longest from the DTM size that was fetched earlier.
if [ "$width" -gt "$height" ]; then
    heightmap_outsize="$SIZE_HEIGHT_MAP 0"
    diffusionmap_outsize="$SIZE_DIFFUSION_MAP 0"
else
    heightmap_outsize="0 $SIZE_HEIGHT_MAP"
    diffusionmap_outsize="0 $SIZE_DIFFUSION_MAP"
fi


#######################
# CREATING HEIGHT MAP #
#######################

# Verbosity.
printf "Creating grayscale heightmap...\n"

# Use GDAL to create grayscale heightmap file.
gdal_translate -of PNG -ot Byte -scale -b 1 $DIR_TMP/dtm.tif $DIR_OUTPUT/heightmap.png -outsize $heightmap_outsize

# Use ImageMagick to rescale canvas size to SIZE_HEIGHT_MAP x SIZE_HEIGHT_MAP pixels.
printf "Rescaling heightmap canvas to ${SIZE_HEIGHT_MAP}, ${SIZE_HEIGHT_MAP}...\n"
convert $DIR_OUTPUT/heightmap.png -resize "${SIZE_HEIGHT_MAP}x${SIZE_HEIGHT_MAP}" -background Black -gravity center -extent "${SIZE_HEIGHT_MAP}x${SIZE_HEIGHT_MAP}" $DIR_OUTPUT/heightmap.png


##########################
# CREATING DIFFUSION MAP #
##########################

# Verbosity.
printf "Creating RGB diffusionmap...\n"

# Use PDAL to create the GTiff DTM file.
pdal pipeline pipelines/rgb.json

# Use python-gdal to merge red, green, and blue tif files into a single rbg.tif file.
# This could probably have been done in the PDAL rgb pipeline filters.merge but it throws a malloc error for high resolutions.
gdal_merge.py -separate $DIR_TMP/red.tif $DIR_TMP/green.tif $DIR_TMP/blue.tif -o $DIR_TMP/rgb.tif

# Use GDAL to create the RGB diffusion map.
gdal_translate -of PNG -ot Byte -scale -b 1 -b 2 -b 3 $DIR_TMP/rgb.tif $DIR_OUTPUT/diffusion.png -outsize $diffusionmap_outsize

# Use ImageMagick to rescale canvas size to SIZE_DIFFUSION_MAP x SIZE_DIFFUSION_MAP pixels.
printf "Rescaling heightmap canvas to ${SIZE_DIFFUSION_MAP}, ${SIZE_DIFFUSION_MAP}...\n"
convert $DIR_OUTPUT/diffusion.png -resize "${SIZE_DIFFUSION_MAP}x${SIZE_DIFFUSION_MAP}" -background Black -gravity center -extent "${SIZE_DIFFUSION_MAP}x${SIZE_DIFFUSION_MAP}" $DIR_OUTPUT/diffusion.png


###########
# CLEANUP #
###########

# Delete tmp directory containing all the temporary files created by the script.
rm -Rf tmp
