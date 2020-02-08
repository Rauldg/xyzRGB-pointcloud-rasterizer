# xyzRGB Pointcloud Rasterizer
This project contains two bash scripts:
- **rasterize.sh:** Rasterizes xyzRGB pointcloud files into height and diffusion map files.
- **makemap.sh:** Create files for a 3D model environment that can be loaded into the [MARS](https://github.com/rock-simulation/mars) simulator.

## Dependencies
Third party applications are invoked throughout the **rasterize.sh:** bash script. The mentioned versions are those used while the script was developed:

- [LAStools](https://github.com/LAStools/LAStools) 1.8
- [PDAL](https://pdal.io/) 1.6.0
- [GDAL](https://gdal.org/) 2.2.3, released 2017/11/20
- [python-gdal](https://launchpad.net/ubuntu/bionic/+package/python-gdal)
- [ImageMagick](https://imagemagick.org/index.php) 6.9.7-4 Q16 x86_64 20170114

In Ubuntu the latest version of these third party applications can be installed as follow:

    sudo apt install liblas-bin
    sudo apt install pdal
    sudo apt install gdal-bin
    sudo apt install python-gdal
    sudo apt install imagemagick

## rasterize.sh

### Options

| Option | Description        | Default value |
|--------|--------------------|---------------|
| -i     | Input filename     |               |
| -h     | Height map size    | 512           |
| -d     | Diffusion map size | 4096          |
| -r     | PDAL resolution    | 0.05          |
| -t     | PDAL output type   | mean          |

Although not enforced, the diffusion map size should be a power of 2.

Regarding the PDAL options:
- **PDAL resolution:** refers to the length of raster cell edges in X/Y units. The smaller this value the higher the resolution.
- **PDAL output type:** can be set to a comma separated list of statistics for which to produce raster layers. The supported values are *min*, *max*, *mean*, *idw*, *count*, *stdev* and *all*. The option may be specified more than once.

Read more about PDAL options [here](https://pdal.io/stages/writers.gdal.html#options).

### Examples

Create height map and diffusion map image files with default parameters:
    bash rasterize.sh -i pointcloud.xyz

Create 1024x1204px height map file and 3600x3600px diffusion map file:
    bash rasterize.sh -i pointcloud.xyz -h 1024 -d 3600

### Possible Errors
- **Memory:** Invoking PDAL can throw a *malloc* error when too low of a value is set for the resolution option. To resolve this, decrease the target resolution by increasing the value of this option (e.g. use the `-r` option to set it to 0.04 instead of the default 0.05).
- **Image output sizes:** The program will throw an error if the desired height map or diffusion map sizes are greater than that of the intermittent digital terrain model (DTM) GeoTiff file generated by PDAL (i.e. the *dtm.tif* in the tmp directory). To resolve this, either increase the resolution of the resulting DTM GeoTiff file via the `-r` option or decrease the sizes of the height and diffusion maps using the `-h` and `-d` options.

## makemap.sh
TODO: Write README
