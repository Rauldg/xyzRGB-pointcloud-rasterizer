import shutil

in_fs = [
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_1.xyz",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_2.xyz",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_3.xyz",
    "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud_part_4.xyz",
]

out_f = "/media/rdominguez/SSDRD/20200921_Galopprennbahn/galopprennbahn_center/pointclouds/Galopprennbahn_center_group1_densified_point_cloud.xyz"

with open(out_f,'wb') as wfd:
    for f in in_fs:
        with open(f,'rb') as fd:
            shutil.copyfileobj(fd, wfd)