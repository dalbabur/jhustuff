%% Starting and ending points of the records
% The dataset doesn't contain the actual starting and ending points of
% actual individual trips, but we can at least get the first and last
% points recorded in the dataset. 

% load variable |T| if it is not in the workspace
if ~ismember('T',who)
    loadData
end

% get the min max of the time per id
timeMinMax = grpstats(T(T.Weekend,{'Id','Time'}),{'Id'},{'min','max'});

% initialize variables
Id = zeros(height(timeMinMax),1); 
StartTime = zeros(height(timeMinMax),1); 
EndTime = zeros(height(timeMinMax),1); 
StartLat = zeros(height(timeMinMax),1); 
StartLon = zeros(height(timeMinMax),1); 
EndLat = zeros(height(timeMinMax),1); 
EndLon = zeros(height(timeMinMax),1);

% get the first and last locations for each id
for i = 1:height(timeMinMax)
    curId = timeMinMax.Id(i);
    curStartTime = timeMinMax.min_Time(i);
    curEndTime = timeMinMax.max_Time(i);
    curStartLat = T.Lat(T.Id == curId & T.Time == curStartTime);
    curStartLon = T.Lon(T.Id == curId & T.Time == curStartTime);
    curEndLat = T.Lat(T.Id == curId & T.Time == curEndTime);
    curEndLon = T.Lon(T.Id == curId & T.Time == curEndTime);

    Id(i) = curId; 
    StartTime(i) = curStartTime; 
    EndTime(i) = curEndTime; 
    StartLat(i) = curStartLat(1); % there could be duplicate entries
    StartLon(i) = curStartLon(1); % there could be duplicate entries
    EndLat(i) = curEndLat(end); % there could be duplicate entries
    EndLon(i) = curEndLon(end); % there could be duplicate entries
end

% create a new table
startEnd = table(Id,StartTime,EndTime,StartLat,StartLon,EndLat,EndLon);

% add time vector variables
startTimeVec = array2table(datevec(startEnd.StartTime),'VariableNames',...
    {'Year','Month','Day','Hour','Min','Sec'});

% append the new variables
startEnd = [startEnd startTimeVec];

clearvars -except T startEnd

%% Adding district labels
% We still have a problem with this list of first and last points of
% individual rides - there are too many records in the dataset and points 
% just form a messy cloud that is hard to interpret. Instead, categorize
% the data points by districts. Let's load the grid that approximate San
% Francisco districts. 

% Load the geo locations of districts
dist = readtable('districts.xlsx');

% Check if the dataset contains |StartDist| and |EndDist| variables 
if sum(ismember({'StartDist','EndDist'},startEnd.Properties.VariableNames)) ~= 2
    
    % initialize accumulators
    StartDist = cell(height(startEnd),1);
    EndDist = cell(height(startEnd),1);
    
    % loop over each district
    for i = 1:height(dist)
        % get the geo boundaries
        n = dist.North(i); s = dist.South(i); e = dist.East(i); w = dist.West(i);
        % select only points that lie inside the rectangle
        inDist = startEnd.StartLon >= w & startEnd.StartLon <= e;
        inDist = inDist & startEnd.StartLat >= s & startEnd.StartLat <= n;
        % assign the district name of the starting point as the label
        StartDist(inDist) = dist.District(i);
        % assign the district name of the ending point as the label
        inDist = startEnd.EndLon >= w & startEnd.EndLon <= e;
        inDist = inDist & startEnd.EndLat >= s & startEnd.EndLat <= n;
        EndDist(inDist) = dist.District(i);
    end

    % if no district name is assigned, apply |Other|
    StartDist(cellfun('isempty',StartDist)) = {'Other'};
    EndDist(cellfun('isempty',EndDist)) = {'Other'};
    % append the starting and ending districts as variables
    startEnd.StartDist = categorical(StartDist);
    startEnd.EndDist = categorical(EndDist);

    clearvars e EndDist i inDist n s StartDist w

end

clearvars cc e i inDist n s w
