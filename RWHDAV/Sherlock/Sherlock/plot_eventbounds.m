

file_list = {...
    'janice_eventbounds_20181022T210101.mat','janice_eventbounds_20181022T210518.mat'};

for f = 1:length(file_list)
    efile = load(file_list{f});
    all_times{f} = etime(efile.output.keytime,efile.output.sync_time);
end

figure(99); clf
for f = 1:length(file_list)
    plot(all_times{f},f*ones(length(all_times{f}),1),'bx','MarkerSize',10,'LineWidth',4); hold on
end
grid on
xlabel('Seconds'); ylabel('Participant');
ylim([0 length(all_times)+1]);
title('Individual participant event boundaries');

