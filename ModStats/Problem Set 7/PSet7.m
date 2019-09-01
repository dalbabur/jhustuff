%% a) Probability that A wins
n=10000;
B=randi([0 25],n);
A=randi([12 30],n);
p = sum(sum(A<B))/n^2

%% b) Histogram
n=1000;
B=randi([0 25],n,1);
A=randi([12 30],n,1);

times = A.*(A<B)+B.*(B<A);
hist(times,20)

%% c) 12 Horse Race
n=100000;
B=randi([0 25],n,1);
A=randi([12 30],n,1);
all = [A,B,normrnd(37,19,n,10)];

pA=sum(sum(repmat(A,1,11)<all(:,2:end),2)==11)/n
pB=sum(sum(repmat(B,1,11)<[all(:,1) all(:,3:end)],2)==11)/n

%% d) Betting
takeA=1<8*pA
takeB=1<5*pB
