
% j.chen september 2018
% adapted from: 
% https://blogs.mathworks.com/loren/2015/09/30/can-we-predict-a-breakup-social-network-analysis-with-matlab/
% https://en.wikipedia.org/wiki/Zachary%27s_karate_club

%% step 0: cd to the Social_Networks directory

clear all
close all
basepath = pwd
[filepath,dirname] = fileparts(basepath);
if ~strcmp(dirname,'Social_Networks')
    fprintf('Your current folder is not Social_Networks -- make sure you are starting in the correct directory.\n');
else
    addpath(basepath);
end

%% load data from CSV files

fid1 = fopen('karate_vertices_names.csv','r'); % made-up names!
fid1_data = textscan(fid1,'%d%s','Delimiter',',');
fclose(fid1);
Vertices = fid1_data{1};
Names = fid1_data{2};

fid2 = fopen('karate_edges.csv','r'); % real data
fid2_data = textscan(fid2,'%d%d','Delimiter',',');
fclose(fid2);
Edges(:,1) = fid2_data{1};
Edges(:,2) = fid2_data{2};

% if you are having trouble reading the csv files, try using readtable to
% see if there are hidden characters with weird formats
% T = readtable('karate_vertices_names.csv','ReadVariableNames',0);

G = graph(Edges(:,1), Edges(:,2),[],Names); % create an undirected graph from edges

%% visualize the graph

figure(1); clf % open a figure window and clear it
P = plot(G); % default layout is 'auto': matlab chooses layout method based on the 
             %structure of the graph, in this case 'force'
title('Zachary''s Karate Club: Force')
figure(11); clf
P_circle = plot(G,'Layout','circle'); 
title('Zachary''s Karate Club: Circle')
figure(12); clf
P_layered = plot(G,'Layout','force3'); 
title('Zachary''s Karate Club: Force3')
figure(13); clf
P_layered = plot(G,'Layout','subspace'); 
title('Zachary''s Karate Club: Subspace')

autoArrangeFigures()
pause % wait for keypress
close([11 12 13])

%% who is the most connected?
% "degree": the number of edges connected to each node

D = degree(G);                          % get degrees per node
mu = mean(D);                           % average degrees
figure(2); clf
histogram(D);                           % plot histogram
hold on
line([mu, mu],[0, 10], 'Color', 'r')    % average degrees line
title('Karate Club Degree Distribution')
xlabel('degrees (# of connections)'); ylabel('# of nodes');
text(mu + 0.1, 10, sprintf('Average %.2f Degrees', mu))
% these two people have the most connections:
text(14.5, 1.5, Names{1})
text(16, 2, Names{34})
autoArrangeFigures()

%% color the nodes & edges of the graph to show the two groups

N1 = neighbors(G, 1);                               % get #1's friends
N1 = [N1; 1];                                       % add #1
N34 = neighbors(G, 34);                             % get #34's friends
N34 = [N34; 34];                                    % add #34

c1 = [1,0,1];                                       % 1's group color
c2 = [0,1,0.5];                                     % 34's group color

figure(1)                                 % return to the previously plotted graph
highlight(P, N1, 'NodeColor', c1, 'EdgeColor', c1); % highlight #1's friends
highlight(P, N34, 'NodeColor', c2, 'EdgeColor', c2);% highlight #34's friends
title('Friends of Nodes 1 and 34')

%% what really happened: the club broke up into two groups
% real data collected by wayne zachary (see slides)

G1nodes = [1, 2, 3, 4, 5, 6, 7, 8, 9,...                % Mr. Hi's (Node 1) group
    11, 12, 13, 14, 17, 18, 20, 22];

figure(3); clf
P = plot(G);                                            % plot the graph
highlight(P, G1nodes, 'NodeColor', c1,'EdgeColor', c1); % highlight group
title('The club broke up in two groups')
autoArrangeFigures()

%% predicting the breakup

A = adjacency(G);           % create adjacency matrix
B = full(A);                % convert the sparse matrix to full matrix
figure(4); clf
imagesc(B)                  % plot the matrix
axis square
title('Adjacency Matrix')
autoArrangeFigures()

%% hierchical clustering approach
% doesn't show us much

dist = pdist(A, 'jaccard'); % use Jaccard distance (intersection over union) to score connections: 
                            % pairwise distance between nodes (rows/cols)
                            % the more connections shared, the "closer" two nodes are
Z = linkage(dist);          % create a hierarchical cluster tree
figure(5); clf
[figh,leaf_node_num,dend_node_labels] = dendrogram(Z,size(Z,1)); % plot dendrogram
hold on
for i = 1:length(G1nodes) % highlight Mr. Hi's group
    node_pos = find(G1nodes(i)==dend_node_labels);
    if ~isempty(node_pos)
        plot(node_pos,0.1,'o','Color',c1); 
    end
end
title('Dendrogram Plot')
xlabel('Node Id'); ylabel('Distance')
autoArrangeFigures()

%% graph partitioning approach
% this works!

L = laplacian(G);                   % get Laplacian Matrix of G
%     L = laplacian(G) returns the graph Laplacian matrix. L is a sparse
%     matrix of size numnodes(G)-by-numnodes(G). The diagonal entries of L
%     are given by the degree of the nodes, L(j,j) = degree(G,j). The
%     off-diagonal entries of L are defined as L(i,j) = L(j,i) = -1 if G has
%     an edge between nodes i and j; otherwise, L(i,j) = L(j,i) = 0.
figure(6); clf
imagesc(L); colorbar
title('Laplacian Matrix');
% you can compare the diagonal of matrix L to the values you got above
% using the "degree" function (vector D); they're the same

% a method from spectral graph partitioning: cut the graph using the median of the Fiedler vector
[V, ~] = eig(full(L),'vector');     % get eigenvectors from L
w = V(:,2);                         % the Fiedler Vector is the eigenvector corresponding to the second smallest eigenvalue
P1nodes = find(w < median(w));      % select nodes below median value of the Fiedler Vector

errors = setdiff(G1nodes, P1nodes)  % perfect match to the actual split!

[~, order] = sort(w);                   % sort the weights by value
sortedA = A(order, order);              % apply the sort order to A

figure(7); clf
imagesc(sortedA)
axis square
title('Sorted Adjacency Matrix')

P1len = length(P1nodes);
line([P1len,P1len],[0,P1len], 'Color', 'r')    % median split line
line([0,P1len],[P1len,P1len], 'Color', 'r')
autoArrangeFigures()












