%% 540.305 Problem Set 1:  Vectors, Arrays, Data and Basic Plotting - Diego Alba

% Script will ask for some input and display all answers in the comand window
clear
clc
addpath('functions','resources','figures')
%% 1 Basic vector and array practice

disp('Basic vector and array practice')
% a
v = [54/(3+(4.2)^2),32,(6.3)^2-(7.2)^2,54,exp(3.7), sin(deg2rad(66))+cos(3*pi/8)];
disp(['1, (a) : [',num2str(v),']'])

% b
x = 0.85;
y = 12.5;
w = [y,y^x,log(y/x),y+x,y+x]';
disp('1, (b) : [')
disp(num2str(w))
disp('          ]')

% c
a = repmat(7.5,1,9)-[repmat(7.5,1,8),0];
disp(['1, (c) : a = [',num2str(a),']'])

% d
B = zeros(5,3);
B(:,1) = 1:5;
B(:,3) = repmat(3,1,5);
disp('1, (d) : B = [')
disp(num2str(B))
disp('          ]')

% e
N = [33 21 9 14 30; 30 18 6 18 34; 27 15 6 22 38; 24 12 10 26 42];
disp('1, (e) : A = [')
disp(num2str([N(1,1:4)', N(2,2:5)']))
disp('          ]')
disp(['1, (e) : B = [',num2str([N(:,3)' N(3,:)]),']'])
disp("1, (e) : C = Error: Expression or statement is incorrect--possibly unbalanced (, {, or [. ")
%----------------------------------------------------------

%% 2 Transforming vectors and arrays

disp('Transforming vectors and arrays')
% a
% function code in separate file
% b
% functions code in separate files
% c
seriesSum = sum(ones(1,10000)./(1:10000).*repmat([1,-1],1,10000/2));
disp(['2, (c): seriesSum = ',num2str(seriesSum)])
%----------------------------------------------------------

%% 3 Filtering, searching and summarizing arrays and vectors

disp('Filtering, searching and summarizing arrays and vectors')
% a
% function code in separate file
A=[1 5 3 4 2; 9 7 6 8 10; 11 14 13 12 15];
[v,w] = filterMat(A);
disp(['3, (a) : evens = [',num2str(v'),']'])
disp(['3, (a) : odds = [',num2str(w'),']'])
% b
% function code in separate file
evenA = odds2zero(A);
disp('3, (b) A without odds: [')
disp(num2str(evenA))
disp('          ]')
%----------------------------------------------------------

%% 4 String handling

% a
hi = 'hello';
% b
strings = {'hello', 'goodbye','hello','hello', 'goodbye', 'goodbye'};
% c
n = sum(strcmp(hi, strings));
allstrings={};
for i = 1:length(strings)
    allstrings = [allstrings, strsplit(strings{i})];
end
m = sum(strcmp(hi,allstrings));

%----------------------------------------------------------

%% 5 Processing EEG data

disp('Processing EEG data')
% a
load('acc')
load('time')
% b
figure
plot(time,acc)
xlabel('tims (s)')
ylabel('voltage (mV)')
saveas(gcf,'figures/EEG.png')
% c
detector = activity(acc, time);
% d
figure
subplot(2,1,1)
plot(time,acc)
xlabel('tims (s)')
ylabel('voltage (mV)')
subplot(2,1,2)
plot(time,detector)
saveas(gcf,'figures/detector.png')

%----------------------------------------------------------

%% 6 Processing PDB files

disp('Processing PDB files')
% a 
% b
[~,~,coords] = xlsread('mystery_molecule.xls','G2:L660');
% c
for i = 1:length(coords)
    coords{i,6} = double(coords{i,6});
end
coords = cell2mat(coords);
coords = sortrows(coords,6);
figure
plot3(coords(:,1),coords(:,2),coords(:,3))
saveas(gcf,'figures/DNA.png')
% d
C = sum(coords(:,6)==67); % black
N = sum(coords(:,6)==78)+C; % blue
O = sum(coords(:,6)==79)+N; % red
P = sum(coords(:,6)==80)+O; % green

figure
hold on
plot3(coords(1:C,1),coords(1:C,2),coords(1:C,3),'black')
plot3(coords(C:N,1),coords(C:N,2),coords(C:N,3),'blue')
plot3(coords(N:O,1),coords(N:O,2),coords(N:O,3),'red')
plot3(coords(O:P,1),coords(O:P,2),coords(O:P,3),'green')
hold off
saveas(gcf,'figures/colorDNA.png')

%----------------------------------------------------------
clear






