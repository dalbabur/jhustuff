%% Problem #3: Ethanol - Water, Saturated Liquid Feed
function g = mccabe(F,z,R,x_D,q,EMv)
F = 1000;
z = 0.1;
yD = 0.75;
xB = 0.05;
EMv = 2/3;

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

Bot = [xB, 0; pinch2']';
mBot = (Bot(2,2)-Bot(2,1))/(Bot(1,2)-Bot(1,1));
S = (5/4*F-F*mTop2/4)/(mBot-mTop2); % relating material balances and slopes of O.L.

% Stages
delta = 0.01;
xq = xD;
yq = xD;
xl = [xq];
yl = [yq];

while xq > yB-delta && yq > yB-delta % make sure this is right
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

g = figure;
hold on
plot(x,y)
plot(x,x,'--')
plot(Top(1,:),Top(2,:),'--k')
plot(Top2(1,:),Top2(2,:),'k')
plot(Feed(1,:),Feed(2,:),'--k')
plot(Feed2(1,:),Feed2(2,:),'k')
plot(Bot(1,:),Bot(2,:),'k')
plot(xl,yl)
title('Ethanol-Water Distillation')
xlabel('x')
ylabel('y')
xlim([0,1])
ylim([0,1])
hold off
clear 
end
% Minimum reflux ratio = 0.6443
% Total stages = 10 + 1
% Optimum feed stage = 8 (starting from top, not counting partial
% condenser)
% Steam flow rate = 757.77 mol/h
