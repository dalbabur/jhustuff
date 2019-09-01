%% 540.305 Problem Set 4:

clear
clc

%% 1 Solving systems of linear equations

% a
C = [6 4 -3; 18 -5 4; -5 0 -8];
b = [2 6 -20]';
x = C\b;
disp(['Part 1, (a) : [x,y,z] = [',num2str(x'),']'])

% b
load('A_matrix.mat')
b = zeros(1,100);
for i = 1:100
    b(i) = 2^i;
end
sol = A\b';
disp(['Part 1, (b) : [x1,x2,x3,x4,x5] = [',num2str(sol(1:5)'),']'])

% c
A = reshape(1:10000,100,100)';
b = ones(100,1);
b(10)=5;
sol = A\b;
disp(['Part 1, (c) : [x1,x2,x3,x4,x5] = [',num2str(sol(1:5)'),']'])

%% 2 Solving non-linear equations

% a 
x = -2:0.001:6;
y = -0.6*x.^3+3*x.^2+2*x-0.5;
figure
plot(x,y)
xlabel('x')
ylabel('y')
title('y = -0.6*x.^3+3*x.^2+2*x-0.5')
% zeros @ x = -0.767, 0.195 , 5.571
% max y = 17.59

% b
disp(['Part 2, (b): max = ',num2str(max(y))]);

% c
disp(['Part 2, (c): roots = ',num2str(roots([-.6 3 2 -.5])')]);

%% 3 Integrating nmerical data that represents a curve

w = 8;
h =[2.0	2.1	2.3	2.4	3.0	2.9	2.7	2.6	2.5	2.3	2.2	2.1	2.0];
v =[2.0	2.2	2.5	2.7	5	4.7	4.1	3.8	3.7	2.8	2.5	2.3	2.0];
day=[1	32	60	91	121	152	182	213	244	274	305	335	366];
flow = 86400*w*h.*v;

disp(['Part 3,  Anual Flow = ',num2str(trapz(day,flow)),' m^3']);

%% 4 Deriavtives of numerical data

% a
time = xlsread('Nanotube_length_time.xlsx','A2:A35');
lengths = xlsread('Nanotube_length_time.xlsx','B2:AC35');
figure
plot(time, lengths)
xlim([time(1) inf])
hold on
plot(time, mean(lengths,2),'--black','LineWidth',3)
xlabel('time (hr)')
ylabel('length (um)')
title('Nanotube Growth')

% b
g = diff(lengths);
figure
plot(time(1:end-1), g)
xlim([time(1) inf])
hold on
plot(time(1:end-1), mean(g,2),'--black','LineWidth',3)
xlabel('time (hr)')
ylabel('length (um)')
title('Nanotube Growth Rate')

%% 5 Solving systems of linear differential equations

% a
A=[1 2 3; 0 3 6; 0 0 4];
t=10;
x0 = [1 0 1]';
x=expm(A*t)*x0;
disp(['Part 5, (a) : [x,y,z] = [',num2str(x'),']'])

% b
[vect,val]=eig(A);
% x2=vect*exp(val*t)*vect^-1*x0;
disp('Part 5, (b) : eigenvectors')
disp(num2str(vect))
disp('Part 5, (b) : eigenvalues')
disp(num2str(val))
% c
t=0:0.001:10;
x=zeros(3,length(t));
for i = 1:length(t)
    x(:,i)=expm(A*t(i))*x0;
end
figure
subplot(1,2,1)
plot(t,x)
title('by Exp Matrix')
subplot(1,2,2)
[tout,yout]=ode45(@(t,x)[x(1)+2*x(2)+3*x(3);3*x(2)+6*x(3);4*x(3)],[0 10],x0');
plot(tout,yout)
title('by ode45')

%% 6 Solving systems of non-linear ODEs (a trasncriptional oscullator)

kt = 0.5;
ktr = .1155;
Km = 40;
kmdeg = .0058;
kpdeg = .0012;
kleak = 0.0005;

sys = @(t,x)[...
    kt/(1+x(6)^2/Km^2)-kmdeg*x(1)+kleak;...
    kt/(1+x(4)^2/Km^2)-kmdeg*x(2)+kleak;...
    kt/(1+x(5)^2/Km^2)-kmdeg*x(3)+kleak;...
    ktr*x(1)-kpdeg*x(4);...
    ktr*x(2)-kpdeg*x(5);...
    ktr*x(3)-kpdeg*x(6);...
    ];
x0 = [100 100 100 200 200 200];

[t,y] = ode45(sys,[0 1000000],x0);
figure
plot(t,y)
legend('g1','g2','g3','p1','p2','p3','Location','northwest')
xlabel('time')
ylabel('concentration')
title('Oscillatory gene expression')