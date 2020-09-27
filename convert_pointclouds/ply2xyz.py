import argparse
import open3d as o3d
import numpy as np

# Define the program description
program_desc = 'This script uses open3d to convert a ply into a xyz. The ply is expected to have color information in the range [0,1] the output xyz will have these colors in the range [0,255]'
# Initiate the parser
parser = argparse.ArgumentParser(description = program_desc)
parser.add_argument("--input_ply", "-i", help="The ply to be converted")
parser.add_argument("--output_xyz", "-o", help="The xyz to be created")
args = parser.parse_args()

if not (args.input_ply):
    print("Error: missing input ply")
else:
    #pcd = o3d.io.read_point_cloud("../metashape_exports/dense_export_UTM_m.ply")
    pcd = o3d.io.read_point_cloud(args.input_ply)
    np_colors = np.asarray(pcd.colors)
    np_points = np.asarray(pcd.points)
    # Colors are defined in range [0,1] but we need them in range [0,255]
    np_colors = np_colors*255
    np_cloud = np.concatenate([np_points, np_colors], axis=1)
    np.savetxt(args.output_xyz, np_cloud, fmt="%f %f %f %i %i %i")
