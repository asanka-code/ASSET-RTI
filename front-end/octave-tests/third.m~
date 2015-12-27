% start and end point of line
a = [1 10];
b = [4 1];

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
s

% if desired, apply to a matrix
N = 10;
X = zeros(N, N);
X(sub2ind(size(X), s(:, 1), s(:, 2))) = 1;

% or, plot
clf
plot(s(:, 1), s(:, 2), 'r.-')
axis(N * [0 1 0 1 0 1])
grid on

