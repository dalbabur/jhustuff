function TC = dewpoint_T_solver(y1, P, TC_guess, A1, B1, C1, A2, B2, C2)
% by Sakul Ratanalert, PhD
% Given the Antoine equation constants for two-component two-phase mixture,
% calculate the temperature at which the given vapor mole fractions exist
% at the given pressure.
% Input(s): y1 = vapor mole fraction for Component 1
%           P = pressure of system (in mmHg)
%           TC_guess = initial guess (in degC) for dew point temperature
%           A1 = Antoine coefficient A for Component 1
%           B1 = Antoine coefficient B for Component 1
%           C1 = Antoine coefficient C for Component 1
%           A2 = Antoine coefficient A for Component 2
%           B2 = Antoine coefficient B for Component 2
%           C2 = Antoine coefficient C for Component 2
% Output(s): TC = dew point temperature (in degC)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute vapor mole fraction for Component 2
y2 = 1 - y1;

% Write equation that we want to equal 0
eqn = @(TC) P*(y1/10^(A1 - B1/(TC + C1)) + y2/10^(A2 - B2/(TC + C2))) - 1;

% Use fsolve to solve nonlinear equation
TC = fsolve(eqn,TC_guess);


end