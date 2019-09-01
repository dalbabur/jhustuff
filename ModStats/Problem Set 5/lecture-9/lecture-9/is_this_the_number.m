
function response = is_this_the_number(guess)
   load('secret_number.mat');
   if number == guess
       response = 'yes';
   elseif number > guess
       response = 'higher';
   elseif number < guess
       response = 'lower';
   end