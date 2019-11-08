% s1 = fitcA(:,1) >= 400 & fitcA(:,1)<=700;
% s2 = fitcE(:,1) >= 400 & fitcE(:,1)<=700;
% s3 = rbA(:,1) >= 400 & rbA(:,1)<=700;
% s4 = rbE(:,1) >= 400 & rbE(:,1)<=700;
% 
% fitcA=[fitcA(:,1).*s1 fitcA(:,2).*s1];
% fitcE=[fitcE(:,1).*s2 fitcE(:,2).*s2];
% rbA=[rbA(:,1).*s3 rbA(:,2).*s3];
% rbE=[rbE(:,1).*s4 rbE(:,2).*s4];
% 
% fitcA(fitcA == 0) = [];
% fitcE(fitcE == 0) = [];
% rbA(rbA == 0) = [];
% rbE(rbE == 0) = [];
% 
% fitcAA = reshape(fitcA,length(fitcA)/2,2);
% rbAA = reshape(rbA,length(rbA)/2,2);
% rbEE = reshape(rbE,length(rbE)/2,2);
% 
% fitcAA(end,:) = [];
% fitcE(end,:) = [];
% rbAA(end,:) = [];
% rbEE(end,:) = [];
% 
% 
% 
% 
% fitcAA = reshape(fitcAA,length(fitcAA)/24,48);
% fitcEE = reshape(fitcE,length(fitcE)/24,48);
% rbAA = reshape(rbAA,length(rbAA)/24,48);
% rbEE = reshape(rbEE,length(rbEE)/24,48);
% 

for i = 1:4
    plotData(:,:,i) = reshape(all(:,i),length(all)/24,24);
end

set(gca,'colororder',colors)
hold on

for i = 1:4
    for j = 1:24
        plot(plotX(:,j),plotData(:,j,i),'.','MarkerSize',20)
    end
end
ylim([0 1])