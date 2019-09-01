function [odes] = test(w,f)
C=f(1:3);
T=f(4);

Fto = 2; % mol/min
Cto = 2; % mol/dm^3
v = Fto/Cto; % dm^3/min

yAo = 0.5; % meta
yBo = 0.5; % ortho

W = 100; % kg

Cp = 100; % J/mol*K

dH1 = -1800; % J/molB
dH3 = -1100; % J/molB

To = 330; % K
Ta = 500; % K
U = 16; % Ua/rhoB J/kg_cat*min*C

% Rates

% B -> A k1 dH1
% A -> B k2 -dH1 
% B -> C k3 dH3
dH2 = -dH1;

Kc = 10*exp(4.8*(430./T-1.5));

k1 = 0.5*exp(2*(1-315./T)); % dm^3/kg_cat*min
k2 = k1./Kc; % dm^3/kg_cat*min
k3 = 0.005*exp(4.6*(1-460./T)); % dm^3/kg_cat*min

rA1 =k1*C(2);
rA2 = -k2*C(1);
rA =rA2 + rA1;

rB1 =-rA1;
rB2 = -rA2;
rB3 = -k3*C(2);
rB = rB2 + rB1 + rB3;

rC = -rB3;

dCadW =rA/v;
dCbdW = rB/v;
dCcdW =rC/v;

dTdW =(U*(Ta-T) + (rA1*dH1+rB3*dH3))/...
                (sum(v*C*Cp));
            
odes = [dCadW dCbdW dCcdW dTdW]';
end
