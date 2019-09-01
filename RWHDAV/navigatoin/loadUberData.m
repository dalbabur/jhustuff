% initialize
clearvars;close all;clc;
%load data
T = readtable('uber.tsv','Delimiter','tab','FileType','text','ReadVariableNames',false);
T.Properties.VariableNames = {'Id','Time','Lat','Lon'};
T.Id = categorical(T.Id);

% Limit the geography to San Francicso
T(T.Lat < 37.7 | T.Lat > 37.85,:) = [];
T(T.Lon > -122.25,:) = [];

% convert time from text to serial numbers
T.Time = datenum(T.Time, 'YYYY-mm-ddTHH:MM:SS+00:00');
% add additional columns to the table for each time unit
T = [T array2table(datevec(T.Time),'VariableNames',...
    {'Year','Month','Day','Hour','Min','Sec'})];

% generate labels for 24 hours
labels = cell(1,24);
for i = 0:23
    labels{i+1} = sprintf('%02d:00',i);
end
% convert time serial numbers to a categorical data type
T.TimeOfDay = categorical(T.Hour,0:23,labels);

% add the day of week as a categorical variable
[~,DayName] = weekday(T.Time);
DayName = cellstr(DayName);
DayLabel = {'Mon','Tue','Wed','Thu','Fri','Sat','Sun'};
T.DayName = categorical(DayName,DayLabel);

% add a binary variable to indicate whether the ride took place in weekend or not
T.Weekend = ismember(T.DayName,{'Fri','Sat','Sun'});

clearvars i DayName DayLabel labels