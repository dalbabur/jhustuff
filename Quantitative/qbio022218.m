function Xout = qbio022218(start)

if nargin==0
    xstart = 1;
    ystart = 1;
else
    xstart = start(1);
    ystart = start(2);
end
% Constants

correction = 100;

alpha = correction*2/3;
beta = 1;
gamma = 50;
sigma = 1;

% xnull
yn = alpha/beta;

% ynull
xn = gamma/sigma;

% Jacobian at fixed point

J = [alpha - beta*yn, -beta*xn;sigma*yn, sigma*xn-gamma];

% Trace of J
trJ = trace(J); 

% Determinant of J
detJ = det(J);      

% Eigenvalues of J
e = eig(J);

% PHASE PLANE %

xspan = linspace(-xn,xn,10);
yspan = linspace(-yn,yn,10);

% grid of x & y values
[x,y] = meshgrid(xspan,yspan);

% Flip y grid so that negative values are on the bottom
y = flipud(y);

% Empty matrices to fill in with velocity data
dx = NaN(size(x));
dy = NaN(size(y));

% Fill velocities into grid.
for m=1:length(x)
    for n=1:length(y)
        dx(m,n) = J(1,1)*x(m,n) + J(1,2)*y(m,n);
        dy(m,n) = J(2,1)*x(m,n) + J(2,2)*y(m,n);
    end
end

figure;

% Plot xnull
plot([0 max(xspan)+xn],[yn yn],'r');
hold on

% Plot ynull
plot([xn xn],[0 max(yspan)+yn],'b');
hold on


% Plot flow in realm of fixed point
quiver(x+xn,y+yn,dx,dy);

xlabel('x (sheep)');
ylabel('y (wolves)');


% Calculate x(t) & y(t)
timespan = linspace(0,1,1000);
h = timespan(2)-timespan(1);

Xout = NaN(2,length(timespan));

C = [alpha,beta,gamma,sigma];
y0 = [xstart;ystart];

for t=1:length(timespan)
    
    yout = RungeKutta(@sheepwolves,h,y0,C);
    
    Xout(:,t) = yout;
    y0 = yout;
end

figure;

plot(timespan,Xout(1,:),'b','DisplayName','Sheep');
hold on
plot(timespan,Xout(2,:),'r','DisplayName','Wolves');
xlabel('time');
ylabel('Population');

legend show

end

% Runge-Kutta

function yn = RungeKutta(ode,h,y0,C)


k1 = ode(y0,C);
k2 = ode(y0+0.5*h*k1,C);
k3 = ode(y0+0.5*h*k2,C);
k4 = ode(y0+h*k3,C);

yn = y0 + h*(k1 + 2*k2 + 2*k3 +k4)./6;

end

function dXdt= sheepwolves(y0,C)

% Constants

alpha = C(1);
beta = C(2);
gamma = C(3);
sigma = C(4);

x = y0(1);
y = y0(2);

dXdt = NaN(2,1);
dXdt(1) = alpha*x - beta*x*y;
dXdt(2) = sigma*x*y - gamma*y;

end