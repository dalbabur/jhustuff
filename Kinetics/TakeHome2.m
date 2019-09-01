%% Diego Alba - Kinetics Midterm II - Take Home
%
% I pledge that I have neither given or received unathorized assiatance on
% this assignment. 
% 
% Diego Alba Burbano 4/20/18

% DATA

% Monod 
mu_max = 0.8; % 1/hr
Ks = 0.25; % g_glucose/L
Ycs = 0.4; % g_cells/g_glucose for cells (Y'cs)
Yps = 0.3; % g_acid/g_glucose for product (Y'ps)
kd = 0.1; % 1/hr
m = 0.01; % 1/hr
qacid =@(mu) 0.035*mu./(0.2+mu+3.6*mu.^2);
mu =@(Cs) mu_max*Cs/(Ks+Cs);
% no susbtrate: kd = 1 1/hr, no cell/product formation
data = {Ycs Yps kd m qacid mu};

% PART I - Batch Reactor

Cso = 25; % g/L, inital concentration glucose
Cco = 0.01; % g/L, initial concentration cells
Cpo = 0;
tspan = [0 24]; % hr
IC = [Cco;Cso;Cpo];

[t, C] = ode45(@(t,C) batchMB(t,C,data), tspan, IC);

% A) Plot
figure
plot(t,C)
legend('Cc','Cs','Cp')
title('Concentrations over time')
xlabel('Time (hr)')
ylabel('Ci (g/L)')

% B) Stop
stop = t(C(:,3)==max(C(:,3))) % max. product concentration

% C) Total product
downt = 1.5; % hr, downtime
V = 8; % L
T = stop + downt; % time for one cycle
n = floor(24/T); % number of full cycles in 24hrs
g_acid = n*max(C(:,3))*V

% PART II - Chemostat

D = 0.5; %1/hr
% steady state

% Material Balances: 

% A) Effluent concentrations
Csf = fsolve(@(Cs) mu(Cs)-kd-D,0,optimset('Display','off'))
Ccf = (D*Cso-D*Csf)/(mu(Csf)/Ycs+qacid(mu(Csf))/Yps+m)
Cpf = qacid(mu(Csf))*Ccf/D

% B) Wash-out Rate
Dwo = mu(Cso)-kd % from Cc and Cs material balance

% C) Plot
d = linspace(0,Dwo);
Csf = zeros(1,length(d));
Ccf = zeros(1,length(d));
Cpf = zeros(1,length(d));

for i = 1:length(d) % 1*length linspace
    D = d(i);
    Csf(i) = fsolve(@(Cs) mu(Cs)-kd-D,0,optimset('Display','off'));
    Ccf(i) = (D*Cso-D*Csf(i))/(mu(Csf(i))/Ycs+qacid(mu(Csf(i)))/Yps+m);
    Cpf(i) = qacid(mu(Csf(i)))*Ccf(i)/D;
end

figure
hold on
plot(d,Csf)
plot(d,Ccf)
plot(d,Cpf)
plot(d,d.*Ccf)
hold off
legend('Cs','Cc','Cp','DCc')
ylim([0 10])
title('Concentrations v Dilution Rate')
xlabel('D (hr-1)')
ylabel('Ci (g/L)')

rp = d.*Cpf; % rate of production of acid
maxP = max(rp);
% D) Dilution rate to maximize production of acid
bestD = d(rp == maxP)
figure
hold on
plot(d,rp)
plot(bestD,maxP,'o')
title('Rate of production of acid')
xlabel('D (hr-1)')
ylabel('rp = D*Cp (g/(L*hr))')

% E) Production of Acid in 24hrs
% To campare with batch reactor, use same volume: 8 L
g_acid = maxP*V*24

% function for system of equations
function f = batchMB(t,conc, data)

    Ycs = data{1};
    Yps = data{2};
    kd = data{3};
    m = data{4};
    qacid = data{5};
    mu = data{6};
    
    Cc = conc(1);
    Cs = conc(2);
    Cp = conc(3);

    if Cs > 0
        rg = mu(Cs)*Cc;
        rd = kd*Cc;
        rp = qacid(mu(Cs))*Cc;
        rs = -1/Ycs*rg - 1/Yps*rp - m*Cc;
    else

        rg = 0; % set to 0
        rp = 0; % set to 0
        rd = 10*kd*Cc; % increse tenfold
        rs = 0;
    end

    dCcdt = rg - rd;
    dCsdt = rs;
    dCpdt = rp;
    
    f = [dCcdt;dCsdt;dCpdt];
end









