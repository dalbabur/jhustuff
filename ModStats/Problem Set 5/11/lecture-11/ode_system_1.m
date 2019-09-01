
function dydx = ode_system_1(x,y)
  dydx = [y(2); 4*(y(1) - x)];
  
  
