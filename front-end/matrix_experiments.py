#!/usr/bin/python

import numpy as np
import scipy.ndimage
import matplotlib.pyplot as plt

node_list = []
W = []

def addNodePosition(x, y):
	"add the position of a sensor node"
	node_list.append([x,y])
	return


def generateWeightMatrix(width, height):
	"generates the weight matrices for all the links"
	# process each node in the node_list
	i=0
	while i<len(node_list):
		j = i + 1

		# take the next node after the above selected node
		while j < len(node_list):
			#print 'link=(', node_list[i][0], node_list[i][1], ') to (', node_list[j][0], node_list[j][1],')'
			# Two points
			xpoint0, ypoint0 = node_list[i][0], node_list[i][1]
			xpoint1, ypoint1 = node_list[j][0], node_list[j][1]

			# Extracting the coordinates of the voxels along the line
			length = int(np.hypot(xpoint1-xpoint0, ypoint1-ypoint0)) + 1
			xarray1, yarray1 = np.linspace(xpoint0, xpoint1, length), np.linspace(ypoint0, ypoint1, length)

			# Generate the image matrix
			z0 = np.random.uniform(0,0,size=(width,height))

			# Don't delete the below line. I may need it oneday soon.
			# Extract the values of the voxels along the line
			#zi = z0[xarray1.astype(np.int), yarray1.astype(np.int)]

			# Set a new value to each voxel along the line
			z0[xarray1.astype(np.int), yarray1.astype(np.int)] = 1

			#print 'z0:'
			#print z0
			
			W.append(z0)

			j = j + 1
		i=i+1

def initialize(width, height):
	addNodePosition(0,0)
	addNodePosition(4,0)
	addNodePosition(0,4)
	addNodePosition(4,4)
	#print 'node_list='
	#print node_list

	generateWeightMatrix(width, height)
	'''
	print 'len(W)=',len(W)
	i=0
	while i<len(W):
		print 'W[',i,']:'
		print W[i]
		i = i + 1
	'''
	return W


