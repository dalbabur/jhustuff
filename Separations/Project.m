% NUMBERS FROM PART A

z = 0.4; % molar fraction of pentane in feed
xD = 0.999; % molar fraction of pentane in distilate
xB = 0.002; % molar fraction of pentane in bottoms

F = 2500; % mol/hr
B = 1502.01;
D = 997.99;

L = 2993.97;
V = 3991.96;

hf = 4838; % enthalpy of feed, J/mol
Cp1_l = 156; % heat capacity of liquid toluene, J/molK
Cp2_l = 167.2; % heat capacity of liquid pentane, J/molK

% VLE -Solution Theory, 1: toluene, 2: pentane

% ANTOINES - FROM NIST
% Range: 308.52 K - 384.66 K
% Note: Range OK
A1 = 4.07827;
B1 = 1343.943;
C1 = -53.773;	
P1 =@(T) 10^(A1 - B1/(T+C1)); % Antoine's Eq for toluene

% Range: 268.8 K - 341.37 K
% Note: Slightly out of range, could not find better source
A2 = 3.9892;
B2 = 1070.617;
C2 = -40.454;
P2 =@(T) 10^(A2 - B2/(T+C2)); % Antoine's Eq for pentane

% DATA - FROM PROBLEM
P = 1.01325; % bar
nu2 = 116; % cc/(mol), molar  volume
nu1 = 107; % cc/(mol)
lambda2 = 25770; % J/mol, latent heat
lambda1 = 33470; % J/mol
delta2 = 7.1; % (cal/cc)^1/2, solubility
delta1 = 8.9; % (cal/cc)^1/2
Rcal = 1.9872; % cal/(mol*K), gas constant
Bp1 = 110.6 + 273.15; % K
Bp2 = 36.1 + 273.15; % K

% To generate the VLE data, loop through the molar fractions, and solve for
% temperature, taking into account the activity coefficient. 

allT = [];
allY2 = [];
for x2 = linspace(0,1,200)
    
    % SOLUTION THEORY
    x1 = 1-x2;
    Vmix = x1*nu1+x2*nu2; % volume of mixture
    phi1 = x1*nu1/Vmix; % volume fraction toluene
    phi2 = x2*nu2/Vmix; % volume fraction pentane
    % activity coefficients, given by the Eq. given (solution theory)
    gamma2 =@(T) exp(nu2*phi1^2*(delta1-delta2)^2/(Rcal*T));
    gamma1 =@(T) exp(nu1*phi2^2*(delta1-delta2)^2/(Rcal*T));
    
    daltons =@(T) P - x1*gamma1(T)*P1(T) - x2*gamma2(T)*P2(T); % Dalton's Law
    allT = [allT fsolve(daltons,273,optimset('Display','off'))];
    
    raoults =@(y2) y2*P - x2*gamma2(allT(end))*P2(allT(end)); % Raoult's Law
    allY2 = [allY2 fsolve(raoults,0,optimset('Display','off'))];
end
x2 = linspace(0,1,200);

% We can see how the enthalpy of vaporization (lambda) changes with
% temperature using the Clapyron Eq.
T = (ceil(Bp2):ceil(Bp1));
vap1 = [];
vap2 = [];
for T2 = T
    vap1 = [vap1 log(P1(Bp1)/P1(T2))*8.314/(1/T2 - 1/Bp1)];
    vap2 = [vap2 log(P2(Bp2)/P2(T2))*8.314/(1/T2 - 1/Bp2)];
end
figure
plot(T-273,vap1,T-273,vap2)
title('Enthalpy of vaporizations')
legend('Toluene','Pentane')
xlabel('T (ºC)')
ylabel('Enthalpy (J/mol)')

% We can assume enthalpy of vaporization is constant due to the negligible
% change

% Plot the Txy diagram, find the temperature of the feed if it were a
% saturated liquid

figure
hold on
plot(x2,allT-273)
plot(allY2,allT-273)
ylabel('T (ºC)')
xlabel('x_2 , y_2')
% InterX is a custom function to calculate intersections
% https://www.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections?focused=5165138&tab=function
addpath('InterX')
warning('off','MATLAB:nargchk:deprecated')
Tsat_l = InterX([z z;30 120], [x2;allT-273]); % find Tsat
plot([z z],[30 120])
plot(Tsat_l(1),Tsat_l(2),'o')
title('T-xy Diagram for Pentane and Toluene')
hold off

% FINDING q 
% q = (H-hf)/(H-h) = 
% (enthalpy of sat. vapor - enthalpy feed)/
% (enthalpy of sat. vapor - enthalpy sat. liq)
q = ((z*(lambda2+Cp2_l*Tsat_l(2))+(1-z)*(lambda1+Cp1_l*Tsat_l(2)))-hf)/...
    (z*lambda2+(1-z)*lambda1);

% FINDING O.L.s
mTop = L/V; % Slope of Top OL
mFeed = q/(q-1); % Slope of Feed OL
Top = [xD, xD; xD-1, xD-mTop]';
Feed = [z, z; z+1,z+mFeed]';

int = InterX(Top,Feed);
Top(:,2) = int;
Bot = [int [xB;xB]];

% STAGES
delta = 0.00;
xq = xB;
yq = xB;
xl = [xq];
yl = [yq];
Eq = [x2;allY2];

while xq < xD-delta && yq < xD-delta
    up = [xq,xq;yq,yq+1];
    inter = InterX(up,Eq);
    xq = inter(1);
    yq = inter(2);
   
    xl(end+1)=xq;
    yl(end+1)=yq;
    
    right = [xq,xq+1;yq,yq];
    if yq < int(2) % optimum feed stage
        inter = InterX(right,Bot);
    elseif int(2) < yq && yq < xD
        inter = InterX(right,Top);
    else
        inter = InterX(right,[x2;x2]);
    end
    
    xq = inter(1);
    yq = inter(2);
    xl(end+1)=xq;
    yl(end+1)=yq;
end

figure 
hold on
plot(x2, allY2)
plot(x2,x2)
plot(Top(1,:),Top(2,:),'k')
plot(Bot(1,:),Bot(2,:),'k')
plot(Feed(1,:),Feed(2,:),'k')
plot(xl,yl)
title('Pentane-Toluene Distillation')
xlabel('x_2')
ylabel('y_2')
ylim([0 1])

