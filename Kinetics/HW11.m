%% Diego Alba - Kinetics - HW#11

%% Temperature and molar flow rates as a function of catalyst weight

% check BP 140ºC = 413 K, liquid
% cnt. volumetric flow rate
% no pressure drop

Fto = 2; % mol/min
Cto = 2; % mol/dm^3
v = Fto/Cto; % dm^3/min

yAo = 0.5; % meta
yBo = 0.5; % ortho

W = 100; % kg

Cp = 100; % J/mol*K

dH1 = -1800; % J/molB
dH3 = -1100; % J/molB

Kc =@(T) 10*exp(4.8*(430./T-1.5));

k1 =@(T) 0.5*exp(2*(1-315./T)); % dm^3/kg_cat*min
k2 =@(T) k1(T)./Kc(T); % dm^3/kg_cat*min
k3 =@(T) 0.005*exp(4.6*(1-460./T)); % dm^3/kg_cat*min

To = 330; % K
Ta = 500; % K
U = 16; % Ua/rhoB J/kg_cat*min*C

% Rates

% B -> A k1 dH1
% A -> B k2 -dH1 
% B -> C k3 dH3
dH2 = -dH1;

rA1 =@(T,C) k1(T)*C(2);
rA2 =@(T,C) -k2(T)*C(1);
rA =@(T,C) rA2(T,C) + rA1(T,C);

rB1 =@(T,C) -k1(T)*C(2);
rB2 =@(T,C) k2(T)*C(1);
rB3 =@(T,C) -k3(T)*C(2);
rB =@(T,C) rB2(T,C) + rB1(T,C) + rB3(T,C);

rC =@(T,C) -rB3(T,C);

% Material Balances

dCadW =@(W,T,C) rA(T,C)/v;
dCbdW =@(W,T,C) rB(T,C)/v;
dCcdW =@(W,T,C) rC(T,C)/v;

% Energy Balance

dTdW =@(W,T,C) (U*(Ta-T) + (rB1(T,C)*dH1+rB2(T,C)*dH2+rB3(T,C)*dH3))/...
                (sum(v*C*Cp));

% Solve

sys = @(W,var)[...
           dTdW(W,var(1),var(2:3));
          dCadW(W,var(1),var(2:3));
          dCbdW(W,var(1),var(2:3));
          dCcdW(W,var(1),var(2:3));
          ];
      
IC = [Cto*yAo Cto*yBo 0];
[w,var] = ode45(sys,[0 W],[To IC]);

T = var(:,1);
F = var(:,2:4)*v;

figure
subplot(2,1,1)
plot(w,F)
legend('A','B','C')
xlabel('W (kg)')
ylabel('F_j (mol/min')
title('Molar Flow Rates when feed is equimolar A and B')
subplot(2,1,2)
plot(w,T)
title('Temperature')
xlabel('W (kg)')
ylabel('T (K)')

%% Max and Min o-xylene concentration, Max m-xylene concentration

maxB = max(F(:,2))/v
minB = min(F(:,2))/v
maxA = max(F(:,1))/v

%% Repeat with pure o-xylene feed

IC = [0 Cto 0];
[w,var] = ode45(sys,[0 W],[To IC]);

T = var(:,1);
F = var(:,2:4)*v;

figure
subplot(2,1,1)
plot(w,F)
legend('A','B','C')
xlabel('W (kg)')
ylabel('F_j (mol/min')
title('Molar Flow Rates when feed is just B')
subplot(2,1,2)
plot(w,T)
title('Temperature')
xlabel('W (kg)')
ylabel('T (K)')

maxB2 = max(F(:,2))/v
minB2 = min(F(:,2))/v
maxA2 = max(F(:,1))/v

%% Compare
% 
% Maximum concentration of m-xylene is slightly higher when feed is
% equimolar, 1.3467mol/dm^3, than when there is no m-xylene in the
% feed, 1.2138 mol/dm^3. This could be do the third reaction (B->C)
% taking place faster when there is more B present.  
