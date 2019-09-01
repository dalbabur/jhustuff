% HM 3

K = 0.05/1000; % mol/L
mu_max = 1.386; % hr-1
Yxo = 2.22; % g O2 / g cells
klacl = 0.2; % mol/ L hr
MwO2 = 32; % g/mol

x =@(Cl) klacl./(mu_max*(Cl./(K+Cl))*Yxo/MwO2);
cl = linspace(0,4);

figure
plot(x(cl),cl)

x_crit = 0.9*klacl*4/(3*mu_max*Yxo/MwO2);