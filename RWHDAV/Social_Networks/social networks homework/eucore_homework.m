
% j.chen september 2018
% data from:
% https://snap.stanford.edu/data/email-Eu-core.html

%% step 0: cd to the Social_Networks directory

clear all
close all
basepath = pwd
[filepath,dirname] = fileparts(basepath);
if ~strcmp(dirname,'social networks homework')
    fprintf('Your current folder is not Social_Networks -- make sure you are starting in the correct directory.\n');
else
    addpath(basepath);
end

%% load data from CSV files

fid1 = fopen('email-Eu-core-department-labels.txt','r'); % node labels
fid1_data = textscan(fid1,'%d%s','Delimiter',' ');
fclose(fid1);
Vertices = fid1_data{1};
Dept_Names = fid1_data{2};
for i = 1:length(Dept_Names)
    Dept_Num(i) = str2num(Dept_Names{i});
end

fid2 = fopen('email-Eu-core.txt','r'); % edges
fid2_data = textscan(fid2,'%d%d','Delimiter',' ');
fclose(fid2);
Edges(:,1) = fid2_data{1};
Edges(:,2) = fid2_data{2};
Edges = double(Edges)+1; % originally zero-indexed; add 1 to all values because MATLAB wants all positive values
Dept_Num = Dept_Num+1;

G = digraph(Edges(:,1), Edges(:,2),'OmitSelfLoops'); % create a directed graph from edges

%% Exercise 1: Find unconnected nodes and remove them
% unconnected nodes have in- and out-degree of zero
% use rmnode to remove them from G
% also remove them from Dept_Num!

noIN = find(indegree(G) == 0);   
noOUT = find(outdegree(G) == 0);
delete = intersect(noIN,noOUT);
G = rmnode(G, delete);
Dept_Num(delete)=[];
Dept_Names(delete)=[];


%% Exercise 2: Look at the histogram of Department ?????????????

figure(1); clf
histogram(Dept_Num)   
title('Size of Departments')
xlabel('Department Number')
ylabel('Size')

%% Exercise 3: Visualize the graph according to betweenness
betweenness = centrality(G,'betweenness');          
edgeC = [.7 .7 .7];

figure; clf                                           % set color map
H = plot(G,'MarkerSize',log((betweenness+1)*10), ...  % node size by betweenness (bring into range 1-10 for plotting)
    'NodeCData',betweenness,...                       % node color by betweenness
    'EdgeColor',edgeC,'EdgeAlpha',0.3);                  
title('Ego Network colored by Betweenness Centrality')                                    
H = colorbar;                                         % add colorbar
ylabel(H, 'betweenness')                              % add metric as ylabel
colormap parula 



%% Exercise 4: Visualize the graph according to Department

figure; clf                                           % set color map
H = plot(G,'MarkerSize',log((betweenness+1)*10), ...  % node size by betweenness (bring into range 1-10 for plotting)
    'NodeCData',Dept_Num,...                          % node color by betweenness
    'EdgeColor',edgeC,'EdgeAlpha',0.3);               
title('Ego Network colored by Department')                                    
H = colorbar;                                         % add colorbar
ylabel(H, 'Departments')                              % add metric as ylabel
colormap colorcube 


%% Exercise 5 (Optional): Visualize the graph according to Department size
% It's hard to see 42 different colors on one graph. Identify the largest 8
% departments and plot them in distinct colors, using a color picker like
% viz palette. Plot the rest of the nodes in gray.

colors = [
"e41a1c",
"377eb8",
"4daf4a",
"984ea3",
"ff7f00",
"ffff33",
"a65628",
"f781bf",
"999999"];

rgb = zeros(length(colors),3);
for i = 1:length(colors)
    rgb(i,:) = hex2rgb(colors{i});
end
rgb = flipud(rgb/255);

counts = histcounts(Dept_Num,42);
[~,top8] = sort(counts,'descend');
top8 = top8(1:8);

top = ismember(Dept_Num,top8);
top_Dept = top.*Dept_Num;

for i = 1:8
    top_Dept(top_Dept == top8(i))=i;
end
figure; clf                                           % set color map
H = plot(G,'MarkerSize',log((betweenness+1)*10), ...  % node size by betweenness (bring into range 1-10 for plotting)
    'NodeCData',top_Dept,...                          % node color by betweenness
    'EdgeColor',edgeC,'EdgeAlpha',0.3);   
title('Ego Network colored by Top 8 Departments')                                    
Hc = colorbar;                                         % add colorbar
ylabel(Hc, 'Departments')                              % add metric as ylabel
colormap(rgb)

autoArrangeFigures







       

