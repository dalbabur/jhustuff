

% Mapping & Navigation Tutorial
% j.chen october 2018
% adapted from:
% https://blogs.mathworks.com/loren/2014/09/06/analyzing-uber-ride-sharing-gps-data/
% data from https://github.com/dima42/uber-gps-analysis

%% step 0: cd to the Navigation directory
% 
% clear all
% close all
% basepath = pwd
% [filepath,dirname] = fileparts(basepath);
% if ~strcmp(dirname,'navigation')
%     fprintf('Your current folder is not Navigation -- make sure you are starting in the correct directory.\n');
% else
%     addpath(basepath);
% end

%% The whole world

% % set colors
% ocean_color = [0.7 0.8 1]; land_color = [0.9 0.9 0.8]; % map colors
% 
% figure(1); clf
% % worldmap REGION or worldmap(REGION) sets up an empty map axes with
% % projection and limits suitable to the part of the world specified in REGION.
% ax = worldmap('World')
% 
% %% plot the coastline
% coastline = load('coast.mat');
% plotm(coastline.lat, coastline.long)
% 
% %% switch between projections
% % https://www.mathworks.com/help/map/projections.html
% % https://xkcd.com/977/
% setm(ax,'MapProjection','ortho')
% % setm(ax,'MapProjection','mercator')
% % setm(ax,'MapProjection','giso')
% % setm(ax,'MapProjection','giso')
% % setm(ax,'MapProjection','pcarree')
% % setm(ax,'MapProjection','eqaazim')
% % setm(ax,'MapProjection','wetch')
% 
% %% plot the land areas, major lakes and rivers, and cities
% setm(ax, 'Origin', [0 180 0])
% land = shaperead('landareas', 'UseGeoCoords', true);
% geoshow(ax, land, 'FaceColor', land_color)
% lakes = shaperead('worldlakes', 'UseGeoCoords', true);
% geoshow(lakes, 'FaceColor', 'blue')
% rivers = shaperead('worldrivers', 'UseGeoCoords', true);
% geoshow(rivers, 'Color', 'blue')
% cities = shaperead('worldcities', 'UseGeoCoords', true);
% geoshow(cities, 'Marker', '.', 'Color', 'red')
% 
% %% plot one country
% figure(2); clf
% % worldmap('Finland')
% % worldmap('Alaska')
% worldmap('United States')
% land = shaperead('landareas', 'UseGeoCoords', true);
% geoshow(land, 'FaceColor', land_color)
% cities = shaperead('worldcities', 'UseGeoCoords', true);
% geoshow(cities, 'Marker', '.', 'Color', 'red')
% 
% 
% %% plot a selected area by latitude and longitude
% figure(2); clf
% latlim = [51 72];
% lonlim = [173 -130];
% worldmap(latlim,lonlim)
% land = shaperead('landareas', 'UseGeoCoords', true);
% geoshow(land, 'FaceColor', land_color)
% rivers = shaperead('worldrivers', 'UseGeoCoords', true);
% geoshow(rivers, 'Color', 'blue')
% cities = shaperead('worldcities', 'UseGeoCoords', true);
% geoshow(cities, 'Marker', 'o', 'Color', [1 0 0])
% 
% 
% %% add a marker
% offset = 0.3;
% geoshow(64.8,-147.7,'DisplayType','Point','Marker','o',...
%     'MarkerSize',8,'MarkerEdgeColor',[1 0 0])
% textm(64.8-offset,-147.7+offset,'Fairbanks')

%% Exercise 0 (in class): make a map showing the place where you grew up
% figure(3); clf
% latlim = [31, 48];
% lonlim = [-12,-1];
% worldmap(latlim,lonlim)
% land = shaperead('landareas', 'UseGeoCoords', true);
% geoshow(land, 'FaceColor', land_color)
% rivers = shaperead('worldrivers', 'UseGeoCoords', true);
% geoshow(rivers, 'Color', 'blue')
% cities = shaperead('worldcities', 'UseGeoCoords', true);
% geoshow(cities, 'Marker', 'o', 'Color', [1 0 0])
% offset = 0.3;
% geoshow(42.2,-8.72,'DisplayType','Point','Marker','o',...
%     'MarkerSize',8,'MarkerEdgeColor',[1 0 0])
% textm(42.2-offset,-8.72+offset,'Vigo')

%% Load the data from San Francisco Uber Rides
% The file contains  GPS logs taken from the mobile apps in Uber
% cars that were actively transporting passengers in San Francisco. The
% data have been anonymized by removing names, trip start and end points.
% The dates were also substituted. Weekdays and time of day are still
% intact.
% 
% For the purpose of this analysis, let's focus on the data captured in the
% city proper and visualize it with the Mapping Toolbox.
load('uber_data_table.mat'); % load the variable T (created with loadUberData.m)

%% Examine the table
T(1:10,:)

% reformat (because I don't like tables)
uId = double(T{:,1});
uTime = T{:,2};
uLat = T{:,3};
uLon = T{:,4};
uYear = T{:,5};
uMonth = T{:,6};
uDay = T{:,7};
uHour = T{:,8};
uMin = T{:,9};
uSec = T{:,10};
uTimeOfDay = T{:,11};
uDayName = T{:,12};
uWeekend = T{:,13};

% how many individual rides?
length(unique(uId))

% how many months?
unique(uMonth)

% how many days?
unique(uDay)

%% Looks like there's a data point every few seconds, but it isn't consistent
[uId(1:100) uMin(1:100) uSec(1:100)]

%% San Francisco
% Overlay the Uber rides (GPS points) on the map. 
ocean_color = [0.7 0.8 1]; land_color = [0.9 0.9 0.8]; % map colors
states = geoshape(shaperead('usastatehi', 'UseGeoCoords', true));
figure(4); clf
latlim = [min(T.Lat) max(T.Lat)]; % boundaries of the rides in the dataset
lonlim = [min(T.Lon) max(T.Lon)];
ax = usamap(latlim, lonlim);
setm(ax, 'FFaceColor', ocean_color)
geoshow(states,'FaceColor',land_color)
geoshow(T.Lat,T.Lon,'DisplayType','Point','Marker','.',...
    'MarkerSize',4,'MarkerEdgeColor',[0 0 1])
title('Uber GPS Log Data')
xlabel('San Francisco')
textm(37.802069,-122.446618,'Marina')
textm(37.808376,-122.426105,'Fishermans Wharf')
textm(37.797322,-122.482409,'Presidio')
textm(37.774546,-122.412329,'SOMA')
textm(37.770731,-122.440481,'Haight')
textm(37.818276,-122.498546,'Golden Gate Bridge')
textm(37.819632,-122.376065,'Bay Bridge')
hold on

%% Plot one ride at a time

% ride_id = 1;
% i = (uId == ride_id);
% figure(4)
% geoshow(uLat(i),uLon(i),'DisplayType','Point','Marker','.',...
%     'MarkerSize',6,'MarkerEdgeColor',[1 0 0])

%% Exercise 1: Identify the 50 longest rides (longest in terms of number of datapoints, not distance)
% plot them on top of all rides; use an assortment of colors
cnt = tabulate(uId);
[~,index] = sort(cnt(:,2),'descend');
top50id = cnt(index(1:50),1);

figure(4);
hold on
for i = 1:50
    index = (uId==top50id(i));
    geoshow(uLat(index),uLon(index),...
        'DisplayType','Point','Marker','.',...
    'MarkerSize',6,'MarkerEdgeColor',[rand rand 0])
end
% bonus question: Identify the 100 longest rides in terms of distance and
% plot them on the map


%% Does the usage change over time?
% Let's start with a basic question - how does the use of Uber service
% change over time. We can use grpstats to
% summarize data grouped by specific categorical values, such as |DayName|
% and |TimeOfDay|, which were added in the data loading process.
%
% Get grouped summaries.
byDay = grpstats(T(:,{'Lat','Lon','DayName'}),'DayName');
byDayTime = grpstats(T(:,{'Lat','Lon','TimeOfDay','DayName'}),...
    {'DayName','TimeOfDay'});

% Reshape the count of entries into a 24x7 matrix.
byDayTimeCount = reshape(byDayTime.GroupCount,24,7)';

% Plot the data by day of week and by hours per day of week.
figure(6)
subplot(2,1,1)
bar(byDay.GroupCount); set(gca,'XTick',1:7,'XTickLabel',cellstr(byDay.DayName));
title('Data points per day')
ylabel('Number of data points')
subplot(2,1,2)
plot(byDayTimeCount'); set(gca,'XTick',1:24); xlabel('Hours by Day of Week');
legend('Mon','Tue','Wed','Thu','Fri','Sat','Sun',...
    'Orientation','Horizontal','Location','SouthOutside')

% It looks like the usage goes up during the weekend (Friday through
% Sunday) and usage peaks in early hours of the day. San Francisco
% has a very active night life!

%% Where do they go during the weekend?
% Is there a way to figure out where people go during the weekend? Even
% though the dataset doesn't contain the actual starting and ending points
% of individual trips, we may still get a sense of how the traffic flows by
% looking at the first and last points of each record. 
%
% We can extract the starting and ending location data for weekend rides.
% Here we load the preprocessed data |startEnd.mat| to save time and plot
% their starting points.
% getStartEndPoints % commented out to save time
load startEnd.mat % load the preprocessed data instead

startEnd(1:10,:)

figure(7); clf
ax = usamap(latlim, lonlim);
setm(ax, 'FFaceColor', ocean_color)
geoshow(states,'FaceColor',land_color)
geoshow(startEnd.StartLat,startEnd.StartLon,'DisplayType','Point',...
    'Marker','.','MarkerSize',5,'MarkerEdgeColor',[1 0 0])
geoshow(startEnd.EndLat,startEnd.EndLon,'DisplayType','Point',...
    'Marker','.','MarkerSize',5,'MarkerEdgeColor',[0 0 1])
title('Uber Weekend Rides - Starting Points')
xlabel('San Francisco')
textm(37.802069,-122.446618,'Marina')
textm(37.808376,-122.426105,'Fishermans Wharf')
textm(37.797322,-122.482409,'Presidio')
textm(37.774546,-122.412329,'SOMA')
textm(37.770731,-122.440481,'Haight')
textm(37.818276,-122.498546,'Golden Gate Bridge')
textm(37.819632,-122.376065,'Bay Bridge')

%% Color by district
% When you plot the longitude and latitude data, you just get messy point
% clouds and it is hard to see what's going on. Instead, I broke the map of
% San Francisco into rectangular blocks to approximate its districts. Here
% is the new plot of starting points by district.

districts = categories(startEnd.StartDist);
cc = hsv(length(districts));

figure(8); clf
ax = usamap(latlim, lonlim);
setm(ax, 'FFaceColor', ocean_color)
geoshow(states,'FaceColor',land_color)
for i = 1:length(districts)
    inDist = startEnd.StartDist == districts(i);
    geoshow(startEnd.StartLat(inDist),startEnd.StartLon(inDist),...
        'DisplayType','Point','Marker','.','MarkerSize',5,'MarkerEdgeColor',cc(i,:))
end
title('Uber Weekend Rides - Starting Points by District')
xlabel('San Francisco')
textm(37.802069,-122.446618,'Marina')
textm(37.808376,-122.426105,'Fishermans Wharf')
textm(37.797322,-122.482409,'Presidio')
textm(37.774546,-122.412329,'SOMA')
textm(37.770731,-122.440481,'Haight')
textm(37.818276,-122.498546,'Golden Gate Bridge')
textm(37.819632,-122.376065,'Bay Bridge')

%% Visualizing the traffic patterns with a network
% This is a step in the right direction. Now that we have the starting and
% ending points grouped by districts, we can represent the rides as
% connections among different districts - this is essentially a graph with
% districts as nodes and rides as edges. 

Edges = zeros(size(startEnd,1),2);
districts = categories(startEnd.StartDist);
for d = 1:length(districts)
    j = (startEnd.StartDist == districts{d});
    Edges(j,1) = d;
    k = (startEnd.EndDist == districts{d});
    Edges(k,2) = d;
end

G = digraph(Edges(:,1), Edges(:,2),[],districts); 
deg = indegree(G);                                  % get node in-degrees

figure(9); clf
edgeC = [.7 .7 .7];                                 % gray color
H = plot(G,'MarkerSize',log(deg).^1.5, ...          % node size in log scale and ^ to adjust sizes
    'NodeCData',deg,...                             % node color by degree
    'EdgeColor',edgeC,'EdgeAlpha',0.3);
% H = plot(G,'MarkerSize',log(deg).^1.4, ...          % node size in log scale
%     'NodeCData',deg,...                             % node color by degree
%     'EdgeColor',edgeC,'EdgeAlpha',0.3,'Layout','force3'); 

% To see a version made in Gephi,
% https://blogs.mathworks.com/images/loren/2014/uber_graph.pdf
% * The size of the district nodes represents their in-degrees, the
% number of incoming connections, and you can think of it as measure of
% popularity as destinations. SOMA, Haight, Mission District, Downtown, and
% The Castro are the popular locations based on this measure.
% * In the Gephi plot, the districts are colored based on their modularity, which
% basically means which cluster of nodes they belong to. It looks like
% people hang around set of districts that are nearby - SOMA, Downtown,
% Mission District are all located towards the south (green). The Castro,
% Haight, Western Addition in the center (purple) and it is strongly
% connected to Richmond and Sunset District in the west. Since those are
% residential areas, it seems people from those areas hang out in the other
% districts in the same cluster. 
% * The locals don't seem to go to Fisherman's Wharf or Chinatown in the
% north (red) very much - they are probably considered not cool because of
% tourists?

%% you can explore more by time slicing the data to see
% how the traffic pattern changes based on the time of day or day of the
% week. You may be able to find traffic congestions by calculating the
% speed using the timestamps. 




