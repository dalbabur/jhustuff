function TC = bubblepoint_T_solver(x1, P, TC_guess, A1, B1, C1, A2, B2, C2)
% by Sakul Ratanalert, PhD
% Given the Antoine equation constants for two-component two-phase mixture,
% calculate the temperature at which the given liquid mole fractions exist
% at the given pressure.
% Input(s): x1 = liquid mole fraction for Component 1
%           P = pressure of system (in mmHg)
%           TC_guess = initial guess (in degC) for bubble point temperature
%           A1 = Antoine coefficient A for Component 1
%           B1 = Antoine coefficient B for Component 1
%           C1 = Antoine coefficient C for Component 1
%           A2 = Antoine coefficient A for Component 2
%           B2 = Antoine coefficient B for Component 2
%           C2 = Antoine coefficient C for Component 2
% Output(s): TC = bubble point temperature (in degC)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute vapor mole fraction for Component 2
x2 = 1 - x1;

% Write equation that we want to equal 0
eqn = @(TC) (x1*10^(A1 - B1/(TC + C1)) + x2/10^(A2 - B2/(TC + C2))) - P;

% Use fsolve to solve nonlinear equation
TC = fsolve(eqn,TC_guess);


end