#!/bin/bash
#======================================================================================================
# Name:         rasterize.sh
# Description:  Reads a DSM point cloud file and outputs height and diffusion map image files.
#
# Dependencies: GDAL and ImageMagick.
#               The following version were used while developing this script:
#               - GDAL 2.2.3, released 2017/11/20
#               - ImageMagick 6.9.7-4 Q16 x86_64 20170114
#======================================================================================================



# Target sizes for height map and diffusion map image file outputs.
SIZE_HEIGHT_MAP=512
SIZE_DIFFUSION_MAP=4096

# Expected error message for unsorted DSM:
# ERROR 1: Ungridded dataset: At line <LINE_NUMBER>, change of Y direction
REGEX_ERROR_UNGRIGGED_DATASET=".*Ungridded dataset.*"

# Expected dgalinfo string output pattern for size info.
REGEX_SIZE=".*Size is ([0-9]+), ([0-9]+).*"

# Stored inputted DSM filename into a variable.
dsm_filename=$1

#####################
# ORDERING DSM DATA #
#####################

printf "\nVerifying if DSM is ordered...\n"
# Execute gdalinfo command and capture error output.
gdalinfo_stdout="$(gdalinfo $dsm_filename 2>&1)"


if [[ $gdalinfo_stdout =~ $REGEX_ERROR_UNGRIGGED_DATASET ]]; then
  # Create an ordered DSM file if the error output indicates that the DSM is not ordered.
  printf "DSM is not ordered. Ordering...\n"

  # Build name of new file with ordered data.
  extension="${dsm_filename##*.}"
  dsm_filename="${dsm_filename//\.xyz/.ordered.}$extension"

  # Order data and save in the new file.
  sort -k2 -n -k1 $1 -o $dsm_filename

  # Verify if ordering was successful by checking for gdalinfo error message on ordered DSM file.
  printf "Validating ordered DSM...\n"
  gdalinfo_stdout="$(gdalinfo $dsm_filename 2>&1)"
  if [[ $gdalinfo_stdout =~ $REGEX_SIZE ]]; then
      printf "DSM ordering was successful.\n"
  else
      printf "DSM ordering failed with the following error:\n\n"
      printf "$gdalinfo_stdout"

      printf "\n\nExiting program.\n\n"
      exit 1
  fi

elif [[ $gdalinfo_stdout =~ $REGEX_SIZE ]]; then
    # No errors indicates that the DSM is already ordered.
    printf "DSM is ordered.\n"

else
  # In case of an unexpected error: display the error message and exit the program.
  printf "An unexpected error occured:\n\n"
  printf "$gdalinfo_stdout"

  printf "\n\nExiting program.\n\n"
  exit 1
fi


# Fetch width and height of the DSM.
if [[ $gdalinfo_stdout =~ $REGEX_SIZE ]]
then
    width="${BASH_REMATCH[1]}"
    height="${BASH_REMATCH[2]}"
    #printf "DSM size is ${width}x${height}.\n"
fi

#######################
# CREATING HEIGHT MAP #
#######################

# Set size of heightmap output.
if [ "$width" -gt "$height" ]; then
    heightmap_outsize="$SIZE_HEIGHT_MAP 0"
else
    heightmap_outsize="0 $SIZE_HEIGHT_MAP"
fi

# Generate grayscale heightmap file.
printf "Creating grayscale heightmap...\n"
gdal_translate -of PNG -ot Byte -scale $dsm_filename heightmap.png -outsize $heightmap_outsize

# Use ImageMagick to rescaling canvas size to SIZE_HEIGHT_MAP x SIZE_HEIGHT_MAP pixels.
printf "Rescaling heightmap canvas to ${SIZE_HEIGHT_MAP}, ${SIZE_HEIGHT_MAP}...\n"
#printf "Rescaling height canvas to 512x512px...\n"

# Use ImageMagick to rescale the heightmap image.
convert heightmap.png -resize "${SIZE_HEIGHT_MAP}x${SIZE_HEIGHT_MAP}" -background Black -gravity center -extent "${SIZE_HEIGHT_MAP}x${SIZE_HEIGHT_MAP}" -out.png
