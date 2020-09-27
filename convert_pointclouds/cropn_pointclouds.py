import open3d as o3d
import numpy as np


in_fs = [
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_1.xyz",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_2.xyz",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_3.xyz",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_4.xyz",
]

for pointcloud_f in in_fs:
    pcd = o3d.io.read_point_cloud(
        pointcloud_f,
        format="xyzrgb"
        )
    print(pcd)

    colors_o3d = np.asarray(pcd.colors)/256.0  # o3d expects colors in the range [0,1]
    pcd.colors = o3d.utility.Vector3dVector(colors_o3d)
    o3d.visualization.draw_geometries_with_editing([pcd])
    #o3d.visualization.draw_geometries([pcd])
    #downpcd = pcd.voxel_down_sample(voxel_size=0.5)
    #o3d.visualization.draw_geometries([downpcd])