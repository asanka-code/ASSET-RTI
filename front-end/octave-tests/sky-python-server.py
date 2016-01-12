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

print "Waiting..."

while True:

	print ser.readline()

	data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
	print "-----------------------------------------------------\n", data.lower()
	fifo.write(data.lower())
	fifo.write('\n')


