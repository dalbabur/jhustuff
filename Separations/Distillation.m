%% Diego Alba - Separations - HW#2
%% Problem #1: Methanol - Water, Constant Molar Overflow

F = 150;
z = 0.52;
xD = 0.9;
xB = 0.05;
R = 1.25;
Br = 2;

% Material Balances
sol = [1 1; xD, xB]\[F;F*z]; % overall and component
D = sol(1);
B = sol(2);

L = D*R;
Vhat = B*Br;
Lhat = Vhat+B;
q = (Lhat-L)/F;

mTop = R/(R+1);
mBot = 1+1/Br;

% Operating Lines
Top = [xD, xD; xD-1, xD-mTop]';
Bot = [xB, xB; xB+1, xB+mBot]';

warning('off','MATLAB:nargchk:deprecated')
TB = InterX(Top,Bot); % InterX is a custom function to calculate intersections
                      % https://www.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections?focused=5165138&tab=function
Top(:,2) = TB;
Bot(:,2) = TB;
Feed = [z,z;TB']'; % can depend on sign of q

% VLE Data, Table 2-7
x = [0 2 4 6 8 10 15 20 30 40 50 60 70 80 90 95 100]/100;
y = [0 13.4 23 30.4 36.5 41.8 51.7 57.9 66.5 72.9 77.9 82.5 87 91.5 95.8 97.9 100]/100;
Eq = [x;y];

% Stages
delta = 0.01;
xq = xB;
yq = xB;
xl = [xq];
yl = [yq];

while xq < xD-delta && yq < xD-delta
    up = [xq,xq;yq,yq+1];
    inter = InterX(up,Eq);
    xq = inter(1);
    yq = inter(2);
   
    xl(end+1)=xq;
    yl(end+1)=yq;
    
    right = [xq,xq+1;yq,yq];
    if yq < TB(2) % optimum feed stage
        inter = InterX(right,Bot);
    elseif TB(2) < yq && yq < xD
        inter = InterX(right,Top);
    else
        inter = InterX(right,[x;x]);
    end
    
    xq = inter(1);
    yq = inter(2);
    xl(end+1)=xq;
    yl(end+1)=yq;
end

figure
hold on
plot(x,y)
plot(x,x,'--')
plot(Top(1,:),Top(2,:),'k')
plot(Bot(1,:),Bot(2,:),'k')
plot(Feed(1,:),Feed(2,:),'k')
plot(xl,yl)
xlim([0,1])
ylim([0,1])
title('Methanol-Water Distillation')
xlabel('x')
ylabel('y')
hold off

% Optimal feed stage = 3
% Total stages = 4+1
% q = 0.65 -> Two-Phase feed

%% Problem #2: Acetone - Ethanol, Two Feeds

F1 = 75;
z1 = 0.6;
q1 = 1;
F2 = 100;
z2 = 0.4;
q2 = 0.4;
xD = 0.9;
xB = 0.1;
Br = 2;
% reflux is sat. liq -> total condenser

% Material Balances
sol = [1 1; xD xB]\[F1+F2;F1*z1+F2*z2]; % overall and component around entire system
D = sol(1);
B = sol(2);

Vhat = B*Br;
Lhat = Vhat+B;

l = Lhat-q2*F2;
L = l - q1*F1;
V = L+D;
R = L/D;

mTop = R/(R+1);
mBot = 1+1/Br;
% mFeed1 = Inf;
mFeed2 = q2/(q2-1);

% Operating Lines
Top = [xD, xD; xD-1, xD-mTop]';
Bot = [xB, xB; xB+1, xB+mBot]';
Feed1 = [z1, z1; z1, z1+1]';
Feed2 = [z2, z2; z2-1,z2-mFeed2]';

TF1 = InterX(Top,Feed1);
BF2 = InterX(Bot,Feed2);
Mid = [TF1,BF2];
Top(:,2) = TF1;
Bot(:,2) = BF2;
Feed1(:,2) = TF1;
Feed2(:,2) = BF2;

% VLE Data, Table 2-7
x = [.1 .15 .2 .25 .30 .35 .4 .5 .6 .7 .8 .9];
y = [.262 .348 .417 .478 .524 .566 .605 .674 .739 .802 .865 .929];
Eq = [x;y];

% Stages
delta = 0.01;
xq = xB;
yq = xB;
xl = [xq];
yl = [yq];

while xq < xD-delta && yq < xD-delta
    up = [xq,xq;yq,yq+1];
    inter = InterX(up,Eq);
    xq = inter(1);
    yq = inter(2);
   
    xl(end+1)=xq;
    yl(end+1)=yq;
    
    right = [xq,xq+1;yq,yq];
    if yq < BF2(2) % optimum feed stage
        inter = InterX(right,Bot);
    elseif BF2(2) < yq && yq < TF1(2)
        inter = InterX(right,Mid);
    elseif TF1(2) < yq && yq < xD
        inter = InterX(right,Top);
    else
        inter = InterX(right,[[0 x 1];[0 x 1]]);
    end
    
    xq = inter(1);
    yq = inter(2);
    xl(end+1)=xq;
    yl(end+1)=yq;
end

figure
hold on
plot(x,y)
plot([0 x 1],[0 x 1],'--')
plot(Top(1,:),Top(2,:),'k')
plot(Bot(1,:),Bot(2,:),'k')
plot(Feed1(1,:),Feed1(2,:),'k')
plot(Feed2(1,:),Feed2(2,:),'k')
plot(Mid(1,:),Mid(2,:),'k')
plot(xl,yl)
xlim([0,1])
ylim([0,1])
title('Acetone-Ethanol Distillation')
xlabel('x')
ylabel('y')
hold off

% D and B = 84.37 kmol/h and 90.62 kmol/h, respectively
% Optimal feed stage = 7 and 10
% Total stages = 11+1

%% Problem #3: Ethanol - Water, Subcooled Liquid Feed

F = 1000;
z = 0.32;
yD = 0.75;
xB = 0.1;
EMv = 1;

% Material Balance
Lhat_minus_L = F + 1/4*F;
q = Lhat_minus_L/F;

mFeed = q/(q-1);

% VLE Data from Table 2-1
x = [0 0.019 0.0721 0.0966 0.1238 0.1661 0.2337 0.2608 0.3273 0.3965 0.5198 0.5732 0.6763 0.7472 0.8943 1];
y = [0 0.17 0.3891 0.4375 0.4704 0.5089 0.5445 0.5580 0.5826 0.6122 0.6599 0.6841 0.7385 0.7815 0.8943 1];
Eq = [x;y];

Feed = [z,z;z+1,z+mFeed]';
pinch = InterX(Feed, Eq);

Top = [yD,yD;pinch']';
Feed(:,2) = pinch;

mTop = (Top(2,2)-Top(2,1))/(Top(1,2)-Top(1,1));
Rmin = mTop/(1-mTop);

R = 2*Rmin;
mTop2 = R/(R+1);
Top2 = [yD, yD; yD-1, yD-mTop2]';
pinch2 = InterX(Feed, Top2);
Feed2 = [z,z;pinch2']';
Top2(:,2)=pinch2;

Bot = [xB, xB; pinch2']';
mBot = (Bot(2,2)-Bot(2,1))/(Bot(1,2)-Bot(1,1));
S = (5/4*F-F*mTop2/4)/(mBot-mTop2); % relating material balances and slopes of O.L.

% Stages
delta = 0.01;
xq = xB;
yq = xB;
xl = [xq];
yl = [yq];

while xq < yD-delta && yq < yD-delta
    up = [xq,xq;yq,yq+1];
    inter = InterX(up,Eq);
    xq = inter(1);
    yq = (inter(2)-yl(end))*EMv+yl(end);
   
    xl(end+1)=xq;
    yl(end+1)=yq;
    
    right = [xq,xq+1;yq,yq];
    if yq < pinch2(2) % optimum feed stage
        inter = InterX(right,Bot);
    elseif pinch2(2) < yq && yq < yD
        inter = InterX(right,Top2);
    else
        inter = InterX(right,[x;x]);
    end
    
    xq = inter(1);
    yq = inter(2);
    xl(end+1)=xq;
    yl(end+1)=yq;
end

figure
hold on
plot(x,y)
plot(x,y,'*')
plot(x,x,'--')
% plot(Top(1,:),Top(2,:),'--k')
plot(Top2(1,:),Top2(2,:),'k')
% plot(Feed(1,:),Feed(2,:),'--k')
plot(Feed2(1,:),Feed2(2,:),'k')
plot(Bot(1,:),Bot(2,:),'k')
plot(xl,yl)
xlabel('x')
ylabel('y')
xlim([0,1])
ylim([0,1])
hold off
clear 

% Minimum reflux ratio = 0.6443
% Total stages = 10 + 1
% Optimum feed stage = 8 (starting from top, not counting partial
% condenser)
% Steam flow rate = 757.77 mol/h
