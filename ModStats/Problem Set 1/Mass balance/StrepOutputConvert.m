%% 540.305 Problem Set 1: Matlab Introduction - Diego Alba
%% 6 A script for mass balance

function [weight_fraction_strep_in_solvent] = StrepOutputConvert...
    (water_in_L, solvent_in_L)

solvent_in = solvent_in_L*1000; %cm3
water_in = water_in_L*1000;

con_strep_in = 0.01; % g/cm3
con_strep_out = 0.2/1000; % g/cm3
d_solvent = 0.6; % g/cm3
d_water = 1; % g/cm3

solvent_out = solvent_in*d_solvent; % g
water_out = water_in*d_water; % g
strep_out = water_in*con_strep_in - water_out*con_strep_out; % g

weight_fraction_strep_in_solvent = strep_out/solvent_out; % g/g

disp(['The weight fraction of streptomycin in solvent is ', ...
    num2str(weight_fraction_strep_in_solvent)])
end
