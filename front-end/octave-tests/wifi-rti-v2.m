% dimentions of the terrain
%width=30;
%height=30;
width=5;
height=5;

% N is the number of voxels in the image
N = width * height;

% W is the weight matrix which will get populated on the go
W=[];

# Location and MAC address of RSSI measuring nodes
RxNodes = {5,1,'b0:47:bf:ee:54:da'; % Samsung GrandPrime smartphone (mine)
	5,3,'b0:47:bf:ee:54:d4';  % Samsung GrandPrime smartphone (Dinith)
	5,5,'b0:47:bf:ee:54:c8'  % Samsung GrandPrime smartphone (Prabod)
	}

# Location and MAC address of Access point nodes
TxNodes = {1,1,'74:a7:22:6b:e4:fa'; % LG Optimus smartphone
	1,3,'a2:32:99:19:c3:62';   % Lenovo A319 smatphone
	1,5,'5e:cf:7f:02:2d:55'   % ESP8266-esp07 module
	}

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
		%n = max(abs(ab)) + 5;

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

% initialize another vector to keep track whether above Y got updated
didYupdated=zeros(1, num_links);

% initialize historyY matrix
historyY = [];

% initialize backgroundY matrix
backgroundY = [];

% initialize the diffY vector which holds the difference of Y and backgroundY for a moment
diffY = [];

% dynamically drawing the image based on different Y vectors until the end of file
while(txt!=-1)
	txt=fgetl(fid);
	if(txt!=-1)
		packet = strsplit(txt);
		packetLength = length(packet);

		senderMAC = packet(1,1);
		num_data = cell2mat(packet(1,2));

		% collect each pair of MAC address and RSSI value
		i=3;
		while(i<packetLength)
			recvMAC = packet(1,i);
			% that rssi value is a 1x3 vector. We need the real value of it
			rssi = str2num(cell2mat(packet(1,i+1)));
	
			for j=1:length(linkMACs)

				if( cell2mat(senderMAC)==cell2mat(linkMACs(j,1)) )

					if( cell2mat(recvMAC)==cell2mat(linkMACs(j,2)) )
						"Matching!"
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
	if(all(didYupdated))

		% reset the vector which keeps track of Y vector
		didYupdated=zeros(1, num_links);

		% Asanka: Append this updated Y vector to historyY matrix as a new raw.
		% A 'running average' was performed in this historyY matrix to get the
		% backgroundY vector in each time we update this historyY matrix.
		% Additionally, remove unnecessary old data raws from historyY matrix
		% which are out of the current window.
		historyY = [historyY; Y]						
		if( length(historyY)>100 )
			historyY([1],:) = [];
		end
		backgroundY = mean(historyY);

		% Asanka: calculate the difference of Y vector and backgroundY vector
		% to get an RSSI vector which we will use in the calculation of
		% image construction.
		diffY = abs(Y-backgroundY)

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
		%pause(0.05);			
	end
end

fclose (fid);


