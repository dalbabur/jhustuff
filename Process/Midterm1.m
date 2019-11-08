%% What do the following commands do?

% clc : clear command windom
% clear: clear workspace variables
% linspace: generate linearly spaced vector
% inv: calculate inverse of a matrix
% plot: generate plot from vetors
% title: title for a plot

%% What plot corresponds to this code?

% Code
x = [0 2 4 6 8 10 15 20 30 40 50 60 70 80 90 95 100]/100;
y = [0 13.4 23 30.4 36.5 41.8 51.7 57.9 66.5 72.9 77.9 82.5 87 91.5 95.8 97.9 100]/100;

figure
hold on
plot(x,y)
plot(x,x,'--r')
hold off
xlabel('X_M_e_t_O_H')
ylabel('Y_M_e_t_O_H')

% Plots to choose from
figure 
subplot(2,2,1)
    hold on
    plot(y,x)
    plot(x,x,'--r')
    hold off
    xlabel('X_M_e_t_O_H')
    ylabel('Y_M_e_t_O_H')
    title('A')
subplot(2,2,2)
    hold on
    plot(x,y,'--')
    plot(x,x,'r')
    hold off
    xlabel('X_M_e_t_O_H')
    ylabel('Y_M_e_t_O_H')
    title('B')
subplot(2,2,3)
    hold on
    plot(x,y)
    plot(x,x,'--r')
    hold off
    xlabel('X_M_e_t_O_H')
    ylabel('Y_M_e_t_O_H')
    title('C') % correct
subplot(2,2,4)
    hold on
    plot(-x,-y,'--')
    plot(-x,-x,'r')
    hold off
    xlabel('X_M_e_t_O_H')
    ylabel('Y_M_e_t_O_H')
    title('D')
    
%% System of Equations

% Material Balances, B and D?

% F = B + D
% F*z = B*xB + D*xD

F = 150;
z = 0.52;
xD = 0.9;
xB = 0.05;

% Attempts:

% Option A
A = [xB, xD; 1 1];
b = [F;F*z];
sol = A\b;
B = sol(1);
D = sol(2);
% Option B
A = [1, 1; xB xD]; % correct
b = [F;F*z];
sol = A\b;
B = sol(1);
D = sol(2);
% OptionC
A = [xB, xD; 1 1];
b = [F*z;F];
sol = A\b;
B = sol(2);
D = sol(1);
% Option D
A = [1, 1; xB xD];
b = [F;F*z];
sol = A/b;
B = sol(1);
D = sol(2);

