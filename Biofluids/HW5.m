%% Diego Alba - Biofluid Mechanics - HW#5

% Mo as a function of r' for alpha  = 0.1 0.5 1.0 5.0 10 20

alpha = [0.1 0.5 1.0 5.0 10 20];
r_prime = linspace(0,1); % r_prime = r/R, so normalized between 0-1;

figure
hold on
for j = 1:length(alpha)
    MoExp(j,:) = (1-besselj(0,alpha(j)*r_prime*1i^(3/2))./besselj(0,alpha(j)*1i^(3/2)));
    Mo(j,:) = abs(MoExp(j,:));
    plot(r_prime,Mo(j,:))
    xlabel('r"')
    ylabel('Mo')
end
% ylim([0 max(Mo(1,:))])
legend('alpha = 0.1', 'alpha = 0.5', 'alpha = 1.0', 'alpha = 5.0','alpha = 10','alpha = 20')
hold off

% Reproduce plots from class (M1, M1/alpha^2, epsilon1 vs alpha)
alpha = linspace(0,15);

M1Exp = (1-2/1i^(3/2)./alpha.*besselj(1,alpha*1i^(3/2))./besselj(0,alpha*1i^(3/2)));
M1 = arrayfun(@norm,M1Exp);
Eps1 = atan(imag(M1Exp)./real(M1Exp))*180/pi;

figure('Units','normalized','Position',[0.5 0.1 0.4 0.7])
s(1) = subplot(2,1,1);
yyaxis left
hold on
plot(alpha,M1,'k')
plot(alpha,ones(1,100),'k.','markers',1)
ax = gca;
ax.XTick = [];
ax.YTick = [1];
ylim([0 1])
ylabel('M_1')
hold off
pos(1,:) = get(s(1),'Position');

yyaxis right
hold on
plot(alpha,M1./alpha.^2,'k--')
ax = gca;
ax.YTick = [0.1 1/8];
ylim([0 0.2])
ylabel('M_1 / alpha^2')
plot(alpha, 0.1*ones(1,100),'k.','markers',1)
plot(alpha, 1/8*ones(1,100),'k.','markers',1)
hold off

s(2)=subplot(2,1,2);
plot(alpha,Eps1,'k')
ax = gca;
ax.XTick = [0 5 10 15];
ax.YTick = [30 60 90];
ylim([0 100])
xlabel('alpha')
ylabel('epsilon_1')
pos(2,:) = get(s(2),'Position');
pos(2,2) = pos(1,2)- pos(1,4);
pos(2,4) = pos(1,4);
set(s(2),'Position',pos(2,:));