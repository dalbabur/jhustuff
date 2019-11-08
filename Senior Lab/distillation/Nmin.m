% VLE Data

x = [0 0.019 0.0721 0.0966 0.1238 0.1661 0.2337 0.2608 0.3273 0.3965 0.5198 0.5732 0.6763 0.7472 0.8943 1];
y = [0 0.17 0.3891 0.4375 0.4704 0.5089 0.5445 0.5580 0.5826 0.6122 0.6599 0.6841 0.7385 0.7815 0.8943 1];
Eq = [x;y];

% R = 1.7; Infinity!
xD = 0.89; % azeotrope by the separations book
xB = 0.01; % assumption

% Stages
delta = 0.001;
xq = xD;
yq = xD;
xl = [xq];
yl = [yq];

while xq > xB-delta && yq > xB-delta
    left = [xq,xq-1;yq,yq];
    inter = InterX(left,Eq);
    xq = inter(1);
    yq = inter(2);
   
    xl(end+1)=xq;
    yl(end+1)=yq;
    
    down = [xq,xq;yq,yq-1];
    inter = InterX(down,[x;x]);
    
    xq = inter(1);
    yq = inter(2);
    xl(end+1)=xq;
    yl(end+1)=yq;
end

figure
hold on
plot(x,y)
plot(x,x,'--')
plot(xl,yl)
xlim([0,1])
ylim([0,1])
title('Methanol-Water Distillation')
xlabel('x')
ylabel('y')
hold off

Nmin = (length(xl)-1)/2