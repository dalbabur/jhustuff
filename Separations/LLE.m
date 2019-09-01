%% Diego Alba - Separations - HW#4

%% Problem #1: Pyridine - Water - Chlorobenzene

F = 650;
xP = 0.3;
xW = 0.7;
% pure solvent
% not dilute

% equilibrium data
EqW = [0.0005 0.0067 0.0115 0.0162 0.0225 0.0287 0.0395 0.0640 0.132 0.132 0.3790 0.5087 0.6205 0.7392 0.8072 0.8871 0.9482 0.9992];
EqP = [0 0.1105 0.1895 0.2410 .2860 .3155 0.3505 0.4060 0.490 0.490 0.5320 0.4495 0.3610 0.2550 0.1890 .1105 0.0502 0];
Eq = [EqW ; EqP]';

% get Tie lines
T = reshape(Eq,length(Eq)/2,4);
T = [T(:,1) flipud(T(:,2)) T(:,3) flipud(T(:,4))];

%------------- Part A -------------%
% single mixer-settler
S = 300;

% mix
M = F + S;
xWM = F*xW/M;
xPM = F*xP/M;

figure
hold on
plot(EqW,EqP,'o-') % envelope
plot(T(:,1:2)',T(:,3:4)','k--') % tie lines
plot([1 0], [0 1],'k')
plot([0 xW],[0 xP],'k') % feed and solvent
plot(xWM,xPM,'o') % M

% M is practically in the 4th tie line 
% make an approximate tie line with slope of 4th
s = (T(4,4)-T(4,3))/(T(4,2)-T(4,1));
x01 = 1; % generate points on new tie line
y01 = x01*s - s*xWM + xPM;
x02 = 0;
y02 = x02*s - s*xWM + xPM;

inter = InterX([x02,x01; y02,y01],[EqW; EqP]); % find intersect of new tie with Eq
R1 = inter(:,2)'
EN = inter(:,1)'
plot(inter(1,:),inter(2,:))

% material balances
flows = [1 1;R1(1) EN(1)]\[M M*xWM]'

xlabel('X_W')
ylabel('X_P')
title('One Stage Pyridine - Water - Chlorobenzene')
hold off

% R1 flowrate = 551.96
% R1 composition = 0.813 water, 0.1833 pyridine, rest chlorobenzene
% EN flowrate = 398.03
% EN compostion = 0.0157 water, 0.2357 pyrdine, rest cholorbenzene

%------------- Part B -------------%
% two-stage cross flow 

% raffinate becomes feed
F = flows(1);
xW = R1(1);
xP = R1(2);

M = F + S;
xWM = F*xW/M;
xPM = F*xP/M;

figure
hold on
plot(EqW,EqP,'o-') % envelope
plot(T(:,1:2)',T(:,3:4)','k--') % tie lines
plot([1 0], [0 1],'k')
plot([0 xW],[0 xP],'k') % feed and solvent
plot(xWM,xPM,'o') % M

% M is practically in the 3th tie line 
% make an approximate tie line with slope of 3th
s = (T(3,4)-T(3,3))/(T(3,2)-T(3,1));
x01 = 1; % generate points on new tie line
y01 = x01*s - s*xWM + xPM;
x02 = 0;
y02 = x02*s - s*xWM + xPM;

inter = InterX([x02,x01; y02,y01],[EqW; EqP]); % find intersect of new tie with Eq
R1 = inter(:,2)'
EN = inter(:,1)'
plot(inter(1,:),inter(2,:))

% material balances
flows = [1 1;R1(1) EN(1)]\[M M*xWM]'

xlabel('X_W')
ylabel('X_P')
title('Two Stage Pyridine - Water - Chlorobenzene')
hold off

% R1 flowrate = 486.87
% R1 composition = 0.9142 water, 0.0838 pyridine, rest chlorobenzene
% EN flowrate = 365.08
% EN compostion = 0.01 water, 0.1654 pyrdine, rest cholorbenzene
