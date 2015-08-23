#!/usr/bin/python

import matplotlib.pyplot as plt
import numpy as np
import ConfigParser

# our other module
import matrix_experiments

#width = 12
#height = 12

config = ConfigParser.ConfigParser()
config.read("rti_network.cfg")

width = config.getint('Grid','width')
height = config.getint('Grid','height')


# initialize our processing backend
#matrix_experiments.initialize(width, height)
matrix_experiments.initialize(config)

#x = np.arange(width)
#y = np.arange(height)

# generate a matrix of (width x height), each element having a random number between 0 and 100
z = np.random.uniform(0,1,size=(width,height))

plt.ion()
p = plt.imshow(z)
fig = plt.gcf()

# take the axis
ax = fig.gca()
# draw x ticks from 0 to width keeping gaps of 1
ax.set_xticks(np.arange(0,width,1))
# draw x ticks from 0 to height keeping gaps of 1
ax.set_yticks(np.arange(0,height,1))

plt.clim()   # clamp the color limits
plt.title("Radio Tomographic Imaging (RTI)")
#plt.xlabel("Nodes")
#plt.ylabel("Nodes")
plt.grid()
plt.show()

while True:

	image_matrix = matrix_experiments.getImageMatrix(width, height)
	#print 'len(image_matrix)=',len(image_matrix)
	i=0
	while i<len(image_matrix):
		p.set_data(image_matrix[i])
		plt.draw()
	    	#plt.pause(0.5)
		plt.pause(0.00001)
		i = i + 1

	'''
	# update the z matrix
	z = np.random.uniform(0,1,size=(width,height))
        p.set_data(z)
	plt.draw()
    	plt.pause(0.5)
	'''



