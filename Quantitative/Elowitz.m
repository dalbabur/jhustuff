
% PARAMETERS %

tps_r = 0.0005; % promoter strength (repressed), transcripts/s
tps_a = 0.5;    % promoter strength (fully induced), transcripts/s
tauP = 10;      % half-life protein
tauM = 2;       % half-life mRNA
n = 2;          % Hill coefficient
teff = 20;      % avg. translation efficiency, proteins/transcript
Km = 40;        % number of repressors necessary to half-maximally
                % repress a promoter, monomers/cell

decayM = log(2)/tauM; % mRNA decay time
decayP = log(2)/tauP; % protein decay time
a0 = tps_r*60; % change to min
a = tps_a*60;  % change to min

beta =(decayP/decayM); % protein decay rate / mRNA decay rate
alpha = a*teff/decayP/Km; % number of protein copies per cell produced 
                          % from a given promoter type, induced
alpha0 = a0*teff/decayP/Km; % number of protein copies per cell produced 
                            % from a given promoter type, repressed
 
% SYSTEM OF ODEs %

% Box 1 gives dimensionless Eq. 
% To reproduced Fig 1.C, equations are rescaled:

%SCALING

%   time - mRNA lifetime
%   [p] - Km
%   [mRNA] - teff

sys = @(t,x)[...        % x 1-3 is m lacl, tetR, cl
                        % x 4-6 is p lacl, tetR, cl
    (-x(1)+teff*alpha/(1+(x(6)/Km)^n)+teff*alpha0)*decayM;... 
    (-x(2)+teff*alpha/(1+(x(4)/Km)^n)+teff*alpha0)*decayM;...  
    (-x(3)+teff*alpha/(1+(x(5)/Km)^n)+teff*alpha0)*decayM;...
    (-beta*(x(4)-x(1)*Km/teff))*decayM;...               
    (-beta*(x(5)-x(2)*Km/teff))*decayM;...
    (-beta*(x(6)-x(3)*Km/teff))*decayM;...
    
    ];

tspan = [0 1000]; % min
ic = [0 0 0 0 0 40]; % guessed based on figure 1c
[t,x] = ode45(sys, tspan, ic);

% PLOTTING %

figure
plot(t,x(:,[6 4 5]))
legend('cl','lacl','tetR')
ylim([0 6000])
xlim([0 1000])
ylabel('Proteins per cell')
xlabel('Time (min)')