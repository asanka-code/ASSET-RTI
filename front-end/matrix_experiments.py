#!/usr/bin/python

import numpy as np
import scipy.ndimage
import matplotlib.pyplot as plt

# our other module
import network_simulator

node_list = []
links = []
W = []
Rs = []

def addNodePosition(x, y):
	"add the position of a sensor node"
	node_list.append([x,y])
	return

def generateLinks():
	i=0
	while i<len(node_list):
		j=i+1
		# take the next node after the above selected node
		while j < len(node_list):
			links.append([ [ node_list[i][0],node_list[i][1] ], [ node_list[j][0], node_list[j][1] ] ])
			j=j+1
		i=i+1
	i=0

def generateWeightMatrix(width, height):
	"generates the weight matrices for all the links"
	i=0
	while i<len(links):
		#print 'link',i,links[i][0], '-',links[i][1]
		xpoint0, ypoint0 = links[i][0][0], links[i][0][1]
		xpoint1, ypoint1 = links[i][1][0], links[i][1][1]

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
		i=i+1


def genRSSCalibrationVector():
	i=0
	while i<len(links):
		Rs.append(-18)
		i=i+1
	print 'Initial RSS vector Rs=',Rs	
	return


# this should read data from the network. Currently providing dummy data.
def getRSSVector(width, height):
	R = network_simulator.initialize(width, height, links)
	print 'Current RSS vector R=',R
	return R


def getY(width, height):
	Y = []
	R = getRSSVector(width, height)
	i=0
	while i<len(links):
		Y.append(Rs[i]-R[i])
		i=i+1
	return Y


def initialize(width, height):
	addNodePosition(0,4)
	addNodePosition(0,8)

	addNodePosition(11,4)
	addNodePosition(11,8)

	addNodePosition(4,0)
	addNodePosition(8,0)

	addNodePosition(4,11)
	addNodePosition(8,11)	

	generateLinks()
	generateWeightMatrix(width, height)
	genRSSCalibrationVector()

	Y = getY(width, height)
	print "Y=", Y
	return W

#initialize(12, 12)
