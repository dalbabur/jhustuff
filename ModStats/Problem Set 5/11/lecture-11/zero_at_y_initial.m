
function delta = zero_at_y_initial(q)
    initial_conds = [0 q];
    [x,y] = ode45(@ode_system_1,[0 1],initial_conds);
    final_y1 = y(end,1);
    delta = final_y1 - 2;
    
    