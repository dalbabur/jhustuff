
function [JSD12,JSD13,JSD23] = JSD()

load('data.mat','test1','test2','test3');

% test1 = test1 - ones(length(test1),1)*nanmean(test1);
% test2 = test2 - ones(length(test2),1)*nanmean(test2);
% test3 = test3 - ones(length(test3),1)*nanmean(test3);

JSD12 = NaN(1,2);
JSD13 = NaN(1,2);
JSD23 = NaN(1,2);

% Plot Data
figure;plot(test1(:,1),test1(:,2),'ro');
hold on;
plot(test2(:,1),test2(:,2),'bo');
plot(test3(:,1),test3(:,2),'go');

% Establish bin boundaries

alldata = [test1;test2;test3];
Xedges = nanmin(alldata(:,1)):50:nanmax(alldata(:,1));
Yedges = nanmin(alldata(:,2)):50:nanmax(alldata(:,2));


% Calculate P distribution for each dataset

N1 = histcounts2(test1(:,1),test1(:,2),Xedges,Yedges);
N2 = histcounts2(test2(:,1),test2(:,2),Xedges,Yedges);
N3 = histcounts2(test3(:,1),test3(:,2),Xedges,Yedges);

P1 = N1(:)/length(test1);
P2 = N2(:)/length(test2);
P3 = N3(:)/length(test3);

% Mixtures

M12 = 0.5*(P1 + P2);
M13 = 0.5*(P1 + P3);
M23 = 0.5*(P2 + P3);

% JSD

JSD12(1) = 0.5*KLD(P1,M12) + 0.5*KLD(P2,M12);
JSD13(1) = 0.5*KLD(P1,M13) + 0.5*KLD(P3,M13);
JSD23(1) = 0.5*KLD(P2,M23) + 0.5*KLD(P3,M23);

% Freedman?Diaconis rule

for m=1:3
    if m==1
        d1 = test1;
        d2 = test2;
    elseif m==2
        d1 = test1;
        d2 = test3;
    elseif m==3
        d1 = test2;
        d2 = test3;
    end
    IQR = IQRcalc([d1;d2]);
    binsize = 2*IQR/nthroot(length([d1;d2]),3);
    Xedges = nanmin(alldata(:,1)):binsize(1):nanmax(alldata(:,1));
    Yedges = nanmin(alldata(:,2)):binsize(2):nanmax(alldata(:,2));
    figure;
    plot(d1(:,1),d1(:,2),'ro');
    hold on;
    plot(d2(:,1),d2(:,2),'bo');
    set(gca,'XTick',Xedges,'YTick',Yedges,'Layer','top');
    grid on
    N1 = histcounts2(d1(:,1),d1(:,2),Xedges,Yedges);
    N2 = histcounts2(d2(:,1),d2(:,2),Xedges,Yedges);
    P1 = N1(:)/length(d1);
    P2 = N2(:)/length(d2);
    M = 0.5*(P1 + P2);
    
    if m==1
        JSD12(2) = 0.5*KLD(P1,M) + 0.5*KLD(P2,M);
    elseif m==2
        JSD13(2) = 0.5*KLD(P1,M) + 0.5*KLD(P2,M);
    elseif m==3
        JSD23(2) = 0.5*KLD(P1,M) + 0.5*KLD(P2,M);
    end
end


end

function divergence = KLD(P,Q)

divergence = nansum(P.*log2(P./Q));

end

function IQR = IQRcalc(data)

data = sort(data);

data(isnan(data(:,1)),:) = [];
data(isnan(data(:,2)),:) = [];

d = length(data);

if rem(d,2)
    n = (d-1)/2;
else
    n = d/2;
end

Q1 = median(data(1:n,:));
Q3 = median(data(n:end,:));

IQR = Q3-Q1;

end