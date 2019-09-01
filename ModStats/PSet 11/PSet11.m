clear;

%% 9.1-2

control = [17.9 12.2 14.9 13.8 26.1 15.4 20.3 16.9 20.8 14.8];
deficient = [ 7.0 6.9 13.3 11.1 11.0 16.5 12.7 12.4 17.1 9.0];
slow = [19.8 20.3 16.1 17.9 12.4 12.5 17.4 19.9 27.3 14.4];

data = [ control deficient slow ];
groups(1:10) = {'c'};
groups(11:20) = {'d'};
groups(21:30) = {'s'};

[p,table,stats] = anova1(data,groups)
multcompare(stats);
% yes, heights differ 


%% 9.1-4
clear;
g0 = [12.7 14.1 13.2];  
g05 = [13.5 14.5 14.6];
g1 = [12.7 13.4 13.2];
g2 =[12.7 13.6 14.1];
g3 = [13.4 13.5 14.3];
g4 = [14.5 13.5 14.9];

data = [g0,g05,g1,g2,g3,g4];
groups(1:3) = {'0 g'};
groups(4:6) = {'0.5 g'};
groups(7:9) = {'1 g'};
groups(10:12) = {'2 g'};
groups(13:15) = {'3 g'};
groups(14:18) = {'4 g'};

[p,table,stats] = anova1(data,groups)
multcompare(stats);
% no differences

%%
% 1. The treatment populations must be normal.
% 2. The treatment populations must all have the same variance

%% 9.3-6

SA =[6.4 5.8 5.1 8.4 7.0 8.4 8.5 7.5 7.0 7.9]';
SB =[4.7 4.7 3.8 5.3 10.6 4.5 8.2 10.8 5.1 5.7]';
IA =[11.0 8.9 9.3 9.2 7.9 9.7 9.0 12.5 6.7 9.8]';
IB =[8.9 7.0 10.7 10.3 6.2 12.2 7.0 9.5 8.7 9.7]';

data = [SA SB; IA IB];
[p_vals, table,stats] = anova2(data, 10)
multcompare(stats,'estimate','column');
multcompare(stats,'estimate','row');

% Yes, it is possible, P=0.687
% Yes, there's a difference, p=0.00002
% Yes, no difference, p=0.3014

%% 9.3-9

S80T5 =[5 6 5 5 4 3]';
S80T10 =[8 8 8 8 8 8]';
S80T15 =[11 10 9 9 10 9]';
S150T5 =[9 11 9 8 10 9]';
S150T10 =[14 14 15 13 17 18]';
S150T15 =[16 15 26 24 24 25]';
S220T5 =[34 33 19 21 18 20]';
S220T10 =[60 59 29 31 28 31]';
S220T15 =[65 64 31 33 75 80]';

data = [S80T5 S80T10 S80T15;S150T5 S150T10 S150T15;S220T5 S220T10 S220T15];
[p_vals, table,stats] = anova2(data, 6);

% No, it is not possible, P=0.007
% No, no model
% No, no model

%%
% Because the design is not balanced, the analysis becomes harder, and we
% do not know how to do the calculations. 

%% 9.5-4

data = [0.55, 0.49...
        0.60, 0.42...
        0.37, 0.28...
        0.30, 0.28...
        0.54, 0.54...
        0.54, 0.47...
        0.44, 0.33...
        0.36, 0.20];

f=ff2n(3+1);
A=f(:,3)';
B=f(:,2)';
C=f(:,1)';

[p,table] = anovan(data,{A,B,C},'model','full','varnames',{'A','B','C'})

% Yes, it is appropiate (no interactions)
% B has an effect

%% 9.5-5

data = [68.0 77.5 98.0 98.0 74.0 77.0 97.0 98.0];
f = fliplr(ff2n(3));
f(f==0)=-1;
f(:,4)=f(:,1).*f(:,2);
f(:,5)=f(:,1).*f(:,3);
f(:,6)=f(:,2).*f(:,3);
f(:,7)=f(:,1).*f(:,2).*f(:,3);

effect = data*f/4

% No, design is unreplicated
% No, B has the greatest effect












