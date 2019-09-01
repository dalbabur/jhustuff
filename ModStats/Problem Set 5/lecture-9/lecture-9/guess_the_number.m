
function number = guess_the_number(lowest,highest)
% Takes a minimum and a maximum value and attempts to guess
% the secret number that lies between them.
% This function assumes the secret number is an integer.

response = 'nothing yet';

while strcmp(response,'yes') == 0
    guess = floor((lowest+highest)/2);
    response = is_this_the_number(guess);
    disp(['For guess ' num2str(guess) ...
          ', response is  ' response])
    if strcmp(response,'higher')
        lowest = guess;
    elseif strcmp(response,'lower')
        highest = guess;
    end
end

