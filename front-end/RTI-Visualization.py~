
import matplotlib.pyplot as plt
import numpy as np

width = 20
height = 20

#x = np.arange(width)
#y = np.arange(height)

# generate a matrix of (width x height), each element having a random number between 0 and 100
z = np.random.uniform(0,100,size=(width,height))

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
	# update the z matrix
	z = np.random.uniform(0,100,size=(width,height))
        p.set_data(z)
	plt.draw()
    	plt.pause(0.5)



