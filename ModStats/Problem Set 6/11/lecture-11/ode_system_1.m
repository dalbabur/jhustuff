
function dydx = ode_system_1(t,x)
  dydx = [x(2); x(1)^3-x(1)*x(2)];
  
  
