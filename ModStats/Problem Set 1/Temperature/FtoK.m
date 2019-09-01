%% 540.305 Problem Set 1: Matlab Introduction - Diego Alba
%% 4 Temperature Conversion

function [T_kelvin] = FtoK(T_Fahrenheit)
T_kelvin = (T_Fahrenheit-32)*5/9+273.15;
disp(['The temperature in Kelvin is ', num2str(T_kelvin),'K'])
end