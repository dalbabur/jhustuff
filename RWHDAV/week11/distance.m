[~,~,data] = xlsread('anon_edge_list.csv','A2:B7706');
for i = 1:length(data)
    for j = 1:2
        edges(i,j) = str2num(data{i,j}(2:end));
    end
end
index = find(edges(:,1)==edges(:,2));
edges(index,:) = [];

G = graph(edges(:,1),edges(:,2));
figure;
plot(G)

d = distances(G);
figure
hist(d);