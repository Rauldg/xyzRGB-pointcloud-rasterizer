from las2xyz import las2xyz

in_fs = [
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_1.las",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_2.las",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_3.las",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_4.las",
]

out_fs = [
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_1.xyz",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_2.xyz",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_3.xyz",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_4.xyz",
]

for i in range(0, len(in_fs)):
    las2xyz(in_fs[i], out_fs[i])