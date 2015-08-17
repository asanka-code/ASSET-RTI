#!/usr/bin/python

import numpy as np
import scipy.ndimage
import matplotlib.pyplot as plt

tx_power = -18 		# -18dB
block_attenuation = 10 	#  10dB
obstacle_list = []
field_view_matrix = []


def addObstaclePosition(x, y):
	"add the position of a sensor node"
	obstacle_list.append([x,y])
	return


def initialize(width, height, link_array):
	
	R = []

	# define the locations of obstacle blocks
	addObstaclePosition(2,3)
	addObstaclePosition(2,4)
	addObstaclePosition(3,3)
	addObstaclePosition(3,4)

	# create the field view matrix according to the placement of obstacles
	field_view_matrix = np.random.uniform(0,0,size=(width,height))
	i=0
	while i<len(obstacle_list):
		field_view_matrix[obstacle_list[i][0]][obstacle_list[i][1]] = 1
		i=i+1
	#print "field_view_matrix:"
	#print field_view_matrix

	i=0
	while i<len(link_array):
		xpoint0, ypoint0 = link_array[i][0][0], link_array[i][0][1]
		xpoint1, ypoint1 = link_array[i][1][0], link_array[i][1][1]

		# Extracting the coordinates of the voxels along the line
		length = int(np.hypot(xpoint1-xpoint0, ypoint1-ypoint0)) + 1
		xarray1, yarray1 = np.linspace(xpoint0, xpoint1, length), np.linspace(ypoint0, ypoint1, length)

		# Generate the link matrix
		Z = np.random.uniform(0,0,size=(width,height))

		# Set a new value to each voxel along the line
		Z[xarray1.astype(np.int), yarray1.astype(np.int)] = 1
		#print 'Z:'
		#print Z

		# now we should take AND operation between 'field_view_matrix' and 'Z' matrices.
		result = np.multiply(field_view_matrix, Z)
		#print "result:"
		#print result

		# now count the '1's in the resulting matrix.
		block_count = sum(sum(result))
		#print 'block_count=',block_count

		link_RSSI = tx_power - ( (block_attenuation) * (block_count) )
		#print "link_RSSI=",link_RSSI
		R.append(link_RSSI)
		i=i+1	

	#print "R = ", R
	return R

#initialize(12, 12)


