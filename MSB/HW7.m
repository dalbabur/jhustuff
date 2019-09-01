% Diego Alba MSB HW7

GT = zeros(11,18);

GT(1,1:3) = [1 -1 -1];
GT(2,[2 4 5]) = [1 -1 -1];
GT(3,[4 14 6 13]) = [1 -1 -1 -1];
GT(4,[6 17 7]) = [1 -1 -1];
GT(5,[7 12 18 8]) = [1 -1 -1 -1];
GT(6,[8 9 15]) = [1 -1 -1];
GT(7,[9 12 10]) = [1 1 -1];
GT(8,[10 13 11]) = [1 1 -1];
GT(9,[12 13]) = [1 -1];
GT(10,[5 11 6]) = [1 1 -1];
GT(11,[5 4 16 9 8]) = [-1 1 1 1 1];
masterGT = GT;

D = [0.03, 0.048];
m = [1 3 15 16 17 18];
V = [[5.17 0.578 0.353 8.33 1.61 0.334];...
    [7 1.28 0.725 12.9 0.922 0.286]]/10^4;

Vmodel = [12 5 9];
Vc = zeros(6,11);
k=0;
for i = 1:2 % D
    for j = 1:3 % model
        k = k+1;
        M = [m Vmodel(j)];
        Vm = [V(i,:) 0];
        
        GTm = masterGT(:,M);
        GT(:,M)=[];
        GTc = GT;
        
        Vc(k,:) = -GTc^-1*GTm*Vm';
        GT = masterGT;
    end
end

DilutionRate = repmat(D',3,1);
Model = repmat([1,2,3]',2,1);
V =array2table(Vc);
results = [table(DilutionRate,Model),V(:,1:3)];
disp(results)
disp('\n')
results = [table(DilutionRate,Model),V(:,4:6)];
disp(results)
disp('\n')
results = [table(DilutionRate,Model),V(:,7:9)];
disp(results)
disp('\n')
results = [table(DilutionRate,Model),V(:,10:11)];
disp(results)