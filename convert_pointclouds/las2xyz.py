import laspy
import numpy as np

def las2xyz(in_f, out_f):
    # input file
    f = laspy.file.File(in_f, mode = "r")
    
    #Lets take a look at the header.
    headerformat = f.header.header_format
    print("Header format specification: ")
    for spec in headerformat:
        print(spec.name)

    # Find out what the point format looks like.
    print("Point format specification: ")
    for spec in f.point_format:
        print(spec.name)

    # The colors of the input las are in a format that is not RGB 0-255. It has negative values and 5 digits.

    # To get the rgb in the 0-255 range I have to convert the colors from 16 to 8 bits.

    # This can be done with las2las -scale_rgb_down I didn't that see laspy or liblas can do this.

    #f.visualize()

    #count = f.header.count

    #np_points = np.transpose(np.array([f.x, f.y, f.z]))
    np_points = np.stack((f.x, f.y, f.z), axis=-1)
    np_colors = (np.stack((f.red, f.green, f.blue), axis=-1)>>8).astype(np.uint8)
    #np_colors = np.transpose(np.array([f.red, f.green, f.blue]))
    #np_colors = np_colors*(256/65535)
    np_cloud = np.concatenate([np_points, np_colors], axis=1)
    #np_cloud = np.dstack((np_points, np_colors))
    np.savetxt(out_f, np_cloud, fmt="%f %f %f %i %i %i")