% Runge-Kutta Method
function [tall,Q,P] = RK4(ode, Q0, P0, T, tspan)
n = 10000;
dt = T/n;
c = tspan/T; % number of cycles
t = dt*(0:(n-1));

tall = zeros(1,n*c);
Q = NaN(length(Q0),n*c);
P = NaN(length(P0),n*c);

Q(:,1) = Q0;
P(:,1) = P0;

l = 1;
for i = 1:(n*c-1) % loop through time
    dQ = Q(:,i);
    dP = P(:,i);
    for k =0:3 % loop through RK
        for j = 1:length(Q0) % loop through vessels
            dP(j) = P(j,i) + (1/(4-k))*dt*ode{j+length(P0)}(t(l),dQ,dP);
            dQ(j) = Q(j,i) + (1/(4-k))*dt*ode{j}(t(l),dQ,dP);
        end
    end
    tall(i+1) = tall(i)+dt;
    Q(:,i+1) = dQ;
    P(:,i+1) = dP;
    l = l*(l~=n)+1;
end
end
