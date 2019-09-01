%% Confidence Intervals for Nanotube growth

filename = 'nanotube_lengths(1).xlsx';
data =  xlsread(filename, 'B2:I194');

n = length(data)-sum(isnan(data));
mean = nanmean(data);
SEM = nanstd(data)./sqrt(n);
conf = [0.68 0.95 0.99];
z = -norminv((1-conf)/2);
err=z'*SEM;

figure
for i = 1:3
    subplot(1,3,i)
    errorbar([1 2 3 4 5 10 25 50],mean,err(i,:))
    xlim([0 52])
    title(['Confidence of ',num2str(conf(i))])
    xlabel('time (hr)')
    ylabel('length (microns)')
end

%% Hypothesis Testing for Nanotube growth

% a) The average length of a nanotube at 10 hours is at least 2 microns.
%  H_null: mu > 2
% b) The average length of a nanotube at 10 hours is at least 2.5 microns.
%  H_null: mu > 2.5
% c) The average length of a nanotube at 10 hours is less than 3 microns.
%  H_null: mu <= 3
% d) The average length of a nanotube at 10 hours is between 2.25 and 2.75 microns.
%  H_null: mu <= 2.25 and mu >= 2.75


mus = [2 2.5 3 2.25 2.75];
zscore = (mean(6)-mus)/(SEM(6)*sqrt(n(6)));
confidence = (1-normcdf(-zscore))*100

