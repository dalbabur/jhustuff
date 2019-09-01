
function set_secret_number(limit)
   number = randi(limit);
   save('secret_number.mat','number');
   