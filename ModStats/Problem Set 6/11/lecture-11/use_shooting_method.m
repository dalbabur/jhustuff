
y2_init = fsolve(@zero_at_y_initial,2);
[x,y] = ode45(@ode_system_1,[0 1], [0 y2_init]);

% Plot the value of y_1 only
plot(x,y(:,1))