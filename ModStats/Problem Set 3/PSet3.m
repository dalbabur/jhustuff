%% 540.305 Problem Set 3: Plotting
clear
clc
%% Problem 1

% a
x = (0:0.1:2);
y = [x;x.^2;x.^3]';
colors =[1 0.5 0.5; 0.2 1 0.2;0.1,0.1,1];
legends = {'y=x','y=x^2','y=x^3'};
set(gca, 'ColorOrder', colors,'NextPlot', 'replacechildren');
plot(x,y,'LineWidth',3)
xlabel('X', 'FontSize',12)
ylabel('Y', 'FontSize',12)
legend(legends,'Location', 'northwest')

%b
figure
for i = 1:3
    subplot(1,3,i)
    plot(x,y(:,i),'Color',colors(i,:),'LineWidth',3)
    xlabel('X', 'FontSize',12)
    ylabel('Y', 'FontSize',12)
    legend(legends(i),'Location', 'northwest')
    axis([0 2 0 8])
end

%% Problem 2

% a
v = xlsread('cell_mutagen_data.xlsx','B3:D38');
figure
plot([2 4 6], v, '.r','MarkerSize',20) % used plot with '.' instead of scatter to expres x and y as matrices
xt={'no mutagen','mutagen 1', 'mutagen 2'} ; 
set(gca,'xtick',[2 4 6]); 
set(gca,'xticklabel',xt);
hold on
plot([1.5 2.5; 3.5 4.5; 5.5 6.5]', repmat(mean(v),2,1),'black')
ylabel('Number of Cells')
hold off

% b
figure
bar(mean(v),'r')
set(gca,'xtick',[1 2 3]); 
set(gca,'xticklabel',xt);
ylabel('Number of Cells')

%% Problem 3
file = 'Modstats_raw_fluorescence_data.xlsx';
fluo = [xlsread(file,'B3:C93'),xlsread(file,'G3:G93'),xlsread(file,'I3:I93')];
x = [fluo(:,3),fluo(:,4),fluo(:,3)./fluo(:,4)];
f = figure;
set(f,'defaultAxesColorOrder',[0 0 1; 1 0 0]);
tit = {'Raw Fluorescence (B5)','Normalizing Fluorescence (B9)','Normalized Fluorescence (B5/B9)'};
for i = 1:3
    subplot(2,2,i)
    yyaxis left
    plot(fluo(:,1),x(:,i),'b.','MarkerSize',15)
    ylabel('Fluorescence')
    yyaxis right
    plot(fluo(:,1),fluo(:,2),'r')
    ylabel('Temperature (ºC)')
    xlabel('Time (min)')
    title(tit(i))
end

%% Problem 4

% a
load('XYZt.mat')
figure
plot(squeeze(C(8,8,8,:)))
xlabel('Time')
ylabel('Temperature')
% b
figure
subplot(1,3,1)
surf(squeeze(C(8,:,:,end)))
view(150,29)
subplot(1,3,2)
surf(squeeze(C(:,8,:,end)))
view(150,29)
colorbar('northoutside')
subplot(1,3,3)
surf(squeeze(C(:,:,8,end)))
view(150,29)
% c
figure 
C = permute(C,[2 1 3 4]);
t=[1 251 501 1001];
for i = 1:4
    subplot(1,4,i)
    slice(C(:,:,:,t(i)),[1 5 10 15], 1,1)
    colorbar('northoutside')
    view(150,29)
end


