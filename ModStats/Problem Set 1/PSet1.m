%% 540.305 Problem Set 1: Matlab Introduction - Diego Alba

% Script will ask for some input and display all answers in the comand
% window

clear
clc

%% 1 Calculations with Matlab

disp('Calculations with Matlab')
% Part 1
% a
disp(['Part 1, (a) : ',...
    num2str(15*(10^0.5+3.7^(2))/(log10(1365)+1.9))])
% b
disp(['Part 1, (b) : '...
    num2str(2.5^3*(16-216/22)/(1.7^4+14) + 2050^0.25)])

% Part 2
x=8.3;
y=2.4;
% a
disp(['Part 2, (a) : ',...
    num2str(x^2+y^2-x^2/y^2)])
% b
disp(['Part 2, (b) : '...
    num2str((x*y)^0.5-(x+y)^0.5+((x-y)/(x-2*y))^2-(x/y)^0.5)])

% Part 3
x=deg2rad(12);
logic = {'False','True'};
% a
disp(['Part 3, (a) : ',...
    logic{1+(tan(4*x)==(4*tan(x)-4*tan(x)^3)/(1-6*tan(x)^2+tan(x)^4))}])
% b
disp(['Part 3, (b) : ',...
    logic{1+(sin(x)^3==(3*sin(x)-sin(3*x))/4)}])

% Part 4
disp(['Part 4: ',...
    num2str(2*pi*3*401*(100-20)/log(5/3)),' Watts'])
%----------------------------------------------------------

%% 2 Finding a Function

disp('Finding a Function')
% a
disp('(a): round(X,N), round(12.45,0) = 12')
% b
disp('(b): isprime(X), isprime(12) = 0')
% c
disp('(c): clc')
% d 
disp('(d): date, date = 09-Sep-2017')
%----------------------------------------------------------

%% 3 Whish is which?

disp('Which is which?')
% a
disp('(a): for, while, if')
% b
x = input('Enter first number to compare: ');
y = input('Enter second number to compare: ');

if x>y
    prompt='1';
else
    prompt='0';
end

disp(['(b),(i): X = ',num2str(x),' , Y = ', num2str(y),' so: ', prompt])

x = input('Enter a number: ');
sums = 0;
while x>0
    sums = sums+x;
    x = x-1;
end
disp(['(b),(ii): sum = ',num2str(sums)])

x = input('Enter a number: ');
sums = 0;
for j = 1:x
    sums = sums + j;
    if sums > x
        break
    end
end
disp(['(b),(iii): sum = ',num2str(sums)])
%----------------------------------------------------------

%% 4 Temperature conversion

disp('Temperature conversion')
disp('Code on aseparate file')
disp('Fahrenheit temperature: 97')
FtoK(97);
%----------------------------------------------------------

%% 5 Financial Planning

disp('Financial Planing')
% a
disp(['Money = $',num2str(1000*1.07^25)])
% b
money = 0;
for j = 1:40
    money = (money+1000)*1.07;
end
disp(['Money = $', num2str(money)])
% c
moneyA = 0;
for j = 1:10
    moneyA = (moneyA+1000)*1.07;
end
moneyA = round(moneyA*1.07^30,2);
moneyB = 30*1000;
disp(['MoneyA = $', num2str(moneyA),' & MoneyB = $', num2str(moneyB)])
% d
money = [5000000,5000000];
ind = rem((1:20)/5,1)==0;
for j = 1:length(ind)
    money(1) = money(1) - 200000;
    if j>1 && ind(j-1) == 0
        money(2) = money(2) - 250000;
    end
    if ind(j) == 1
        money = money*0.96;
    else
        money = money*1.1;
    end
end
money = round(money,2);
disp(['MoneyA = $', num2str(money(1)),' & MoneyB = $', num2str(money(2))])
%----------------------------------------------------------

%% 6 A script for mass balances

disp('A script for mass balances')
disp('Code on a separate file')
disp('10 L of water and streptomycin in.')
StrepOutputConvert(10,10);
%----------------------------------------------------------

%% 7 Coding (and debugging!)

disp('Coding (and debugging)')
disp('Code on a separate file')
%----------------------------------------------------------

clear







