import open3d as o3d
import numpy as np

#pcd = o3d.io.read_point_cloud(
#    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_west/Galopprennbahn_west_group1_densified_point_cloud.xyz", 
#    format="xyzrgb"
#    )
pcd = o3d.io.read_point_cloud(
    #"/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_west/pointclouds/cropped_2.ply", 
    #"/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_west/pointclouds/Galopprennbahn_west_group1_densified_point_cloud_cropped.ply", 
    #"/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_west/pointclouds/Galopprennbahn_west_group1_densified_point_cloud.txt",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud.xyz",
    format="xyzrgb"
    )
print(pcd)

colors_o3d = np.asarray(pcd.colors)/256.0  # o3d expects colors in the range [0,1]
pcd.colors = o3d.utility.Vector3dVector(colors_o3d)
#o3d.visualization.draw_geometries_with_editing([pcd])
o3d.visualization.draw_geometries([pcd])
#downpcd = pcd.voxel_down_sample(voxel_size=0.5)
#o3d.visualization.draw_geometries([downpcd])