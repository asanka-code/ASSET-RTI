% dimentions of the terrain
width=30;
height=30;
% N is the number of voxels in the image
N = width * height;

% W is the weight matrix which will get populated on the go
W=[];

% coordinates of the wireless nodes
coords=[1,5;
	1,10;
	1,15;
	1,20;
	1,25;
	5,1;
	10,1;
	15,1;
	20,1;
	25,1;
	30,5;
	30,10;
	30,15;
	30,20;
	30,25;
	5,30;
	10,30;
	15,30;
	20,30;
	25,30;];

% number of nodes
num_nodes=length(coords)

% number of links (this will get updated shortly)
num_links=0;

% link matrix (this will get updated shortly)
links=[];

% generating weight matrix
for i=1:length(coords)
	for j=i+1:length(coords)
		num_links=num_links+1;
		% start and end point of line
		a=[coords(i,1), coords(i,2)];
		b=[coords(j,1), coords(j,2)];

		% add the link to the links matrix for future use
		links=[links;a,b];

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

%num_links
%links

% dynamically drawing the image based on different Y vectors
for i=1:60
	% generating a Y vector with sample RSSI change values
	Y=zeros(1, num_links);
	%Y=rand(1, num_links);
	%Y = randi([0 0.5],1,num_links);
	%Y(170:190)=25;
	%Y(50:60)=50;
	%Y(150:160)=60;
	Y(randi([20 60]):randi([70 90]))=1;
	

	% generating image matrix based on Y vector
	X=Y*W;
	
	% attempting to apply a high-pass filter to reduce noise or smooth out
	%for i=1:length(X)
	%	if X(:,i)<5
	%		X(:,i)=0;
	%	end
	%end

	[mat,padded] = vec2mat(X,width);
	%mat

	image(mat,'CDataMapping','scaled');
	%image(mat)
	colorbar
	title('Radio Tomographic Imaging');

	pause(1)
end


