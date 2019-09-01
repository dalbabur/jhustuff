%% Diego Alba - Kinetics - HW#4

% A)

% The pressure in the reactor increases linearly with volume because 
% there is a spring attached to one of the walls, meaning that as the 
% reactor expands the spring will push back following Hoooke's Law. 

% B)


















    


% C)





















% D)

Vo = 0.15;
k = 150;
T = 599.67; % R
R = 0.73;
NA0 = 10*Vo^2/(3*R*T);

dXAdt = @(t,x) k*NA0^2*(1-x)*(2-x)^2/((1+2*x)*Vo^2)^0.5;
[t,XA] = ode45(dXAdt,[0 100000],NA0/Vo);

plot(t,XA)
title('Conversion of A')
xlabel('time (s)')
ylabel('X_A')
