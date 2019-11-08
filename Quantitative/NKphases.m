function out = NKphases(alpha,beta,sigma,gamma, K)
for k = K
    xnull = gamma/sigma; % dydt = 0
    ynull = @(x) alpha/beta*(1-x/k); % dxdt = 0
    ylimit = fzero(ynull,0); % lower limit for ynull since y >= 0
    figure
    hold on
    plot(0:ylimit,ynull(0:ylimit))
    plot([xnull xnull],[0,ynull(0)+1])
    legend('dxdt = 0','dydt = 0')
    xlabel('Prey')
    ylabel('Predator')
    title(['1A - Phase Diagram for K = ',num2str(k)])
    fp = [xnull, ynull(xnull)];
    fp0 = [0,0];
    J = @(p) [alpha*(1 - 2*p(1)/k) - beta*p(2), -beta*p(1); sigma*p(2), sigma*p(1)-gamma];
    J0 = J(fp0);
    Jfp = J(fp);
    
    e0 = eig(J0);
    e = eig(Jfp);
    xspan = linspace(-120,120,20);
    yspan = linspace(-ynull(0),ynull(0),20);
    [x,y] = meshgrid(xspan,yspan);
    y = flipud(y);
    dx = NaN(size(x));
    dy = NaN(size(y));
    
    % check pull of fixed points (asumme equal strength through midline)
    mid = (fp-fp0)/2;
    s = -1/(fp(1)/fp(2));
    
    % genrate vector field taking into account the two fixed points
    for m=1:length(x)
        for n=1:length(y)
            if y(m,n)+fp(2) < s*(x(m,n)+fp(1)) % effect of only (0,0)
                dx(m,n) = J0(1,1)*(x(m,n)+fp(1)) + J0(1,2)*(y(m,n)+fp(2));
                dy(m,n) = J0(2,1)*(x(m,n)+fp(1)) + J0(2,2)*(y(m,n)+fp(2));
            elseif y(m,n)+fp(2) < s*(x(m,n)+fp(1))-s*fp(1)+fp(2) && y(m,n)+fp(2) > s*(x(m,n)+fp(1)) % effect of both fixed points
                dfp = (abs((-s)*(x(m,n)+fp(1))+y(m,n)+fp(2))/sqrt((-s)^2+1))/sqrt(fp*fp'); % distance between fixed points to weight effects
                dx(m,n) = (J0(1,1)*(x(m,n)+fp(1)) + J0(1,2)*(y(m,n)+fp(2)))*(1-dfp)+dfp*(Jfp(1,1)*x(m,n) + Jfp(1,2)*y(m,n));
                dy(m,n) = (J0(2,1)*(x(m,n)+fp(1)) + J0(2,2)*(y(m,n)+fp(2)))*(1-dfp)+dfp*(Jfp(2,1)*x(m,n) + Jfp(2,2)*y(m,n));
            else % effect of 2nd fixed point
                dx(m,n) = Jfp(1,1)*x(m,n) + Jfp(1,2)*y(m,n);
                dy(m,n) = Jfp(2,1)*x(m,n) + Jfp(2,2)*y(m,n);
            end
        end
    end
    
    quiver(x+fp(1),y+fp(2),dx,dy);
    xlim([-20,120])
    ylim([-20, 90])
    hold off
end
end