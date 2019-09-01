%% Diego Alba - Kinetics - HW#7

% Production of ethylene glycol from
% ethylene chlorohydrin and sodium bicarbonate
% A + B -> C + D + E

% A = ethylene chlorohydrin
% B = sodium bicarbonate
% C = ethylene glycol
% D = sodium chloride
% E = carbon dioxide

% Isothermal semibatch reactor (T = 30ºC)
% elementary reaction (k = 5.1 L / (mol*hr))

k = 5.1/60; % dm^3/(mol*min)
Vmax = 2500; % dm^3

% A flows in
Cao = 1.5; % M
vo = 0.1/Cao; % dm^3/min

% B is in reactor
Cbi = 0.75; % M
Vo = 1500; % dm^3 

% MOL BALANCES
% x1-x5 = Ca-Ce, x6 = V

% PART A %
sys =@(t,x) [-k*(x(1)*x(2)) + (vo/x(6))*(Cao-x(1)); % dCadt
             -k*(x(1)*x(2)) - (vo/x(6))*x(2); % dCbdt
             k*(x(1)*x(2)) - (vo/x(6))*x(3); % dCcdt
             k*(x(1)*x(2)) - (vo/x(6))*x(4); % dCddt
             k*(x(1)*x(2)) - (vo/x(6))*x(5); % dCedt
             vo]; % dVdt
         
tspan = [0 (Vmax-Vo)/vo]; % min, t at which V = Vmax
IC = [0 Cbi 0 0 0 Vo]';
[t,x] = ode45(sys,tspan,IC);

figure
subplot(2,2,1)
hold on
plot(t,(Cao*Vo-x(:,1).*x(:,6))/(Cao*Vo))
plot(t,(Cbi*Vo-x(:,2).*x(:,6))/(Cbi*Vo))
hold off
title('Conversion of A and B')
xlabel('time (min)')
ylabel('conversion')
legend('A','B')
subplot(2,2,2)
plot(t,k*(x(:,1).*x(:,2)))
title('Reaction Rate')
xlabel('time (min)')
subplot(2,2,3)
plot(t,x(:,1:5))
title('Concentrations over time')
xlabel('time (min)')
ylabel('concentration (M)')
legend('A','B','C','D','E')
subplot(2,2,4)
plot(t,x(:,3).*x(:,6))
title('Moles of Glycol over time')
xlabel('time (min)')
ylabel('# moles')

% PART B %
figure
flow = [0.01, 0.1, 2]/Cao; % dm^3/min
for i = 1:3
    vo = flow(i);
    sys =@(t,x) [-k*(x(1)*x(2)) + (vo/x(6))*(Cao-x(1)); % dCadt
             -k*(x(1)*x(2)) - (vo/x(6))*x(2); % dCbdt
             k*(x(1)*x(2)) - (vo/x(6))*x(3); % dCcdt
             k*(x(1)*x(2)) - (vo/x(6))*x(4); % dCddt
             k*(x(1)*x(2)) - (vo/x(6))*x(5); % dCedt
             vo]; % dVdt
         
    if (Vmax-Vo)/vo > 24*60 % no downtime, vo too slow
        tspan = [0 24*60]; % min
        IC = [0 Cbi 0 0 0 Vo]';
        [t,x] = ode45(sys,tspan,IC);
    else % downtime, vo too fast
        % do as many full cycles (fill + downtime) as possible in 24hrs
        tspan = [0 (Vmax-Vo)/vo]; % min
        IC = [0 Cbi 0 0 0 Vo]';
        [t,x] = ode45(sys,tspan,IC);
        f = length(t);
        t = [t; t(1:f)+t(end)+240];
        x = [x; x(1:f,:)];
    end
        
    t = t/60; % hrs
    subplot(3,1,i)
    plot(t,x(:,3).*x(:,6),'.')
    title(['Moles of Glycol over time, vo:',num2str(vo)])
    xlabel('time (hrs)')
    ylabel('# moles')
    xlim([0 24])
end

% PART C %
% solve ODE in two steps, with Ain while tank is filling and without Ain
% while tank is full (cnt. volume)

vo = 0.15/Cao; % dm^3/min
tmax = (Vmax-Vo)/vo;
sys =@(t,x) [-k*(x(1)*x(2)) + (vo/x(6))*(Cao-x(1)); % dCadt
         -k*(x(1)*x(2)) - (vo/x(6))*x(2); % dCbdt
         k*(x(1)*x(2)) - (vo/x(6))*x(3); % dCcdt
         k*(x(1)*x(2)) - (vo/x(6))*x(4); % dCddt
         k*(x(1)*x(2)) - (vo/x(6))*x(5); % dCedt
         vo]; % dVdt
tspan = [0 tmax]; % min, t at which V = Vmax
IC = [0 Cbi 0 0 0 Vo]';
[t,x] = ode45(sys,tspan,IC);

sys =@(t,x) [-k*(x(1)*x(2)); % dCadt
         -k*(x(1)*x(2)); % dCbdt
         k*(x(1)*x(2)); % dCcdt
         k*(x(1)*x(2)); % dCddt
         k*(x(1)*x(2)); % dCedt
         ];
tspan = [0 10000];
IC = x(end,1:5);
[t2,x2] = ode45(sys,tspan,IC);
figure
subplot(1,2,1)
hold on
plot([t;t2+t(end)],[(Cao*Vo-x(:,1).*x(:,6))/(Cao*Vo);(Cao*Vo-x2(:,1)*Vmax)/(Cao*Vo)])
plot([t;t2+t(end)],[(Cbi*Vo-x(:,2).*x(:,6))/(Cbi*Vo);(Cbi*Vo-x2(:,2)*Vmax)/(Cbi*Vo)])
hold off
title('Conversion of A and B')
xlabel('time (min)')
ylabel('conversion')
legend('A','B')
subplot(1,2,2)  
plot([t;t2+t(end)],[x(:,1:5);x2])
title('Concentrations over time')
xlabel('time (min)')
ylabel('concentration (M)')
legend('A','B','C','D','E')


