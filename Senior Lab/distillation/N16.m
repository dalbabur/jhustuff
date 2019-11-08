% Script used to check possibles xB and xD for a ethanol-water distillation
% with 16 stages.

% VLE Data from Separation Process Engineering by Phillip Wankat
x = [0 0.019 0.0721 0.0966 0.1238 0.1661 0.2337 0.2608 0.3273 0.3965 0.5198 0.5732 0.6763 0.7472 0.8943 1];
y = [0 0.17 0.3891 0.4375 0.4704 0.5089 0.5445 0.5580 0.5826 0.6122 0.6599 0.6841 0.7385 0.7815 0.8943 1];
Eq = [x;y]; % put data into matrix

xD = 0.8943; % azeotrope by the separations book
xB = 0.01; % assumption, can be varied

xq = xB; % set intial step off point to xB
yq = xB;
xl = [xq]; % add first point to a list
yl = [yq];

N = 0; % set the a counter for the number of stages
% Caluclate the intersections while stepping off

delta = 0.001;
while N < 16 % limit by the stages of the column
    up = [xq,xq;yq,yq+1]; % create a vertical line starting at xq
    inter = InterX(up,Eq); % find intersect of vertical line with equilibrium data
    
    % InterX is a custom function that calculates intersections
    % https://www.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections
   
    xq = inter(1); % add calcualted point to list
    yq = inter(2);
    xl(end+1)=xq;
    yl(end+1)=yq;
    
    right = [xq,xq+100;yq,yq]; % create a horizontal line starting at the intercept
    inter = InterX(right,[x;x]); % find intersect of horizonatl line with 45 degree line
    
    xq = inter(1); % add calculated point to list
    yq = inter(2);
    xl(end+1)=xq;
    yl(end+1)=yq;
    
    N = (length(xl)-1)/2; % update the counter for N
end

Nmin = (length(xl)-1)/2 % display N, should be 16
xq % display the last intercet, which correponds to xD

% Plot everything
figure
hold on
plot(x,y)
plot(x,x,'--')
plot(xl,yl)
xlim([0,1])
ylim([0,1])
title('Methanol-Water Distillation')
xlabel('x_E_t_O_H')
ylabel('y_E_t_O_H')
text(0.2,0.9,['Nmin= ',num2str(Nmin)])
text(0.2,0.8,['xB= ',num2str(xB),', xD= ',num2str(xq)])
hold off

