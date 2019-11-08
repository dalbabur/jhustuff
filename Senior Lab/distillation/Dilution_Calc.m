% Script to back-calculate original wt% concentration from dilution

% Known values
rhoW = .997; % g/mL
rhoE = .789; % g/mL

% Measured values - enter values here
concDilute = .19; % wt percent
volSolution = 300; % microliters
volAddedDI = 300; % microliters

% For a 1g basis solution of the same concentration as concDilute, calculate 
% the individual volumes for both water and ethanol
massWBasis = 1 - concDilute; % g
massEBasis = concDilute; % g

% Volume additivity does not apply to ethanol and water mixtures
% Since we cannot simply add volW and volE for the total volume of our
% 1g basis solution, we have to use the following graph:
% http://www1.lsbu.ac.uk/water/aqueous_alcohol.html

% In order to use the graph we need to convert our concDilute to a mol %
molWBasis = massWBasis / 18.01528; % mol
molEBasis = massEBasis / 46.07; % mol
molFracEBasis = molEBasis / (molEBasis + molWBasis); % dimensionless
molFracWBasis = 1 - molFracEBasis;

% Values from the chart
partialMolVolW = 17900; % microliters/mol - 15450 for 900microliter
partialMolVolE = 55000; % microliters/mol - 54300 for 900 microliters

% Calculate total volume of our 1g solution
volBasisSol = molEBasis * partialMolVolE + molWBasis * partialMolVolW; % microliters

% Proportion between weight of solution and volume of solution between 
% basis solution and dilution solution to solve for weight of dilution
massDilute = (volSolution + volAddedDI) / volBasisSol; % g

% Now that we have the weight of the dilution, we can figure out the 
% individual masses and volumes of water and ethanol within the dilution
% because we know the wt% composition of the dilution
massEDilution = concDilute * massDilute; % g
massWDilution = (1 - concDilute) * massDilute; % g
massWSolution = massWDilution - (volAddedDI / 1000 * rhoW); % g
originalConc = massEDilution / (massEDilution + massWSolution); % wt %




