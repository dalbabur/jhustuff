%% Diego Alba - Kinetics - HW#8

% Ethylene epoxidation is to be carried out using a
% cesium-doped silver catalyst

% A + 1/2 B -> C
% A + 3 B -> 2 D + 2 E

% A = ethylene
% B = oxygen
% C = epoxide (desired)
% D = corbon dioxide (undesired)
% E = water (undesired)

yA0 = 6/100;
yB0 = 12/100;
Ft0 = 0.0093;
% NOTE: very small intital total flow rate, pressure drop could be ignored
Finert = (1-yA0-yB0)*Ft0;

Tref = 523;
k1A = 0.15;
k2A = 0.0888;
E1 = 60.7;
E2 = 73.2;
K1A = 6.50;
K2A = 4.33;

alpha = 4*10^(-5); % 1/(g_cat)
alpha = alpha*1000; % 1/(kg_cat)

P0 = 2;
W = 2; % kg

r1A = @(pA,pB) -(k1A*pA*pB^0.58)/(1+K1A*pA)^2;
r2A = @(pA,pB) -(k2A*pA*pB^0.3)/(1+K2A*pA)^2;
opts = odeset('NonNegative',[1 2 3 4 5 6]);

% ethylene conversion (xA) and overall selectivity
% as function of catalyst weight

% PBR

% partial pressure is just Pi = Fi/Ft * P = yi*P

sys = @(w,var) [ % var1-5 = FA-FE, var6 = P
    r1A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5))))+r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFa/dW
    1/2*r1A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5))))+3*r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFb/dW
    -r1A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFc/dW
    -2*r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFd/dW
    -2*r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFe/dW
    -alpha*P0^2*(Finert+sum(var(1:5)))/(2*var(6)*Ft0); % dP/dW
    ];

IC = [yA0*Ft0,yB0*Ft0,0,0,0,P0];
[w1,var1] = ode45(sys,[0 W],IC,opts);

% assume all flows are the same as in part A

% MEMBRANE 1

sys = @(w,var) [ % var1-5 = FA-FE, var6 = P
    r1A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5))))+r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFa/dW
    1/2*r1A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5))))+3*r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5))))+yB0*Ft0/W; % dFb/dW
    -r1A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFc/dW
    -2*r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFd/dW
    -2*r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFe/dW
    0; % ignore presuure drop
    ];

IC = [yA0*Ft0,yB0*Ft0/W,0,0,0,P0];
[w2,var2] = ode45(sys,[0 W],IC,opts);

% MEMBRANE 2

sys = @(w,var) [ % var1-5 = FA-FE, var6 = P
    r1A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5))))+r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5))))+yA0*Ft0/W; % dFa/dW
    1/2*r1A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5))))+3*r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFb/dW
    -r1A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFc/dW
    -2*r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFd/dW
    -2*r2A(var(1)*var(6)/(Finert+sum(var(1:5))),var(2)*var(6)/(Finert+sum(var(1:5)))); % dFe/dW
    0; % ignore presuure drop
    ];

% stop ode45 when concentration goes to 0 to avoid negative concentrations
IC = [yA0*Ft0/W,yB0*Ft0,0,0,0,P0];
[w3,var3] = ode45(sys,[0 W],IC,opts);

var = NaN(max([length(var1) length(var2) length(var3)]),6,3);
w = NaN(max([length(w1) length(w2) length(w3)]),1,3);
var(1:length(var1),:,1) = var1;
var(1:length(var2),:,2) = var2;
var(1:length(var3),:,3) = var3;
w(1:length(w1),:,1) = w1;
w(1:length(w2),:,2) = w2;
w(1:length(w3),:,3) = w3;
clear var1 var2 var3

for i = 1:3
    figure(1)
    subplot(1,3,i)
    plot(w(:,1,i),var(:,1:5,i))
    xlabel('W')
    ylabel('F_j')
    title('Flow rates as a function of catalyst weight')
    legend('A','B','C','D','E')
    axis square
    figure(2)
    subplot(1,3,i)
    plot(w(:,1,i),(var(1,1,i)-var(:,1,i))/var(1,1,i))
    xlabel('W')
    ylabel('X_A')
    title('Ethylene conversion')
    ylim([0 1])
    axis square
    
    figure(3)
    subplot(1,3,i)
    plot(w(:,1,i),var(:,3,i)./(var(:,4,i)+var(:,5,i)))
    xlabel('W')
    ylabel('S')
    title('Overall Selectivty of Epoxide')
    axis square
end

