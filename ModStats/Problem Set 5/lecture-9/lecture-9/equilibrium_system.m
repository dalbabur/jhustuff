
function y = equilibrium_system(x)
  C_A = x(1);
  C_B = x(2);
  C_C = x(3);
  C_AB = x(4);
  C_ABC = x(5);
  K_eq1 = 1e-9;
  K_eq2 = 1e-9;
  C_A0 = 2e-6;
  C_B0 = 2e-6;
  C_C0 = 2e-6;

  y(1) = C_AB / (C_A*C_B) - K_eq1;
  y(2) = C_ABC / (C_AB*C_C) - K_eq2;
  y(3) = C_A + C_AB + C_ABC - C_A0;
  y(4) = C_B + C_AB + C_ABC - C_B0;
  y(5) = C_C + C_ABC - C_C0;