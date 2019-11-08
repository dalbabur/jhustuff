function [T,X] = gillespie_ex(Xstart,tspan)

% Reactions
%
% x -> 2x, rate = alpha*x, x=x+1
% x + y -> xy, rate = beta*x*y, x=x-1, y=y+1
% y -> null, rate = gamma*y, y=y-1

stoich_matrix = [1 0;-1 1;0 -1];

correction = 100;

alpha = correction*2/3;
beta = 1;
gamma = 50;%correction*1;

maxlength = 10000;

T = NaN(maxlength,1);
X = NaN(maxlength,length(Xstart));

T(1) = tspan(1);
X(1,:) = Xstart;

count = 1;
while T(count) < tspan(2)

    % probability of different reactions
    a = [alpha*X(count,1),beta*X(count,1)*X(count,2),gamma*X(count,2)];
    a0 = sum(a);
    r = rand(1,2);
    
    % step length
    tau = -log(r(1))/a0;
    
    %reaction choice
    mu = find((cumsum(a) >= r(2)*a0), 1,'first');
    
    % Update time and reactants
    T(count+1) = T(count)+tau;
    X(count+1,:) = X(count,:) + stoich_matrix(mu,:);
    disp(['Time = ',num2str(T(count+1))]);
    count = count+1;
    if count==maxlength
        disp(['Reached maximum length of ',num2str(maxlength)]);
        break
    end
end

T(count:end) = [];
X(count:end,:) = [];

figure;

plot(T,X(:,1),'b','DisplayName','Sheep');
hold on
plot(T,X(:,2),'r','DisplayName','Wolves');
xlabel('time');
ylabel('Population');

legend show

