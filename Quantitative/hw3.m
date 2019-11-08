%% Diego Alba - Quant. Bio - HW#3

%% Problem 1) Predator-Prey
% NOTE: Figures are present at the end of each section. 

% parameters gathered from lecture examples
alpha = 2/3*100;
beta = 1;
gamma = 50;
sigma = 1;
K = 100; % needs to be greater or equal than gamma/sigma for a second  
         % fixed point to exist in the first quadrant. In the case K  
         % approaches infinity, the system behaves like a simple one 
         % with no carrying capacity (x^2 term can be ignored).
         
xnull = gamma/sigma; % dydt = 0
ynull = @(x) alpha/beta*(1-x/K); % dxdt = 0
ylimit = fzero(ynull,0); % lower limit for ynull since y >= 0

%----------------------------- 1A -----------------------------%

% NULL LINES %
figure
hold on
plot(0:ylimit,ynull(0:ylimit))
plot([xnull xnull],[0,ynull(0)+1])
legend('dxdt = 0','dydt = 0')
xlabel('Prey')
ylabel('Predator')
title('1A - Phase Diagram for K = 100')

% Why do you think this term is squared?
    % The term is squared because it models interactions within the 
    % prey, interactions controlled by the carrying capacity.
    
% How are they different from the nullclines for the simple model?
    % Null line for predator (dxdt = 0) is not constant, but a  
    % function of prey. It is also heavily depandant on the 
    % carrying capacity K.
    
% How are they the same?
    % Null line for the prey (dydt = 0) is the same, no change in
    % dydt. 

%----------------------------- 1B -----------------------------%

% Where does the prey nullcine pass through the x and y axes?
    % y-intercept = alpha/beta % ynull(0) 
    % x-intercept = K % ylim
    
% Why do you think K is called the prey carrying capacity?
    % The carrying capacity signifies how much the population can 
    % hold, like an upper threshold.
    
%----------------------------- 1C -----------------------------%

% What is the coordinate for the second fixed point?
    % intercept of null lines: ynull(xnull) = 33.33
    % coordinares fixed point: [50, 33.33]
    fp = [xnull, ynull(xnull)];
    fp0 = [0,0];
        
%----------------------------- 1D -----------------------------%

% JACOBIAN %
J = @(p) [alpha*(1 - 2*p(1)/K) - beta*p(2), -beta*p(1); sigma*p(2), sigma*p(1)-gamma];
J0 = J(fp0);
Jfp = J(fp);
e0 = eig(J0);
e = eig(Jfp);

% What is the stability of the (0,0) fixed point? What does this mean?
    % Since eigen values are real with different sign (-50,66.67), the
    % origin is a saddle point, meaning that the system will diverge.
    % The species won't go extinct together. 
    
% What is the stability of the second fixed point?
    % Since the eigenvalues are complex with negative real part 
    % (-16.6667 +/- 37.2678i), the fixed point is a stable focus.
    % The species will reach equilibrium at the fixed point.
    
xspan = linspace(-120,120,20);
yspan = linspace(-ynull(0),ynull(0),20);
[x,y] = meshgrid(xspan,yspan);
y = flipud(y);
dx = NaN(size(x));
dy = NaN(size(y));

% check pull of fixed points (asumme equal strength through midline)
mid = (fp-fp0)/2;
s = -1/(fp(1)/fp(2));

% genrate vector field taking into account the two fixed points
for m=1:length(x)
    for n=1:length(y)
        if y(m,n)+fp(2) < s*(x(m,n)+fp(1)) % effect of only (0,0)
            dx(m,n) = J0(1,1)*(x(m,n)+fp(1)) + J0(1,2)*(y(m,n)+fp(2));
            dy(m,n) = J0(2,1)*(x(m,n)+fp(1)) + J0(2,2)*(y(m,n)+fp(2)); 
        elseif y(m,n)+fp(2) < s*(x(m,n)+fp(1))-s*fp(1)+fp(2) && y(m,n)+fp(2) > s*(x(m,n)+fp(1)) % effect of both fixed points
            dfp = (abs((-s)*(x(m,n)+fp(1))+y(m,n)+fp(2))/sqrt((-s)^2+1))/sqrt(fp*fp'); % distance between fixed points to weight effects
            dx(m,n) = (J0(1,1)*(x(m,n)+fp(1)) + J0(1,2)*(y(m,n)+fp(2)))*(1-dfp)+dfp*(Jfp(1,1)*x(m,n) + Jfp(1,2)*y(m,n));
            dy(m,n) = (J0(2,1)*(x(m,n)+fp(1)) + J0(2,2)*(y(m,n)+fp(2)))*(1-dfp)+dfp*(Jfp(2,1)*x(m,n) + Jfp(2,2)*y(m,n));
        else % effect of 2nd fixed point
            dx(m,n) = Jfp(1,1)*x(m,n) + Jfp(1,2)*y(m,n);
            dy(m,n) = Jfp(2,1)*x(m,n) + Jfp(2,2)*y(m,n);
        end
    end
end

quiver(x+fp(1),y+fp(2),dx,dy);
xlim([-20,120])
ylim([-20, 90])
hold off

%----------------------------- 1E -----------------------------%

% What does K have to be greater than in order for the system to oscillate?
    % In order for the system to oscillate at all, the eigenvalue 
    % must to be complex, which happens when K is greater than 
    % gamma/sigma.
    
%% Problem 2) Vilar Model

%----------------------------- 2A -----------------------------%

% What assumptions did they make in order to make this simplification? 
    % Quasi-steady-state, all derivatives but R and C equal 0. 
    
% Define R and C (Equation 2) in MATLAB, given the reaction rates in Figure 1.

alphaA = 50;
alphaPA = 500;
alphaR = 0.01;
alphaPR = 50;
betaA = 50;
betaR = 5;
deltaMA = 10;
deltaMR = 0.5;
deltaA = 1;
deltaR = 0.2;
gammaA = 1;
gammaR = 1;
gammaC = 2;
thetaA = 50;
thetaR = 100;
R0 = 0;
C0 = 0;

Kd = thetaA/gammaA;
rho = @(R) betaA./deltaMA./(gammaC.*R+deltaA);
Ahat = @(R)  1/2*(alphaPA.*rho(R)-Kd)+1/2*sqrt((alphaPA.*rho(R)-Kd).^2+4*alphaA.*rho(R)*Kd);
sys = @(t,x) [betaR/deltaMR/(thetaR+gammaR*Ahat(x(1)))*(alphaR*thetaR + alphaPR*gammaR*Ahat(x(1)))-gammaC*Ahat(x(1))*x(1)+deltaA*x(2)-deltaR*x(1);...
           gammaC*Ahat(x(1))*x(1) - deltaA*x(2)];

%----------------------------- 2B -----------------------------%

tspan = [0 200];    
IC = [R0 C0];  
[t,x] = ode15s(sys,tspan,IC); % ode45 stop around 160

figure
hold on
plot(t,x(:,1))
plot(t,x(:,2),'--')
xlim([0 200])
ylim([0 2000])
xlabel('time (hr)')
ylabel('number of molecules')
legend('R','C')
title('Figure 3a')
hold off

%----------------------------- 2C -----------------------------%

% setting dRdt and dCdt = 0

null1 = @(R) (betaR./deltaMR./(thetaR+gammaR.*Ahat(R)).*(alphaR.*thetaR + alphaPR.*gammaR.*Ahat(R))-gammaC.*Ahat(R).*R-deltaR.*R)./(-deltaA); % dRdt = 0
null2 = @(R) gammaC.*Ahat(R).*R./deltaA; % dCdt = 0

R4 = 0:250; % some range for R
null_1 = null1(R4);
null_2 = null2(R4);

figure
hold on
plot(R4,null_1)
plot(R4,null_2)
legend('dRdt = 0','dCdt = 0')
xlabel('R')
ylabel('C')
title('Figure 4')
xlim([0 inf])
ylim([0 max(max(null_1,null_2))*1.1])

% find fixed point

dif = @(R) null1(R) - null2(R);
Rfp = fzero(dif,90);
Cfp = null1(Rfp);
fp = [Rfp, Cfp]; % fixed point

% quiver

dRdt = @(R,C) betaR./deltaMR./(thetaR+gammaR.*Ahat(R)).*(alphaR.*thetaR + alphaPR.*gammaR.*Ahat(R))-gammaC.*Ahat(R).*R-deltaR.*R+deltaA.*C;
dCdt = @(R,C) gammaC.*Ahat(R).*R - deltaA.*C;

q2 = [11 14 17 180 220 250]; % specific points in the R4 range...
q1 = [1 2 100 120 140  180];    % ...where to plot the vectors
                                % eyeballed from the orignal figure
xq = [R4(q1); R4(q2)];
yq = [null_1(q1); null_2(q2)];
vx = [dRdt(R4(q1),null_1(q1)); dRdt(R4(q2),null_2(q2))];
vy = [dCdt(R4(q1),null_1(q1)); dCdt(R4(q2),null_2(q2))];
vx(2,:) = vx(2,:)./abs(vx(2,:));    % trying to normalize the vectots
vy(1,:) = vy(1,:)./abs(vy(1,:));    % but still dif. sizes...

quiver(xq,yq,vx,vy,0.05);
hold off

%----------------------------- 2D -----------------------------%

deltaR = 0.05; % Spontaneous degradation of R
sys = @(t,x) [betaR/deltaMR/(thetaR+gammaR*Ahat(x(1)))*(alphaR*thetaR + alphaPR*gammaR*Ahat(x(1)))-gammaC*Ahat(x(1))*x(1)+deltaA*x(2)-deltaR*x(1);...
           gammaC*Ahat(x(1))*x(1) - deltaA*x(2)];
       
[t2,x2] = ode15s(sys,tspan,IC);

figure
hold on
plot(t2,x2(:,1))
xlim([0 200])
ylim([0 3000])
xlabel('time (hr)')
ylabel('number of molecules')
title('Figure 5a')
hold off

% Why do you think changing this variable had such a strong influence on the outcome?
    % By reducing the spontaneous rate of degradation of R, there is 
    % more R overall and the system is able to reach an equilibrium, 
    % which was not in the first case (deltaR = 0.2) since at some 
    % point all of the R was consumed/degraded, inducing oscillations.

%----------------------------- 2E -----------------------------%

% This model is “noise resistant”. What does that mean? Why is it noise resistant?
    % Noise resistant means that small perturbations in the system do  
    % not change its dynamics. This is due to the fact that the 
    % stability of the system, determined by the trace of the of the 
    % Jacobian, is the same for a wide range of values. 