function Xout = qbio030118(tspan,x0,S)

if nargin==0
    tspan = [0,20];
    x0 = [0 0 0];
%     S = ones(1,1000);
    S = zeros(1,1000);
    S(201:600) = 1;
elseif nargin==1
    x0 = [0 0 0];
    S = zeros(1,1000);
    S(201:600) = 1;
elseif nargin==2
    S = zeros(1,1000);
    S(201:600) = 1;
end

% NETWORK PARAMETERS

betax = 1;
betay = 1;
betaz = 1;
gammax = 1;
gammay = 1;
gammaz = 1;
Ksx = 0.1;
Kxy = 0.5;
Kyz = 0.5;
n = 5;

Constants = [betax,betay,betaz,gammax,gammay,gammaz,Ksx,Kxy,Kyz,n];


% Calculate x(t) & y(t) & z(t)

timespan = linspace(tspan(1),tspan(2),1000);
h = timespan(2)-timespan(1);

Xout = NaN(3,length(timespan));

for t=1:length(timespan)
    Inputs = [Constants,S(t)];
    xout = RungeKutta(@network,h,x0,Inputs);
    
    Xout(:,t) = xout;
    x0 = xout;
end


colors = ['r';'g';'b'];
VariableNames = {'X';'Y';'Z'};

figure;

for m=1:length(x0)
plot(timespan,Xout(m,:),'Color',colors(m),'DisplayName',VariableNames{m});
hold on
end

plot(timespan,S,'k','DisplayName','S');
hold on

Knames = {'Ksx';'Kxy';'Kyz'};

for m=1:3
    plot(timespan,Constants(m+6)*ones(length(timespan),1),'Color',colors(m),...
        'DisplayName',Knames{m});
    hold on
end
xlabel('time');
ylabel('Amount');
ylim([0 1.1]);

legend show

end

% Runge-Kutta

function yn = RungeKutta(ode,h,y0,C)


k1 = ode(y0,C);
k2 = ode(y0+0.5*h*k1,C);
k3 = ode(y0+0.5*h*k2,C);
k4 = ode(y0+h*k3,C);

yn = y0 + h*(k1 + 2*k2 + 2*k3 +k4)./6;

end

function dXdt= network(x0,C)

% NETWORK PARAMETERS

betax = C(1);
betay = C(2);
betaz = C(3);
gammax = C(4);
gammay = C(5);
gammaz = C(6);
Ksx = C(7);
Kxy = C(8);
Kyz = C(9);
n = C(10);
S = C(11);

x = x0(1);
y = x0(2);
z = x0(3);

dXdt(1) = activator(betax,Ksx,n,S) - gammax*x;
dXdt(2) = activator(betay,Kxy,n,x) - gammay*y;
dXdt(3) = activator(betaz,Kyz,n,x*y) - gammaz*z;

end

function dXdt = activator(beta,K,n,input)

dXdt = (beta*input^n)/(K^n + input^n);

end

function dXdt = repressor(beta,K,n,input)

dXdt = beta/(1 + (input/K)^n);

end