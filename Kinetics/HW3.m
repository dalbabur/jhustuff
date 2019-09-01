%% Diego Alba - Kinetics - HW#3
%% Part A) Order of Reaction and Rate Constant

Rdata = [2.49 1.49 1.5;...
    3.44 1.49 2.03;...
    4.54 1.49 2.74;...
    5.23 1.49 3.18;...
    1.12 2.48 0.368;...
    1.67 3.7 0.368;...
    2.75 6.74 0.368;...
    4.11 10 0.368];

Rdata(:,1)=Rdata(:,1)*10^-5;
Rdata(:,2)=Rdata(:,2)*10^-3;
Rdata(:,3)=Rdata(:,3)*10^-3;

T = 395;

figure
hold on
i=1;
for alpha = (-1:3:5)/2    % plotting a range of possilbe orders
    for beta = (-1:3:5)/2  % looking for linear relationship since y=k*x
        subplot(3,3,i)
        hold on
        plot((Rdata(:,2).^alpha.*Rdata(:,3).^beta),Rdata(:,1),'o')
        title(['alpha: ',num2str(alpha),'  beta: ',num2str(beta)])
        i=i+1;
    end
end

% From the plots we infer alpha = 1 and beta = 1
% Rate constant will be the slope of the line
alpha = 1;
beta = 1;
k = (Rdata(end,1)- Rdata(1,1))/(Rdata(end,2).^alpha.*Rdata(end,3).^beta - Rdata(1,2).^alpha.*Rdata(1,3).^beta);
disp(['k = ', num2str(k), ' cm^3/mol*s'])

%% Part B) Activation Energy

Edata = [373 1.25;...
    393 4.7;...
    413 12;...
    433 30.3;...
    453 86.4;...
    473 210];

Edata(:,1) = 1./Edata(:,1);
Edata(:,2) = log(Edata(:,2)*10^-12);

figure % plotting ln of rate as a function of 1/T: ln(r) = Z - Ea/RT
plot(Edata(:,1),Edata(:,2),'o') % where Z = ln(A) + ln([HI]^alpha[O2]^beta)
xlabel('1/T')
ylabel('ln(r)')
title('Rate vs Temperature')

% Activatoin Energy would be the slope of the line time -R
R = 8.314;
Ea = -R*(Edata(end,2)-Edata(1,2))/(Edata(end,1)-Edata(1,1));
disp(['Ea = ', num2str(Ea),' J/mol'])

%% Part C) Constant Volume Batch Reactor

% with the information from Part A and the Ea, we find the constant A
A = exp(log(k)+Ea/(R*T));

x0 = 0.9;
HI_0 = 1.5*10^(-3);
O2_0 = HI_0/2;
theta_HI = HI_0/O2_0;
T = 425;
k = A*exp(-Ea/(R*T));

% O2_0 *dx/dt = -r = k*O2*HI = k*O2_0*(1-x)*O2_0*(theta_HI-2*x), k @ 425 K

sol = ode45(@(t,x) k*(1-x)*O2_0*(theta_HI-2*x),[0 200],O2_0);
figure
plot(sol.x,sol.y)
xlabel('t (s)')
ylabel('x_O_2')
title('Conversion over time')

X = @(t) deval(sol,t)-x0;
t = fsolve(X,100,optimset('Display','off'));
disp(['Necessary time: ',num2str(t),' seconds'])

%% Part D) Pressure
% Since volume and temperature are constant, and the number or moles is
% decreasing over time, the pressure will decrease. 