#!/usr/bin/python

import numpy as np
import scipy.ndimage
import matplotlib.pyplot as plt
import ConfigParser

tx_power = -18 		# -18dB
block_attenuation = 10 	#  10dB
obstacle_list = []
field_view_matrix = []
link_array = []
field_width = 0
field_height = 0


def addObstaclePosition(x, y):
	"add the position of a sensor node"
	obstacle_list.append([x,y])
	return

	
def init(field_link):

	global field_view_matrix
	global field_width, field_height

	sim_config = ConfigParser.ConfigParser()
	sim_config.read("simulator.cfg")
	field_width = sim_config.getint('Grid','width')
	field_height = sim_config.getint('Grid','height')

	start_x = sim_config.getint('Xrange','start')
	end_x = sim_config.getint('Xrange','end')

	start_y = sim_config.getint('Yrange','start')
	end_y = sim_config.getint('Yrange','end')

	# define the locations of obstacle blocks

	x = start_x
	while x<end_x+1:
		y = start_y
		while y<end_y+1:
			addObstaclePosition(x,y)
			y=y+1
		x=x+1

	# create the field view matrix according to the placement of obstacles
	field_view_matrix = np.random.uniform(0, 0, size=(field_width, field_height))
	i=0
	while i<len(obstacle_list):
		field_view_matrix[obstacle_list[i][0]][obstacle_list[i][1]] = 1
		i=i+1

	#print "field_view_matrix:"
	#print field_view_matrix
	#print "num_obstacles = %s" % len(obstacle_list)
	return


def readRSSI(field_link):
	global field_view_matrix
	global field_width, field_height
	R = []
	
	# update field view matrix here. (It should change dynamically when obstacles move)

	# generate R vector containing RSS of each link
	i=0
	while i<len(field_link):
		xpoint0, ypoint0 = field_link[i][0][0], field_link[i][0][1]
		xpoint1, ypoint1 = field_link[i][1][0], field_link[i][1][1]

		# Extracting the coordinates of the voxels along the line
		length = int(np.hypot(xpoint1-xpoint0, ypoint1-ypoint0)) + 1
		xarray1, yarray1 = np.linspace(xpoint0, xpoint1, length), np.linspace(ypoint0, ypoint1, length)

		# Generate the link matrix
		Z = np.random.uniform(0,0,size=(field_width, field_height))

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


