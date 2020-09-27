#!/usr/bin/env python
# coding: utf-8

# In[10]:


import open3d as o3d
import numpy as np


# In[28]:


pcd = o3d.io.read_point_cloud("./Enclousure_group1_densified_point_cloud.xyz", format="xyzrgb")


# In[40]:


colors_o3d = np.asarray(pcd.colors)/255.0
pcd.colors = o3d.utility.Vector3dVector(colors_o3d)


# In[41]:


def demo_crop_geometry():
    print("Demo for manual geometry cropping")
    print(
        "1) Press 'Y' twice to align geometry with negative direction of y-axis"
    )
    print("2) Press 'K' to lock screen and to switch to selection mode")
    print("3) Drag for rectangle selection,")
    print("   or use ctrl + left click for polygon selection")
    print("4) Press 'C' to get a selected geometry and to save it")
    print("5) Press 'F' to switch to freeview mode")
    o3d.visualization.draw_geometries_with_editing([pcd])


# In[42]:


demo_crop_geometry()


# In[39]:


print(np.asarray(pcd.colors)[:10]/255)


# In[43]:


pcd_arena = o3d.io.read_point_cloud("./cropped_colors.ply")


# In[44]:


print(np.asarray(pcd_arena.colors)[:10])


# In[45]:


xyz_colors = np.asarray(pcd_arena.colors)*255


# In[50]:


xyz_colors_int = xyz_colors.astype(int)
print(xyz_colors_int)
pcd_arena.colors = o3d.utility.Vector3dVector(xyz_colors_int)


# In[52]:


## Does not write the colors
o3d.io.write_point_cloud("./RH1_area_cropped.xyz", pcd_arena,write_ascii=True)


# In[70]:


points = np.asarray(pcd_arena.points)
colors = np.asarray(pcd_arena.colors)
pcd_arena_a = np.concatenate([points, colors], axis=1)
np.savetxt("./RH1_area_cropped.xyz", pcd_arena_a, fmt="%f %f %f %i %i %i")


# In[68]:


print(pcd_arena_a)


# In[18]:


downpcd = pcd.voxel_down_sample(voxel_size=0.5)
print(downpcd)


# In[22]:


print(np.asarray(pcd.points)[:10])

pcd = o3d.io.read_point_cloud(in_ply)
np_colors = np.asarray(pcd.colors)
np_points = np.asarray(pcd.points)
# Colors are defined in range [0,1] but we need them in range [0,255]
np_colors = np_colors*255


# In[13]:


o3d.visualization.draw_geometries([pcd])


# In[14]:





# In[9]:


o3d.visualization.draw_geometries([downpcd])


# In[ ]:


import numpy as np


# In[ ]:


pcd_mat = np.loadtxt('RH1_sandy_area.xyz', delimiter=",")


# In[ ]:


pcd = o3d.geometry.PointCloud()
pcd.points = o3d.utility.Vector3dVector(pcd_mat)
o3d.io.write_point_cloud("./RH1_sandy_area.ply", pcd)


# In[ ]:


o3d.io.write_point_cloud("./RH1_sandy_area_05.ply", pcd)


# In[ ]:


o3d.visualization.draw_geometries([pcd])


# In[ ]:


vol = o3d.visualization.read_selection_polygon_volume(".bounding_box.json")
arena = vol.crop_point_cloud(downpcd)
#o3d.visualization.draw_geometries([arena])


# In[ ]:


print(arena)


# In[ ]:


o3d.__version__


# In[15]:





# In[16]:


print(downpcd)


# In[17]:


demo_crop_geometry()


# In[24]:


cropped_pcd = o3d.io.read_point_cloud("./cropped_1.ply")


# In[27]:


print(np.asarray(cropped_pcd.colors))


# In[ ]:




