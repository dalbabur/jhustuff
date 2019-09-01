D = [0.4 0.28 0.26]; % cm
s = [2.2 13 9.6]; % cm
Z0 = [0 612901 692846]; % Ba s/mL

rho = 1.0; % g/cm^3
mu = 0.04; % Ba*s
E = 2*10^8; % Ba

A = pi*D.^2/4; % cm^2
h = 0.08*D;% cm

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

Z2 =@(t) Z0(2)./(alpha(t)).^2;
Z3 =@(t) Z0(3)./(alpha(t)).^2;

As =@(Ds) pi*Ds.^2/4;
Ls =@(ss,Ds) rho*(ss./As(Ds) + (s-ss)./A);
Rs =@(ss,Ds) 8*pi*mu*(ss./(As(Ds)).^2 +(s-ss)./A.^2);
Cs =@(ss,Ds) A.*(s-ss).*D./(E*h);
Q0 = [0 0 0]';
P0 = [Pmin Pmin Pmin]';

% Varying stenosis percentage

Dss =@(DS) D(2)-(DS/100).*D(2);
DS = linspace(50,90,15);
Q_LADs = zeros(2,length(DS));
ss = [0 2 0];

for i = 1:length(DS)
    Ds = [D(1) Dss(DS(i)) D(3)];
    L = Ls(ss,Ds);
    R = Rs(ss,Ds);
    C = Cs(ss,Ds);
    
    dQ1dt =@(t,Q,P) (1/L(1))*(Pa(t)-P(1)-R(1)*Q(1));
    dQ2dt =@(t,Q,P) (1/L(2))*(P(1)-P(2)-R(2)*Q(2));
    dQ3dt =@(t,Q,P) (1/L(3))*(P(1)-P(3)-R(3)*Q(3));

    dP1dt =@(t,Q,P) (Q(1)-Q(2)-Q(3))/C(1);
    dP2dt =@(t,Q,P) (Q(2)-P(2)/Z2(t))/C(2);
    dP3dt =@(t,Q,P) (Q(3)-P(3)/Z3(t))/C(3);

    sys = {dQ1dt dQ2dt dQ3dt dP1dt dP2dt dP3dt};
    [~,Q,~] = RK4(sys,Q0,P0,T,10*T);
    
    Q_LADs(1,i) = mean(Q(2,:));
end
figure
plot(DS,Q_LADs(1,:))
xlabel('Diameter Stenosis Percentage')
ylabel('Average Volumetric Flow Rate [mL/s]')
title('LAD with increasing stenosis')
