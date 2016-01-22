% dimentions of the terrain
width=5;
height=5;

% N is the number of voxels in the image
N = width * height;

% W is the weight matrix which will get populated on the go
W=[];

% coordinates of the wireless nodes (x coordinate, y coordinate, node id).
% list should be in the sorted order of node ids.
%coords=[5,1,1;
%	5,3,2;
%	5,5,3;
%	1,1,4;
%	1,3,5;
%	1,5,6;];

coords=[5,1,1;
	1,5,2;
	5,3,3;
	5,5,4;
	1,1,5;
	1,3,6;];

% number of nodes
num_nodes=length(coords)

% number of links (this will get updated shortly)
num_links=0;

% link coordinates matrix (this will get updated shortly)
links=[];

% addresses of the two nodes in each links
linkIDs=[];

% generating weight matrix
for i=1:length(coords)
	for j=i+1:length(coords)
		num_links=num_links+1;
		% start and end point of line
		a=[coords(i,1), coords(i,2)];
		b=[coords(j,1), coords(j,2)];

		% start and end node ids of this line
		c=[coords(i,3)];
		d=[coords(j,3)];

		% add the link to the links matrix for future use
		links=[links;a,b];

		% add the link to the linkIDs matrix for future use
		linkIDs=[linkIDs;c,d];

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

		% if desired, apply to a matrix
		X = zeros(width, height);
		X(sub2ind(size(X), s(:, 1), s(:, 2))) = 1;

		% insert in to the weight matrix
		W=[W;reshape(X', width*height, 1)'];
	end
end

num_links

links

linkIDs

% temporary variable to hold each data line from the file
txt="0";

% initialize the Y vector with RSSI values as 0
Y=zeros(1, num_links);

% initialize another vector to keep track whether above Y got updated
didYupdated=zeros(1, num_links);

% initialize historyY matrix
historyY = [];
historyY = [historyY; Y]						
historyY = [historyY; Y]						
historyY = [historyY; Y]						
historyY = [historyY; Y]						
historyY = [historyY; Y]						
historyY = [historyY; Y]						
historyY = [historyY; Y]						
historyY = [historyY; Y]						
historyY = [historyY; Y]						
historyY = [historyY; Y]						

% initialize backgroundY matrix
backgroundY = [];

% initialize the diffY vector which holds the difference of Y and backgroundY for a moment
diffY = [];

% the named pipe file from which the RSSI data comes as a structured string
fid = fopen ("/home/asanka/Downloads/myfifo");

% dynamically drawing the image based on different Y vectors until the end of file
while(txt!=-1)
	txt=fgetl(fid);

	if(txt!=-1)
		packet = strsplit(txt);
		packetLength = length(packet);

		senderID = str2double(cell2mat(packet(1,1)));
		num_data = str2double(cell2mat(packet(1,2)));

		% collect each pair of MAC address and RSSI value
		i=3;
		while(i<packetLength)
			recvID = str2double(cell2mat(packet(1,i)));
			% that rssi value is a 1x3 vector. We need the real value of it
			rssi = str2num(cell2mat(packet(1,i+1)));

			for j=1:length(linkIDs)

				if( senderID==linkIDs(j,1) )

					%if( cell2mat(recvID)==cell2mat(linkIDs(j,2)) )
					if( recvID==linkIDs(j,2) )
						%"Matching!"
						% Asanka: For each extracted MAC address pair, find it's correct
						%index position using linkMACs list and then insert the RSSI value
						% to that correct position in Y vector.
						Y(1,j)=rssi;
						
						% updating that this link value got updated
						didYupdated(1,j)=1;
					else
						%"Not matching!"
					end	
				else
					%"Not matching!"
				end
			end

			i=i+2;
		end
	end


	% checking whether all links in Y vector has got update since the last image generation cycle
	%if(all(didYupdated))

		% reset the vector which keeps track of Y vector
		didYupdated=zeros(1, num_links);

		% Asanka: Append this updated Y vector to historyY matrix as a new raw.
		% A 'running average' was performed in this historyY matrix to get the
		% backgroundY vector in each time we update this historyY matrix.
		% Additionally, remove unnecessary old data raws from historyY matrix
		% which are out of the current window.
		historyY = [historyY; Y]						
		if( length(historyY)>12 )
			historyY([1],:) = [];
		end

		backgroundY = mean(historyY)
		%backgroundY = var(historyY)

		% Asanka: calculate the difference of Y vector and backgroundY vector
		% to get an RSSI vector which we will use in the calculation of
		% image construction.
		diffY = abs(Y-backgroundY)
		%diffY = backgroundY;

		% generating a Y vector with sample RSSI change values
		%Y=zeros(1, num_links);
		%Y=rand(1, num_links);
		%Y = randi([0 0.5],1,num_links);
		%Y(170:190)=25;
		%Y(50:60)=50;
		%Y(150:160)=60;
		%Y(randi([20 60]):randi([70 90]))=1;	

		% generating image matrix based on Y vector
		%X=diffY*W;
		Img=diffY*W;
	
		% attempting to apply a high-pass filter to reduce noise or smooth out
		%for i=1:length(Img)
		%	if Img(:,i)<2
		%		Img(:,i)=0;
		%	end

			%if X(:,i)>2
			%	X(:,i)=10;
			%end
		%end

		[mat,padded] = vec2mat(Img,width);
		%mat

		%image(mat,'CDataMapping','scaled');
		image(mat);
		colorbar;
		title('Radio Tomographic Imaging');

		% uncomment the pause if image rendering has a trouble with timing
		pause(0.05);			
	% end
end

fclose (fid);


