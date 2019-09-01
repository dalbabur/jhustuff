
% j.chen september 2018
% adapted from: 
% https://blogs.mathworks.com/loren/2016/02/03/visualizing-facebook-networks-with-matlab/
% _Copyright 2016 The MathWorks, Inc._

% step 0: cd to the Social_Networks directory

clear all
close all
basepath = pwd
[filepath,dirname] = fileparts(basepath);
if ~strcmp(dirname,'Social_Networks')
    fprintf('Your current folder is not Social_Networks -- make sure you are starting in the correct directory.\n');
else
    addpath(basepath);
end

%% Facebook Ego Network Dataset
% https://snap.stanford.edu/data/egonets-Facebook.html
% This dataset contains anonymized personal networks of connections between
% friends of survey participants. Such personal networks represent
% friendships of a focal node, known as "ego" node, and such networks are
% therefore called "ego" networks.
% paper: http://i.stanford.edu/~julian/pdfs/nips2012.pdf

load('facebook.mat');
whos

%% Visualize Combined Ego Networks
% Let's first combine all 10 ego networks into a graph and visualize  them in a single plot. This combined 
% network has a little fewer than 4,000 nodes but with over 84,000 edges. It also includes some ego nodes, 
% which means those survey participants were not entirely unrelated to one another.

comb = vertcat(edges{:});                           % combine edges
comb = sort(comb, 2);                               % sort edge order
comb = unique(comb,'rows');                         % remove duplicates
comb = comb + 1;                                    % convert to 1-indexing
combG = graph(comb(:,1),comb(:,2));                 % create undirected graph
notConnected = find(degree(combG) == 0);            % find unconnected nodes
combG = rmnode(combG, notConnected);                % remove them

edgeC = [.7 .7 .7];                                 % gray color

figure(1); clf
H = plot(combG,'MarkerSize',1,'EdgeColor',edgeC, ...% plot graph
    'EdgeAlpha',0.3); 
title('Combined Ego Networks')                      % add title
text(17,13,sprintf('Total %d nodes', ...            % add node metric
    numnodes(combG)))     
text(17,12,sprintf('Total %d edges', ...            % add edge metric
    numedges(combG)))
text(17,11,'Ego nodes shown in red')                % add edge metric
  
egos = intersect(egoids + 1, unique(comb));         % find egos in the graph
highlight(H,egos,'NodeColor','r','MarkerSize',3)    % highlight them in red 

%% Visualize a Single Ego Network - Degree Centrality
% One of the most basic analyses you can perform on a network is link
% analysis. Let's figure out who are the most well connected in this graph.
% To make it easy to see, we can change the color by number of connections,
% also known as 'degree'; this is a metric known as degree centrality. The
% top 3 nodes by degree are highlighted in the plot and they all belong to
% the same cluster. They are very closely connected friends!
% 
% Note that the ego node does not appear (in the edge list), but it is assumed
%   that they follow every node id that appears in this file.
%
% By nature the ego node will always be the top node, so there is no point
% in including it.

idx = 2; % 2,3,5,6,8,9,10                           % pick an ego node
egonode = num2str(egoids(idx));                     % ego node name as string
G = graphs{idx};                                    % get its graph
deg = degree(G);                                    % get node degrees
notConnected = find(deg < 2);                       % weakly connected nodes
deg(notConnected) = [];                             % drop them from deg           
G = rmnode(G, notConnected);                        % drop them from graph
[~, ranking] = sort(deg,'descend');                 % get ranking by degree
top3 = G.Nodes.Name(ranking(1:3));                  % get top 3 node names

figure(2); clf
H = plot(G,'MarkerSize',log(deg), ...               % node size in log scale
    'NodeCData',deg,...                             % node color by degree
    'EdgeColor',edgeC,'EdgeAlpha',0.3);
labelnode(H,top3,{'#1','#2','#3'});                 % label top 3 nodes
title({sprintf('Ego Network of Node %d', ...        % add title
    egoids(idx)); 'colored by Degree Centrality'})
text(-1,-3,['top 3 nodes: ',strjoin(top3)])         % annotate                                    
H = colorbar;                                       % add colorbar
ylabel(H, 'degrees')                                % add metric as ylabel
colormap cool                                       % set color map

%% Ego Network Degree Distribution
% Make a histogram of degrees for the ego network we just looked at and for the combined ego
% networks. People active on Facebook will have more edges than those not, but a few people 
% have a large number of degrees and the majority have small number of degrees, and difference 
% is large and looks exponential.

figure(3); clf
histogram(degree(combG))                            % plot histogram
hold on                                             % don't overwrite
histogram(degree(G))                                % overlay histogram
hold off                                            % restore default
xlabel('Degrees')                                   % add x axis label
ylabel('Number of Nodes')                           % add y axis label
title('Degree Distribution')                        % add title
legend('The Combined Ego Networks', ...             % add legend
    sprintf('Ego Network of Node %d',egoids(idx)))
text(150,700,'Median Degrees')                      % annotate
text(160,650,sprintf('* Node %d: %d', ...           % annotate
    egoids(idx),median(degree(G))));
text(160,600,sprintf('* Combo    : %d', ...         % annotate
    median(degree(combG))));

%% Shortest Paths 
% We looked at degrees as a metric to evaluate nodes, and it makes sense -
% the more friends a node has, the better connected it is. Another common
% metric is "shortest paths". While degrees measure direct connections only, shortest
% paths consider how many hops at mininum you need to make to traverse from
% one node to another. Let's look at an example of the shortest path
% between the top node 1888 and another node 483.

if idx==2 % only run this section for ego network #2
    
[path, d] = shortestpath(G,top3{1},'483');          % get shortest path 

figure(4); clf
H = plot(G,'MarkerSize',1,'EdgeColor',edgeC);       % plot graph
highlight(H,path,'NodeColor','r', ...               % highlight path
    'MarkerSize',3,'EdgeColor','r','LineWidth',2)
labelnode(H,path, [{'Top node'} path(2:end)])       % label nodes
title('Shortest Path between Top Node and Node 483')% add title
text(1,-3,sprintf('Distance: %d hops',d))           % annotate

end

%% Closeness Centrality
% Distances measured by shortest paths can be used to compute closeness.
% Those with high closeness scores are the ones you want
% to start with when you want to spread news through your ego network.

closeness = centrality(G,'closeness');
[~, ranking] = sort(closeness, 'descend');          % get ranking by closeness
top3 = G.Nodes.Name(ranking(1:3));                  % get top 3 node names              

figure(5); clf                                      % set color map
H = plot(G,'MarkerSize',closeness*10000, ...        % node size by closeness (bring into range 1-10 for plotting)
    'NodeCData',closeness,...                       % node color by closeness
    'EdgeColor',edgeC,'EdgeAlpha',0.3);
labelnode(H,top3,{'#1','#2','#3'});                 % label top 3 nodes
title({sprintf('Ego Network of Node %d', ...        % add title
    egoids(idx)); 'colored by Closeness Centrality'})
text(-1,-3,['top 3 nodes: ',strjoin(top3)])         % annotate                                    
H = colorbar;                                       % add colorbar
ylabel(H, 'closeness')                              % add metric as ylabel
colormap cool 

%% Betweenness Centrality
betweenness = centrality(G,'betweenness');
[~, ranking] = sort(betweenness, 'descend');          % get ranking by betweenness
top3 = G.Nodes.Name(ranking(1:3));                    % get top 3 node names              

figure(7); clf                                        % set color map
H = plot(G,'MarkerSize',log((betweenness+1)*10), ...  % node size by betweenness (bring into range 1-10 for plotting)
    'NodeCData',betweenness,...                       % node color by betweenness
    'EdgeColor',edgeC,'EdgeAlpha',0.3);
labelnode(H,top3,{'#1','#2','#3'});                   % label top 3 nodes
title({sprintf('Ego Network of Node %d', ...          % add title
    egoids(idx)); 'colored by Betweenness Centrality'})
text(-1,-3,['top 3 nodes: ',strjoin(top3)])           % annotate                                    
H = colorbar;                                         % add colorbar
ylabel(H, 'betweenness')                              % add metric as ylabel
colormap cool 

autoArrangeFigures




























