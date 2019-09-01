%% Diego Alba - Kinetics Midterm I - Take Home

%% Part I

% Activation Energy, Rate Constnat (A, 60ºC)

% Data
T = [50 55 65 70 75] + 273; % K 
kA = [0.009 0.017 0.09 0.22 0.43]; % 1/(hr*M^0.5)
R = 8.314; % J/(mol*K)
Kc = 0.5; % STP
Ca0 = 8.85; % M
Hrxn = 26000; % J/mol

% Converting Kc from STP to 60ºC
Kc = Kc*exp(Hrxn/R*(1/273-1/(60+273))); 

% Plot and fit data (Arrhenius Eq, ln form)
lnkA = log(kA);
Tinv = 1./T;
c = polyfit(Tinv,lnkA,1);

figure
hold on
plot(Tinv,lnkA,'o--')
plot(Tinv,Tinv*c(1)+c(2))
legend('Data','Best Fit')
xlabel('1/T')
ylabel('ln(kA)')
title('Rate Constant vs Temperature')
hold off

% Calculate Activation Energy and Rate Constant
A = exp(c(2)); % pre-exponential factor
Ea = -R*c(1) % activation energy, in J/mol
kA_60 = A*exp(-Ea/R/(60+273)) % rate constant at 60ºC, in 1/(hr*M^0.5)
% values displayed at the end of the section 




% Stoichiometry Table and Concentrations



















% Concentrations
Ca = @(x) Ca0*(1-x)/(1+x/2); % isothermal, liquid phase
Cb = @(x) Ca0*(x)/(1+x/2);
Cc = @(x) Ca0*(1+x)/(1+x/2);

% rate and conversion
minus_ra = @(x) kA_60*Ca(x)^0.5*(Ca(x)-Cb(x)*Cc(x)/Kc);
dxdt = @(t,x) minus_ra(x)/Ca0*(1+x/2);

% solve and plot conversion over time
[t,x]=ode45(dxdt,[0 100],0);

figure
plot(t,x)
xlabel('Time (hr)')
ylabel('X_A')
ylim([0 1])
xlim([0 18])
title('Conversion in Batch Reactor, 60ºC')

% find maximum conversion
X_eq = max(x) % equilibrium conversion 


%% Part II




% Boilinig points,@ 1 atm, in ºC
Tb_A = 82.2;
Tb_B = -6.9;
Tb_butanol = 117.7;
% taken from https://pubchem.ncbi.nlm.nih.gov/

% Stoichiometry Table
















% volume as a function of conversion
V = @(x) ((1-x)*95+(1+x)*18)/1000;
% concentration as a function of volume
Ca = @(x) (1-x)/V(x);
% rate and conversion
minus_ra = @(x) kA_60*Ca(x)^1.5; % irreversible reaction 
dxdt = @(t,x) minus_ra(x)*V(x);

% solve and plot conversion over time
[t2,x2]=ode45(dxdt,[0 100],0);

figure
plot(t2,x2)
xlabel('Time (hr)')
ylabel('X_A')
ylim([0 1])
title('Conversion in Batch Reactor, 60ºC')

% compare conversion from Part I and Part II
figure 
hold on
plot(t,x)
plot(t2,x2)
legend('Reversible','Irreversible')
title('Comparing Conversions')
xlabel('Time (hr)')
ylabel('X_A')