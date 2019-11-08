function A = qbio021518()

% Weight Matrix
A = [1 1;4,-2];

% Trace of A
trA = trace(A); 

% Determinant of A
detA = det(A);      

% Eigenvalues of A
e = eig(A);

% Eigenvectors of A
v1 = null(A-e(1)*eye(2),'r');
v2 = null(A-e(2)*eye(2),'r');

% Fixed points
x0 = null(A);

% If zeros are the only answer
if isempty(x0)
    x0 = zeros(2,1);
end

% PHASE PLANE %

% grid of x & y values
[x,y] = meshgrid(-5:5,-5:5);

% Flip y grid so that negative values are on the bottom
y = flipud(y);

% Empty matrices to fill in with velocity data
dx = NaN(11,11);
dy = NaN(11,11);

% Fill velocities into grid.
for m=1:length(x)
    for n=1:length(y)
        dx(m,n) = A(1,1)*x(m,n) + A(1,2)*y(m,n);
        dy(m,n) = A(2,1)*x(m,n) + A(2,2)*y(m,n);
    end
end

figure;

% Plot flow along first eigenvector
plot([x0(1)-v1(1),x0(1)+v1(1)],[x0(2)-v1(2),x0(2)+v1(2)],'r');
hold on

% Plot flow along second eigenvector
plot([x0(1)-v2(1),x0(1)+v2(1)],[x0(2)-v2(2),x0(2)+v2(2)],'b');
hold on

% Plot flow in realm of fixed point
quiver(x,y,dx,dy);

end
