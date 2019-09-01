% Gas-phase Dimerization 2A->B

% elementary rate law
% isothermal
% PBR

% DATA
W = 1; % kg
yA0 = 1;
P0 = 20; % atm
xA1 = 0.3;
P1 = 5; % atm

% STOICH. TABLE
% Fao  -Fao*xA   Fao(1-xA)
% 0    Fao*xA/2  Fao*xA/2
% Fao            Fao(1-xA/2)

% RATES
% minus_rA_P = k*Ca^2 = k*(Cao*(1-xA)/(1-xA/2)*P/P0)^2 % pressure drop
% minus_rA = k*Ca^2 = k*(Cao*(1-xA)/(1-xA/2))^2 % no pressure drop

% PBR MOL BALACE
% Fao*dxA/dW = minus_rA_P = k*Ca^2 = k*(Cao*(1-xA)/(1-xA/2)*P/P0)^2

% dxA/dW = k*Cao/vo * ((1-xA)/(1-xA/2)* y)^2, wher y = P/P0
% dy/dW = -alpha/(2*y)*(1-xA/2)

% dxA/dy = dxA/dW * dW/dy =
% [k*Cao/vo * ((1-xA)/(1-xA/2) * y)^2]/[-alpha/(2*y)*(1-xA/2)] =
% [-2*k*Cao/(vo*alpha)] * (1-xA)^2 / (1-xA/2)^3 * y^3, separable!

% find [k*Cao/(vo*alpha)] = cnt, use PBR data
cnt = integral(@(xA) (1-xA/2).^3./(1-xA).^2,xA1,0)/...
        (-2*integral(@(y) y.^3,P1/P0,1));

% loop to find alpha and [k*Cao/vo]   
guess = 0.6;
while guess < 0.75 % for some reason ode45 takes too long after this
    A = guess;
    % define system of ODEs for dx/dw and dy/dw
    sys = @(w,x) [ % xA = x(1) , y = x(2)
        A * ((1-x(1))/(1-x(1)/2)* x(2))^2; % A = k*Cao/vo 
        -(A/cnt)/(2*x(2))*(1-x(1)/2) % alpha = A/cnt
        ];
    if guess > 0.6 % just to get through the first iteration
        if  x(end,2) - P1/P0 <0 % make sure not to overshoot y
            break
        end
    end
    [w, x] = ode45(sys,[0 1],[0;1]); % ICs for dx/dw and dy/dw
    guess = guess + 0.00001; % small enough increments to  find a good A
end
figure
plot(w,x) % plot displaayed at the end
xlabel('W')
ylabel('xA , y')
legend('conversion (xA)','pressure drop (y)')

alpha = guess/cnt 
A = guess

% A) FBR, no pressure drop, xA1 = ?

%MOL BALANCE, FBR
% W = Fao*xA/minus_ra = vo*xA/[k*Cao*((1-xA)/(1-xA/2))^2]

eq = @(xA) W - (1/A)*xA/((1-xA)/(1-xA/2))^2;
xA1_fbr = fsolve(eq,0,optimset('Display','off'))

% B) Which xA1 is higher? Why? Which effect dominates?

% The conversion of the FBR reactor is greater (0.395) than that of the
% PBR (0.3) because there is no pressure drop, which reduces conversion. 
% This is even if the FBR reaction is happening at the outlet conversion, 
% meaning that a pressure drop has a greater effect on conversion. 

% C) PBR (same W, different L), xA1 = ? if D = 2*Dold, p_size = p_size/2

% double pipe diameter: (inverserly proportional, and cubed*)
% (*G,dz/dw, and turbulent)
alpha = alpha/(4^3); 
% halve particle size: (inversily proportional, but reduced)
alpha = alpha/(1/2)

% solve system again

sys = @(w,x) [ % xA = x(1) , y = x(2)
    A * ((1-x(1))/(1-x(1)/2)* x(2))^2; % A same 
    -(alpha)/(2*x(2))*(1-x(1)/2) % alpha new
    ];
[w, x] = ode45(sys,[0 1],[0;1]); % initial conditions for dx/dw and dy/dw
xA1_pbr = x(end,1)
