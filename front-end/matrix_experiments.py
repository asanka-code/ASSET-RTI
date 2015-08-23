#!/usr/bin/python

import numpy as np
import scipy.ndimage
import matplotlib.pyplot as plt
import ConfigParser

# our other module
import network_simulator

node_list = []
links = []
W = []
weightMatrix = []
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
		W.append(z0.flatten())
		#print W
		
		weightMatrix.append(z0)			
		i=i+1

	# generate 'W' metrix using 'weightMatrix'
	#print 'generating W'
	#print 'len(W):', len(W)
	'''
	i=0
	A = []
	while i<len(links):
		A = np.squeeze(np.asarray(weightMatrix[i]))
		i=i+1	
	print "A:", A
	'''


def genRSSCalibrationVector():
	i=0
	while i<len(links):
		Rs.append(-18)
		i=i+1
	#print 'Initial RSS vector Rs=',Rs	
	return


#def initialize(width, height):
def initialize(config):

	width = config.getint('Grid','width')
	height = config.getint('Grid','height')
	num_nodes = config.getint('Grid','num_nodes')

	# add the sensor node positions
		
	i=1
	while i<num_nodes+1:
		addNodePosition(config.getint(str(i),'x'),config.getint(str(i),'y'))
		i=i+1	

	# generate the links which connect each sensor node
	generateLinks()

	# generate the weight metrix according to the links
	generateWeightMatrix(width, height)

	# generate the Rs vector with static RSSI values for each link
	genRSSCalibrationVector()

	# ask the mesh network to start
	#network_simulator.init(width, height, links)
	network_simulator.init(links)


def getImageMatrix(width, height):
	Y = []
	X = []
	linear_equation_matrix = []

	# read the R vector (current RSSI values for each link) from the network
	R = network_simulator.readRSSI(links)

	# calculating Y vector (Y=Rs-R)
	i=0
	while i<len(links):
		Y.append(Rs[i]-R[i])
		i=i+1

	# STOPPED IN THIS REGION
	#-----------------------------------------------------------------------
	# calculate X vector using Y vector and Weight matrix
	#print 'Y:', Y
	#print 'W:', W
	i=0
	while i<len(Y):
		print 'W[',i,"]=", W[i]
		print 'Y[',i,"]=", Y[i]
		print 'len(W[',i,'])=', len(W[i])

		#linear_equation_matrix.append( [W[i], Y[i]] )
		#print 'linear_equation_matrix:'
		#print linear_equation_matrix
		i=i+1
	#-----------------------------------------------------------------------

	return weightMatrix


#initialize(12, 12)

