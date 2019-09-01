

function [min_sol,max_sol] =  bisection_find_zero(func, p_min, p_max, tolerance)
% Assumes the function goes down over the
% interval
% Uses relative tolerance to determine when a 
% solution has been found
   
 
while abs((p_max - p_min)/p_min) > tolerance
    guess = (p_min + p_max) / 2;
    if func(guess) > 0
        p_min = guess;
    else
        p_max = guess;
    end
end

min_sol = p_min;
max_sol = p_max;