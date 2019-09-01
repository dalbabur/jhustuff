
% j.chen september 2018
% adapted from:
% https://livefreeordichotomize.com/2017/12/27/a-year-as-told-by-fitbit/
% data from nick strayer 

%% step 0: cd to the Health directory

clear all
close all
basepath = pwd
[filepath,dirname] = fileparts(basepath);
if ~strcmp(dirname,'fitbit_tutorial')
    fprintf('Your current folder is not fitbit_tutorial -- make sure you are starting in the correct directory.\n');
else
    addpath(basepath);
end
% helper functions: https://www.dropbox.com/sh/yowqme68b0659jk/AAByvh--d64PfYj4oFACHVTOa?dl=0

%% datafile names

filenames = {'my_fitbit_data_jan-feb.csv','my_fitbit_data_march-april.csv','my_fitbit_data_may-june.csv',...
    'my_fitbit_data_july-aug.csv','my_fitbit_data_sep-oct.csv','my_fitbit_data_nov-dec.csv'};

%% load text data
fprintf('Loading text data.... ');
fitdata = [];
data = readtable(fullfile(basepath,'fitbit_year',filenames{1})); fitdata = vertcat(fitdata,data);
data = readtable(fullfile(basepath,'fitbit_year',filenames{2})); fitdata = vertcat(fitdata,data);
data = readtable(fullfile(basepath,'fitbit_year',filenames{3})); fitdata = vertcat(fitdata,data);
data = readtable(fullfile(basepath,'fitbit_year',filenames{4})); fitdata = vertcat(fitdata,data);
data = readtable(fullfile(basepath,'fitbit_year',filenames{5})); fitdata = vertcat(fitdata,data);
data = readtable(fullfile(basepath,'fitbit_year',filenames{6})); fitdata = vertcat(fitdata,data);
clear data
fitdata(1:10,:) % display the table
unique(fitdata.type) % there are two types: 'heart rate' and 'steps'

% let's put the heart rate and steps data into separate variables
hr_idx = strmatch('heart rate',fitdata.type);
hr_value = fitdata.value(hr_idx);
hr_time = fitdata.time(hr_idx); % this is in seconds, 1 row per minute
hr_date = fitdata.date(hr_idx);
steps_idx = strmatch('steps',fitdata.type);
steps_value = fitdata.value(steps_idx);
steps_time = fitdata.time(steps_idx);
steps_date = fitdata.date(steps_idx);
clear fitdata

whos
% note the length of hr_* and steps*

%% basic descriptive stats

mean(hr_value) % mean heart rate
mean(steps_value) % mean step count per minute

figure(1); clf
subplot(1,3,1) % select subplot to plot to next
histogram(hr_value); grid on
title('heart rate'); xlabel('value [per minute]'); ylabel('count');

subplot(1,3,2)
histogram(steps_value,'BinWidth',1); grid on; hold on
title('steps per minute'); xlabel('value [per minute]'); ylabel('count');
[bin_counts,bin_edges] = histcounts(steps_value,'BinWidth',1);

% where are the peaks of the histogram?
sel = 300; % sel: The amount above surrounding data for a peak to be; Larger values mean
%           the algorithm is more selective in finding peaks.
[peakLoc, peakMag] = peakfinder(bin_counts,sel); 
plot(peakLoc,peakMag,'ro');

subplot(1,3,3)
y = histogram(steps_value,'BinWidth',1); 
grid on; hold on
title('steps per minute (zoomed in)'); xlabel('value [per minute]'); ylabel('count');
ylim([0 3050]); % zoom in on this histogram
plot(peakLoc,peakMag,'ro');
text(peakLoc(3)+4,peakMag(3),['walking pace (' num2str(peakLoc(3)) ')']); % +4 moves the text to the right a little bit
text(peakLoc(4)+4,peakMag(4),['running pace (' num2str(peakLoc(4)) ')']);
text(peakLoc(2)+4,peakMag(2),['walking across the room? (' num2str(peakLoc(2)) ')']);

all_hr_days = unique(hr_date); length(all_hr_days)
% if you loaded all of the csv files, there should be 358 days.

all_steps_days = unique(steps_date); length(all_steps_days)
% if you loaded all of the csv files, there should be 360 days.

% uh-oh, they don't match -- there is some missing data.

%% missing data?

% hr measurements are 1 per minute, and there are 60*24=1440 minutes in a day
% thus theoretically we can reshape the hr_value vector into day x minute
%    hr_day_x_minute = reshape(hr_value,[],1440);
% but this doesn't work- we get an error. are there missing times?

figure(2); clf
plot(hr_time(1:4000),'k.'); title('hr-time'); xlabel('index in array'); ylabel('value in array');
% yes, looks like some timestamps are missing (gaps and bends in the lines)
% nick mentions this in his blog; sometimes he took the fitbit off
% and since HR and Steps don't match, the fitbit must have also dropped some measurements unpredictably

%% also, the data are not in chronological order

% hr_date values are "datetime" class, which means you can use some special
% syntax to see different versions of the date; type "help datetime" to read about them
hr_date.Day(1:5)
hr_date.Month(1:5)
hr_date.Day(1440:1445)
hr_date.Month(1440:1445)

figure(3); 
subplot(2,1,1)
plot(hr_date.Day,'r'); hold on
plot(hr_date.Month,'b','LineWidth',2)
title('Order of Months and Days in hr-date')
xlabel('index in array'); ylabel('value in array');
subplot(2,1,2)
plot(steps_date.Day,'r'); hold on
plot(steps_date.Month,'b','LineWidth',2)
title('Order of Months and Days in steps-date')
xlabel('index in array'); ylabel('value in array');

% looks like each csv file was in reverse chronological order by day, but
% forward order by minute (see figure 2)

%% reformat the heart rate and steps data
% we will use the Time and Date values to align the Heart Rate and Steps
% data to each other,
% and put everything in chronological order.
% load one csv file at a time; this section could take around 5-10 minutes
% we want to build a num_days x 1440 array (rows=days, cols=minutes) of heart-rate-per-minute values
% and a num_days x 1440 array (rows=days, cols=minutes) of steps-per-minute values
%
% challenge question (optional): can you improve the efficiency of this section, eg
% eliminate some of the loops?

if 0 % set this to 1 in order to run the cell
    
clearvars -except basepath filenames

minute_timestamps = [0:60:1439*60]';
hr_day_x_minute = []; steps_day_x_minute = []; 

for f = 1:length(filenames)
    filepath = fullfile(basepath,'fitbit_year',filenames{f});
    [month_hr_value,month_hr_time,month_hr_date,month_steps_value,month_steps_time,month_steps_date] = read_fitbit_csv(filepath);
    month_days = union(month_hr_date,month_steps_date); % all unique dates in both HR and Steps data
    month_hr_day_x_minute = nan(length(month_days),length(minute_timestamps)); % create array filled with Nan (overwriting previous)
    month_steps_day_x_minute = nan(length(month_days),length(minute_timestamps)); % create array filled with Nan (overwriting previous)
    for d = 1:length(month_days)
        curr_date = month_days(d)
        for m = 1:length(minute_timestamps)
            curr_minute = minute_timestamps(m);
            j = (month_hr_time==curr_minute)&(month_hr_date==curr_date);
            if sum(j)>0
                month_hr_day_x_minute(d,m) = month_hr_value(j);
            end
            j = (month_steps_time==curr_minute)&(month_steps_date==curr_date);
            if sum(j)>0
                month_steps_day_x_minute(d,m) = month_steps_value(j);
            end
        end
    end
    hr_day_x_minute = [hr_day_x_minute; month_hr_day_x_minute]; % concatenate the current month data onto the existing HR array
    steps_day_x_minute = [steps_day_x_minute; month_steps_day_x_minute]; % concatenate the current month data onto the existing Steps array
end

save('hr_data.mat','hr_day_x_minute');
save('steps_data.mat','steps_day_x_minute');

% this could have been part of the loop above, but i added it later
all_dates = [];
for f = 1:length(filenames)
    filepath = fullfile(basepath,'fitbit_year',filenames{f});
    [month_hr_value,month_hr_time,month_hr_date,month_steps_value,month_steps_time,month_steps_date] = read_fitbit_csv(filepath);
    all_dates = [all_dates; union(month_hr_date,month_steps_date)]; % all unique dates in both HR and Steps data
end
save('all_dates.mat','all_dates');

end

%% load .mat data (calculated and saved in the previous section)

clearvars -except basepath filenames
load('hr_data.mat','hr_day_x_minute');
load('steps_data.mat','steps_day_x_minute');
load('all_dates.mat','all_dates');
figure(4); clf

subplot(1,3,1)
imagesc(hr_day_x_minute); colorbar
colormap hot
title('heart rate'); xlabel('minute'); ylabel('day');

subplot(1,3,2)
imagesc(steps_day_x_minute); colorbar
title('steps per minute'); xlabel('minute'); ylabel('day');

% let's also look at where there were missing values
subplot(1,3,3)

% choose one of these to plot
missing_values = isnan(hr_day_x_minute); tstr = 'HR missing values'; % there's quite a bit of missing hr data
% missing_values = isnan(steps_day_x_minute); tstr = 'steps missing values'; % but not much missing step data

imagesc(missing_values); colorbar
title(tstr); xlabel('minute'); ylabel('day');
% a stripe of missing data seems to fall near the start of each day.
% maybe the transition from sleep to wake causes fitbit to need to recalibrate its HR estimation?

%% fill in the missing data
% fill empty cells with the mean
% interpolation would be better, but this is ok
% challenge question: fill empty cells by interpolation instead

hr_missing_values = isnan(hr_day_x_minute);
hr_day_x_minute(hr_missing_values) = nanmean(hr_day_x_minute(:)); % the (:) notation turns the 2d array into 1d
steps_missing_values = isnan(steps_day_x_minute);
steps_day_x_minute(steps_missing_values) = nanmean(steps_day_x_minute(:));

figure(5); clf
subplot(1,2,1)
imagesc(hr_day_x_minute); colorbar
colormap hot
title('heart rate'); xlabel('minute'); ylabel('day');
subplot(1,2,2)
imagesc(steps_day_x_minute); colorbar
title('steps'); xlabel('minute'); ylabel('day');

% challenge question (optional):
% estimate nick's bedtime based on when steps stop and heart rate drops at night. does bedtime
% change over time as wakeup time changes?

% challenge question (optional):
% does he have "social jetlag"? ie, does higher variability of weekend vs
% weekday wakeup/bedtime in a given month predict less sleep hours overall?

%% days x days correlation matrix

hr_corrmat_days = corr(hr_day_x_minute'); % transpose the matrix
figure(6); clf
imagesc(hr_corrmat_days); ch = colorbar; ch.Label.String = 'pearson correlation';
title('days x days correlation matrix of HR')
xlabel('day'); ylabel('day');

steps_corrmat_days = corr(steps_day_x_minute'); % transpose the matrix
figure(7); clf
imagesc(steps_corrmat_days); ch = colorbar; ch.Label.String = 'pearson correlation';
title('days x days correlation matrix of steps')
xlabel('day'); ylabel('day');

% zoom in to look at 1 example week
figure(8); clf
imagesc(hr_corrmat_days(345:351,345:351)); ch = colorbar; ch.Label.String = 'pearson correlation';
title('days x days correlation matrix of HR: one example week')
xlabel('day'); ylabel('day');

%% the average week (homework exercise)

% calculate nick's average heart rate and step timecourse for each day of the week
% first average together all the timecourses for each day, eg for monday
% then calculate the correlations between days
% note: this can be done in around 8 lines of code
% you'll need this function:
dayofweek = weekday(all_dates); % values 1-7

avg_day_hr = zeros(7,1440);
avg_day_steps = zeros(7,1440);
for i = 1:7
    avg_day_hr(i,:) = mean(hr_day_x_minute((dayofweek==i),:),1);
    avg_day_steps(i,:) = mean(steps_day_x_minute((dayofweek==i),:),1);
end

week_corr_hr = corr(avg_day_hr');
week_corr_steps = corr(avg_day_steps');

% plot the average heart rate and step timecourse for each day of the week (make a figure 9 with 2 subplots)
% note: these are all plotting commands, no new calculations needed
% you'll need these labels:
daynames = {'sun','mon','tue','wed','thu','fri','sat'};

figure(9); clf
subplot(1,2,1)
plot(avg_day_hr')
legend(daynames)
title('Heart rate timecourse for each day of the week')
xlabel('Minute of the Day')
ylabel('Average Heart Rate')
subplot(1,2,2)
plot(avg_day_steps')
legend(daynames)
title('Steps-per-minute timecourse for each day of the week')
xlabel('Minutes of the Day')
ylabel('Average Steps per Minute')

% calculate and plot the average week correlation matrix for heart rate and for steps (make a figure 10 with 2 subplots)
% note: make use of the timecourses you generated above!
% after plotting the correlation matrix, you'll need this command:


figure(10); clf
subplot(1,2,1)
imagesc(week_corr_hr)
ch = colorbar; ch.Label.String = 'pearson correlation';
title('days x days correlation matrix of HR')
xlabel('day'); ylabel('day');

subplot(1,2,2)
imagesc(week_corr_steps)
ch = colorbar; ch.Label.String = 'pearson correlation';
title('days x days correlation matrix of steps')
xlabel('day'); ylabel('day');

% challenge question (optional):
% each day-timecourse plotted above was made by averaging together many
% individual days. the variation across these individual days is important too.
% use this variation to put error bars on the mean timecourses (standard
% deviation or standard error).

%% minutes x minutes correlation matrix
% which minutes resemble other minutes?

hr_corrmat_minutes = corr(hr_day_x_minute); % corr calculates pearson correlation using columns
figure(11)
imagesc(hr_corrmat_minutes); ch = colorbar; ch.Label.String = 'pearson correlation';
title('minutes x minutes correlation matrix of HR')
xlabel('minute'); ylabel('minute');

steps_corrmat_minutes = corr(steps_day_x_minute); % corr calculates pearson correlation using columns
figure(12)
imagesc(steps_corrmat_minutes); ch = colorbar; ch.Label.String = 'pearson correlation';
title('minutes x minutes correlation matrix of steps')
xlabel('minute'); ylabel('minute');

% challenge question (optional):
% use kmeans clustering to identify blocks of activity throughout the day
% k=6 is probably a good place to start
%  idx = kmeans(hr_corrmat_minutes, 6);
% plot a new matrix of the same size showing where the clusters are

idx = kmeans(hr_corrmat_minutes, 6);
groups = zeros(1440,1440);
for i = 1:1440
    for j = 1:1440
        if idx(i) == idx(j)
            groups(j,i) = idx(i);
        else
            groups(j,i) = 0;
        end
    end
end
figure
subplot(1,2,1)
imagesc(hr_corrmat_minutes);
subplot(1,2,2)
imagesc(groups)



%% scatter plot of heart rate vs. steps per minute

figure(90); clf
plot(hr_day_x_minute(1:180,:),steps_day_x_minute(1:180,:),'rx'); hold on % 1st half of year
plot(hr_day_x_minute(181:360,:),steps_day_x_minute(181:360,:),'co'); hold on % 2nd half of year
title('scatter plot of steps per minute vs. heart rate');
set(gca,'FontSize',16);
xlabel('heart rate'); ylabel('steps per minute'); grid on
text(125,175,'Running','FontSize',18)

% in second half of the year, his heart rate is higher during running.
% is this evidence that his heart health improved?

% challenge question (optional):
% investigate how his heart rate during running changes over the course of
% the year, eg by month. does it increase steadily, or is there a u-shaped
% effect, which might suggest a seasonal influence?





















