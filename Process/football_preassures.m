%Creates a vector of many pressures from 0 psi to 200 psi,
%converts that vector to a new vector of pressures in Pa,
%and then creates a plot of the data with psi on the x-axis and Pa on the y-ax

psi = 0:8:200;
Pa = psi2Pa(psi);
plot(psi,Pa)
xlabel('psi')
ylabel('Pa')
title('psi vs Pa')
axis([7 17 50000 120000])
hold on
plot(8.7,psi2Pa(8.7),'r*');
plot(16.1,psi2Pa(16.1),'r*');
min ='\leftarrow min preassure: 8.7 psi, 60kPa';
max ='max preassure: 16.1 psi, 111 kPa\rightarrow ';
text(9,psi2Pa(8.7),min);
text(15.5,psi2Pa(16.1),max, 'HorizontalAlignment', 'right');