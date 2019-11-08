warning('off','all')
At = 4.12118;
Bt = 1202.942;
Ct = -46.818;
Aw = 6.20963; 
Bw = 2354.731;
Cw = 7.559;

alpha = 3.0216;
beta = 1.9436;

P2 = 1.01325; % bar

syms T
Pt = 10.^(At-Bt./(T+Ct));
Pw = 10.^(Aw-Bw./(T+Cw));
Tx = [];
y = [];

tic
for i = linspace(0,1,100);
    xTHF = i;
    xW = 1 - xTHF;
    gammaTHF = exp(alpha./(1+alpha.*xTHF./beta./xW).^2);
    gammaW = exp(beta./(1+beta.*xW./alpha./xTHF).^2);
    Tx = [Tx eval(solve(xTHF ==(-Pw.*gammaW+P2)./(Pt.*gammaTHF-Pw.*gammaW),T))];
    y = [y (10.^(At-Bt./(Tx(end)+Ct)).*gammaTHF.*xTHF./P2)];
end
toc
warning('on','all')

figure
plot(linspace(0,1,100),Tx,y,Tx)