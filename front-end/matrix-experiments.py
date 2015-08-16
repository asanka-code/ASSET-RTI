import numpy as np
import scipy.ndimage
import matplotlib.pyplot as plt

width = 5
height = 5

xarray = np.arange(width)
yarray = np.arange(height)

print 'xarray=',xarray
print 'yarray=',yarray

# Two points
xpoint0, ypoint0 = 2, 0
xpoint1, ypoint1 = 0, 4
print 'coordinates point0=(', xpoint0, ypoint0, ') point1=(', xpoint1, ypoint1,')'

# Extracting the coordinates of the voxels along the line
length = int(np.hypot(xpoint1-xpoint0, ypoint1-ypoint0)) + 1
#print 'length=',length
xarray1, yarray1 = np.linspace(xpoint0, xpoint1, length), np.linspace(ypoint0, ypoint1, length)
#print 'xarray1=',xarray1
#print 'yarray1=',yarray1

# Generate the image matrix
z0 = np.random.uniform(0,0,size=(width,height))
print 'z0='
print z0

# Extract the values of the voxels along the line
zi = z0[xarray1.astype(np.int), yarray1.astype(np.int)]
#print 'zi='
#print zi

# Set a new value to each voxel along the line
z0[xarray1.astype(np.int), yarray1.astype(np.int)] = 1
print 'z0='
print z0

plt.show()


