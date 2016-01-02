% dimentions of the terrain
width=30;
height=30;

% N is the number of voxels in the image
N = width * height;

% W is the weight matrix which will get populated on the go
W=[];

# Location and MAC address of RSSI measuring nodes
RxNodes = {30,5,'e4:d5:3d:ed:f5:bd';
	30,25,'e4:d5:3d:ed:f5:be'}

# Location and MAC address of Access point nodes
TxNodes = {1,5,'e4:d5:3d:ed:f5:bf';
	1,15,'e4:d5:3d:ed:f5:bc';
	1,25,'e4:d5:3d:ed:f5:b4';}

% number of nodes
num_RxNodes = size(RxNodes)(1,1)
num_TxNodes = size(TxNodes)(1,1)
total_nodes = num_RxNodes + num_TxNodes

% number of links (this will get updated shortly)
num_links=0;

% link coordinates matrix (this will get updated shortly)
linkCoords=[];

% MAC addresses of the two nodes in each links
linkMACs={};

% generating weight matrix
for i=1:size(RxNodes)(1,1)
	for j=1:size(TxNodes)(1,1)

		num_links=num_links+1;

		% start and end point of this line
		a=[RxNodes(i,1), RxNodes(i,2)];
		a = cell2mat(a);
		b=[TxNodes(j,1), TxNodes(j,2)];
		b = cell2mat(b);

		% start and end MAC addresses of this line
		c=[RxNodes(i,3)];
		c = cell2mat(c);
		d=[TxNodes(j,3)];
		d = cell2mat(d);

		% add the link to the link coordinates matrix for future use
		linkCoords=[linkCoords;a,b];

		% add the link to the linkMACs matrix for future use
		linkMACs=[linkMACs;c,d];

		% get diffs
		ab = b - a;

		% find number of steps required to be "one pixel wide" in the shorter
		% two dimensions
		n = max(abs(ab)) + 1;

		% compute line
		s = repmat(linspace(0, 1, n)', 1, 2);
		for d = 1:2
			s(:, d) = s(:, d) * ab(d) + a(d);
		end

		% round to nearest pixel
		s = round(s);

		% apply to a matrix
		X = zeros(width, height);
		X(sub2ind(size(X), s(:, 1), s(:, 2))) = 1;

		% insert in to the weight matrix
		W=[W;reshape(X', width*height, 1)'];
	end
end

num_links

% the named pipe file from which the RSSI data comes as a structured string
fid = fopen ("/home/asanka/Downloads/myfifo");
% temporary variable to hold each data line from the file
txt="0";

% initialize the Y vector with RSSI values as 0
Y=zeros(1, num_links);

% initialize historyY matrix
historyY = [];

% initialize backgroundY matrix
backgroundY = [];

% dynamically drawing the image based on different Y vectors until the end of file
while(txt!=-1)
	txt=fgetl(fid);
	if(txt!=-1)
		txt
		packet = strsplit(txt);
		senderMAC = packet(1,1)
		num_data = cell2mat(packet(1,2))

		%{
		% Asanka: Extract the other MAC addresses and their RSSI values
		i=0;
		while(i<num_data)
			packet(1,i+3)
			i
			i=i+1;
		end
		%}

		% Asanka: For each extracted MAC address pair, find it's correct
		%index position using linkMACs list and then insert the RSSI value
		% to that correct position in Y vector.

		% Asanka: Append this updated Y vector to historyY matrix as a new raw.
		% A 'running average' was performed in this historyY matrix to get the
		% backgroundY vector in each time we update this historyY matrix.
		% Additionally, remove unnecessary old data raws from historyY matrix
		% which are out of the current window.

		% Asanka: calculate the difference of Y vector and backgroundY vector
		% to get an RSSI vector which we will use in the calculation of
		% image construction.

	end

	% generating a Y vector with sample RSSI change values
	%Y=zeros(1, num_links);
	Y=rand(1, num_links);
	%Y = randi([0 0.5],1,num_links);
	%Y(170:190)=25;
	%Y(50:60)=50;
	%Y(150:160)=60;
	%Y(randi([20 60]):randi([70 90]))=1;	

	% generating image matrix based on Y vector
	X=Y*W;
	
	% attempting to apply a high-pass filter to reduce noise or smooth out
	%for i=1:length(X)
	%	if X(:,i)<1
	%		X(:,i)=0;
	%	end
	%end

	[mat,padded] = vec2mat(X,width);
	%mat

	image(mat,'CDataMapping','scaled');
	%image(mat)
	colorbar
	title('Radio Tomographic Imaging');

	pause(0.5)
end

fclose (fid);


