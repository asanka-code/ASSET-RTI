import os
import tempfile
import time
import serial

# opening serial port
ser = serial.Serial('/dev/ttyUSB0', 115200)

# opening temporary file (named pipe)
filename = '/home/asanka/Downloads/myfifo'
print filename
try:
	os.mkfifo(filename)
except OSError, e:
	print "Failed to create FIFO: %s" % e

bufsize=1 # line buffered where each line is flushed immediately to the file
fifo = open(filename, 'w', bufsize)

print "Starting..."

while True:
	data = ser.readline().split()
	if(len(data)>2):
		# creating a dummy data array
		# "senderid numdata node1 value1 node2 value2 node3 value3"
		packet = "1 2 2 " + data[1] + " 3 -55"	
		print "packet:", packet	
	
		#fifo.write(data)
		fifo.write(packet)
		fifo.write("\n")
		#print packet
	

