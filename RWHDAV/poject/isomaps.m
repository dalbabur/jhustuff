function [ ] = isomaps(topics, neighbors)
l = length(neighbors);
for i = 1:l
    figure;
    [mapped_data,~] = compute_mapping(topics,'Isomap',2,neighbors(i));
    plot(mapped_data(:,1),mapped_data(:,2),'-o')
    for j = 1:length(mapped_data)
        text(mapped_data(j,1),mapped_data(j,2),['  ',num2str(j)]);
    end
    autoArrangeFigures
end