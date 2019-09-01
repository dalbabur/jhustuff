% data
D = [0.4 0.28 0.26]; % cm
s = [2.2 13 9.6]; % cm
Z0 = [0 612901 692846]; % Ba s/mL

rho = 1.0; % g/cm^3
mu = 0.04; % Ba*s
E = 2*10^8; % Ba

A = pi*D.^2/4; % cm^2
h = 0.08*D;% cm

% define Inductance, Resistance, and Capcitance

L = rho*s./A;
R = 8*pi*mu*s./A.^2;
C = (A.*s.*D)./(E*h);

% more data
Pmax = 159987; % Ba
Pmin = 106658; % Ba
alphamin = 0.2;
alphamax = 1;
HR = 70; % BPM

T = 60/HR;
STI = (-2.1*HR+550)/1000;
a = pi/T/tan(pi*0.5*STI/T);

Pa = @(t) (Pmax-Pmin)*(exp(-a.*t).*sin(pi.*t/T))./...
    (exp(-a.*0.5*STI).*sin(pi*0.5*STI/T)) + Pmin;

alpha = @(t) alphamax - (alphamax-alphamin)*sin(pi*t.*(t<STI)/STI);

t = linspace(0,T);
figure('Position',[388 445 1129 366])
plot(t,Pa(t),'k',t+T,Pa(t),'k',t+2*T,Pa(t),'k')
ylim([round(Pmin,-5),Pmax*1.08])
ylabel('Pa(t) [Ba]')
yyaxis right
plot(t,alpha(t),'k--',t+T,alpha(t),'k--',t+2*T,alpha(t),'k--')
ylim([0,alphamax*1.2])
ylabel('alpha(t)')
ax = gca;
ax.YColor = 'black';
xlim([0,T*3])
xlabel('t [s]')

Z2 =@(t) Z0(2)./(alpha(t)).^2;
Z3 =@(t) Z0(3)./(alpha(t)).^2;

dQ1dt =@(t,Q,P) (1/L(1))*(Pa(t)-P(1)-R(1)*Q(1));
dQ2dt =@(t,Q,P) (1/L(2))*(P(1)-P(2)-R(2)*Q(2));
dQ3dt =@(t,Q,P) (1/L(3))*(P(1)-P(3)-R(3)*Q(3));

dP1dt =@(t,Q,P) (Q(1)-Q(2)-Q(3))/C(1);
dP2dt =@(t,Q,P) (Q(2)-P(2)/Z2(t))/C(2);
dP3dt =@(t,Q,P) (Q(3)-P(3)/Z3(t))/C(3);

sys = {dQ1dt dQ2dt dQ3dt dP1dt dP2dt dP3dt};
Q0 = [0 0 0]';
P0 = [Pmin Pmin Pmin]';

[t,Q,P] = RK4(sys,Q0,P0,T,10*T);
r = 10000*[7 10];
figure('Position',[680 83 800 895])
for i = 1:3
    subplot(3,1,i)
    plot(t(r(1):r(2)),P(i,r(1):r(2)))
    ylabel('Pressure [Ba]')
    ylim([10^5 1.7*10^5])
    yyaxis right
    plot(t(r(1):r(2)),Q(i,r(1):r(2)))
    ylabel('Volumetric Flow Rate [mL/s]')
    ylim([0 0.5])
    title(['Vessel ',num2str(i)])
    legend('P','Q')
    xlim(t(r))
    xlabel('time [s]')
end

% Average flow rates in LAD and LCx

Q_LAD = mean(Q(2,:));
Q_LCx = mean(Q(3,:));