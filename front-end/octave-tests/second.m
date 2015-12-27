% start and end point of line
a = [1 10 2];
b = [4 1 9];

% get diffs
ab = b - a;

% find number of steps required to be "one pixel wide" in the shorter
% two dimensions
n = max(abs(ab)) + 1;

% compute line
s = repmat(linspace(0, 1, n)', 1, 3);
for d = 1:3
    s(:, d) = s(:, d) * ab(d) + a(d);
end

% round to nearest pixel
s = round(s);

% if desired, apply to a matrix
N = 10;
X = zeros(N, N, N);
X(sub2ind(size(X), s(:, 1), s(:, 2), s(:, 3))) = 1;

% or, plot
clf
plot3(s(:, 1), s(:, 2), s(:, 3), 'r.-')
axis(N * [0 1 0 1 0 1])
grid on
