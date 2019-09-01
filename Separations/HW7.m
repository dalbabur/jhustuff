%% Diego Alba - HW#7 - Separations

L = 50; % cm
Vs = 20; % cm/min
Ee = 0.4;
Ep = 0.54;
Kd = 1;
rho = 1.124; % kg/L


dqdc =@(c) 1.2./(1-0.46*c).^2;
Vi = Vs/Ee; % cm/min
Us =@(c) Vi./(1+(1-Ee)/Ee*Ep*Kd + (1-Ee)*(1-Ep)*rho/Ee*dqdc(c)); % cm/min
t =@(c) L./Us(c); % min 

c = linspace(0,1.5); % g/L

figure
plot(t(c),c)
xlabel('Time (min)')
ylabel('Concentration (g/L)')
title('Outlet concentration over time')