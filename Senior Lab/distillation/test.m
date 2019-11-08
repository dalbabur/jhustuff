% Script used to calcualte the optimal Reflux ration for a given set of
% operating conditions. 

% VLE Data from Separation Process Engineering by Phillip Wankat
x = [0 0.019 0.0721 0.0966 0.1238 0.1661 0.2337 0.2608 0.3273 0.3965 0.5198 0.5732 0.6763 0.7472 0.8943 1];
y = [0 0.17 0.3891 0.4375 0.4704 0.5089 0.5445 0.5580 0.5826 0.6122 0.6599 0.6841 0.7385 0.7815 0.8943 1];
Eq = [x;y]; % put data into matrix

F = 442; % molar flor rate for 25% pump, 10wt% EtOH
z = 0.04; % molar composition of the fed

xD = 0.88; % from other script

EMv = 1; % assumed 100% efficiency

D = (F*z/xD); % upper bound, all ethanol in D
D = 0.5*D;

q = 1; % feed compostion

% Feed Operating Line
mFeed = q/(q-1); % slope of operating line
if mFeed == inf
    Feed = [z,z;z,z+1]';
else
    Feed = [z,z;z+1,z+mFeed]';
end

% Find lower bound for R
pinch = InterX(Eq,Feed); % intersection of VLE data with feed O.L.
    % InterX is a custom function that calculates intersections
    % https://www.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections
m = (pinch(2)-xD)/(pinch(1)-xD); % find the slope of the line connecting the pich point and xD
Rlow = m/(1-m); % calcualte the Reflux ratio based on the slope of the top operting line
R = Rlow*2;


% Slowly increse the reflux ratio until exactly 16 stages are need to
% connect xB and xD

N = 17; % set counter for the number of stages
while N > 16 && R < 10 % set upper bound for R so the loop ends
    % Material Balance
    B = F-D;
    xB = (F*z-D*xD)/B;

    % Top O.L
    mTop = R/(R+1);
    Top = [xD, xD; xD-1, xD-mTop]';

    meet = InterX(Top,Feed);

    % Bot O.L
    Bot = [meet(1),meet(2);xB,xB]';


    xq = xB; % set intial step off point to xB
    yq = xB;
    xl = [xq]; % add first point to a list
    yl = [yq];

    % Caluclate the intersections while stepping off

    delta = 0.01;
    while xq < xD-delta && yq < xD-delta
        up = [xq,xq;yq,yq+1]; % create a vertical line starting at xq
        inter = InterX(up,Eq); % find intersect of vertical line with equilibrium data

        xq = inter(1); % add calculated point to list
        yq = (inter(2)-yl(end))*EMv+yl(end);
        xl(end+1)=xq; 
        yl(end+1)=yq;

        right = [xq,xq+1;yq,yq]; % create a horizontal line starting at the intercept

        if xq < z && yq < meet(2) % check which operating line to intecept, depending where the feed is
            inter = InterX(right,Bot);
        elseif yq > xD
            inter = InterX(right,[x;x]);
        else
            inter = InterX(right,Top);
        end

        xq = inter(1); % add calculated point to list
        yq = inter(2);
        xl(end+1)=xq;
        yl(end+1)=yq;
end

N = (length(xl)-1)/2; % update the counter for N
R = R+0.01; % update value of R
end

% Plot everything
figure
hold on
plot(x,y)
plot(x,x,'--')
plot([Top(1),meet(1)],[Top(1),meet(2)],'k')
plot([Feed(1),meet(1)],[Feed(1),meet(2)],'k')
plot([Bot(3),meet(1)],[Bot(3),meet(2)],'k')
plot(xl,yl)
title(['R: ',num2str(R),', N: ',num2str(N)])
xlabel('x')
ylabel('y')
xlim([0,1])
ylim([0,1])
hold off

