
function delta = zero_at_x_initial(q)
    [~, x] = ode45(@ode_system_1,[1 2],[1/2 q]);
    final_x1 = x(end,1);
    delta = final_x1 - 1/3;
    
    