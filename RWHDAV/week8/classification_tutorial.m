
% Tutorial for running ROI-level classification analyses on the Sherlock movie & recall data
% j.chen october 2018
%
% This tutorial includes fmri data files from Chen et al. (2017) Nature Neuroscience 

%% step 0: cd to the Sherlock directory

clear all
close all
basepath = pwd
[filepath,dirname] = fileparts(basepath);
if ~strcmp(dirname,'Sherlock')
    fprintf('Your current folder is not Sherlock -- make sure you are starting in the correct directory.\n');
else
    addpath(basepath);
end
addpath(fullfile(basepath,'code'));
addpath(fullfile(basepath,'NIFTI_tools'));

%% Calculate scene averages: a voxel pattern for each scene
% for movie-movie, movie-recall, and recall-recall

% choose an ROI
% roiname = 'aud_early';
roiname = 'pmc_nn';

% this file contains movie and recall scene timestamps for each subject
load(fullfile(basepath,'subjects','sherlock_allsubs_events.mat'),'ev');
names = sherlock_get_subj_info('names','sherlock_movie');

condnames = {'sherlock_movie','sherlock_recall'};
[allsubs_50M_events,allsubs_50FR_events,allsubs_iM_events,allsubs_iFR_events] =...
    sherlock_load_avgscenes_50M_50R(basepath,roiname,names,ev,condnames);

%% Movie-Movie scene classification

% choose 100 random permutations 
numperms = 100;
allperms = nchoosek([1:17],8);
r = randi(size(allperms,1),numperms,1);
permmat = allperms(r,:);

clear erank_iters eexact_iters all_corrmats
for n = 1:numperms
    group1 = permmat(n,:); group2 = setdiff([1:17],group1);
    
    % create the two independent group averages
    group1_Epats = nanmean(allsubs_50M_events(:,:,group1),3);
    group2_Epats = nanmean(allsubs_50M_events(:,:,group2),3);
    
    % calculate scene-to-scene corrs
    corrmat = corr(group1_Epats,group2_Epats);
    all_corrmats(:,:,n) = corrmat;
    sdiag = diag(corrmat); % get the diagonal elements of the corr matrix
    clear erank
    % proceed one column at a time through the corr matrix
    % for each column, is the diagonal element the largest correlation value in the whole column?
    for ee = 1:length(sdiag)
        colsort = sort(corrmat(:,ee)); % extract the column and sort it lowest-to-highest
        % identify where the diagonal element (sdiag(ee)) is in this ranked list
        % save a 1 in erank(ee) if the diagonal element is the largest correlation
        % save a 2 is it's the 2nd largest, etc.
        erank(ee) = length(colsort) - find(sdiag(ee)==colsort) + 1; 
    end
    
    % subj_eranks is a numscenes x numsubj matrix where for each scene we record
    % what rank [1:50] the true match was at, among all the 50 scenes.
    
    % subj_eexact records standard classification results (perfect matches only).
    eexact = sum(erank==1)/length(sdiag); % chance = 1/50 = 2%
    
    erank_iters(n,:) = erank; % save the ranks
    eexact_iters(n) = eexact; % save the "exact match" results
end
numscenes = length(erank);
    
mean_erank = mean(mean(erank_iters,1));
fprintf(['Movie-movie mean rank: ' num2str(mean_erank) '\n']);

fs = 14; ms = 10;

figure(1); clf

subplot(1,4,1)
bar(mean(eexact_iters),'FaceColor',([0 0 0])); hold on
exact_jittervec = ones(numperms,1) + (rand(numperms,1)-0.5)/3;
plot(exact_jittervec,eexact_iters,'g.','MarkerSize',ms); hold on
plot([0 2],[1/numscenes 1/numscenes],'r--','LineWidth',2);
xlim([0 2]); ylim([0 0.6]);
set(gca,'FontSize',fs);
ylabel('Classification Accuracy');
title('Accuracy: Movie vs. Movie');

subplot(1,4,2:4)
for cc = 1:size(erank_iters,2)
    bar(cc,numscenes - mean(erank_iters(:,cc)) + 1,'FaceColor',([0 0 0])); hold on
end
for cc = 1:size(erank_iters,2)
    jittervec = cc*ones(size(erank_iters,1),1) + (rand(size(erank_iters,1),1)-0.5)/3;
    plot(jittervec,numscenes - erank_iters(:,cc) + 1,'g.','MarkerSize',ms); hold on
end
xlim([0 length(erank)+1]); ylim([0 numscenes+1]);
set(gca,'FontSize',fs); set(gca,'XTick',[0:10:length(erank)]);
epoints = fliplr([numscenes numscenes-9:-10:1]); epointstr = fliplr([1 10:10:numscenes]);
set(gca,'YTick',epoints,'YTickLabel',epointstr); 
xlabel('Scene Number'); ylabel('Mean Rank');
title('Classification Rank for Individual Scenes: Movie vs. Movie');

%% Movie-movie correlation matrix
figure(2); clf
imagesc(mean(all_corrmats,3),[-1 1]); colorbar
title('Movie-Movie Correlation Matrix Averaged Across Subjects');
xlabel('Movie Scenes'); ylabel('Movie Scenes');


%% Exercise 1: Use different size groups. What happens to classification accuracy?
% What do you think is the cause of this pattern?
% Group sizes X vs Y where X=1:16 and Y=17-X

% The pattern could be caused by the fact that the mean for each group will
% be closer to the "true mean" of the entire sample if the group is bigger.
% Because we are segmenting into two groups, the best resul is when each
% group contains half of the sample.

figure;
hold on
for s = 1:16
    % choose 100 random permutations
    numperms = 100;
    allperms = nchoosek(1:17,s);
    r = randi(size(allperms,1),numperms,1);
    permmat = allperms(r,:);
    
    clear erank_iters eexact_iters
    for n = 1:numperms
        group1 = permmat(n,:); group2 = setdiff(1:17,group1);
        
        % create the two independent group averages
        group1_Epats = nanmean(allsubs_50M_events(:,:,group1),3);
        group2_Epats = nanmean(allsubs_50M_events(:,:,group2),3);
        
        % calculate scene-to-scene corrs
        corrmat = corr(group1_Epats,group2_Epats);
        all_corrmats(:,:,n) = corrmat;
        sdiag = diag(corrmat); % get the diagonal elements of the corr matrix
        clear erank
        % proceed one column at a time through the corr matrix
        % for each column, is the diagonal element the largest correlation value in the whole column?
        for ee = 1:length(sdiag)
            colsort = sort(corrmat(:,ee)); % extract the column and sort it lowest-to-highest
            % identify where the diagonal element (sdiag(ee)) is in this ranked list
            % save a 1 in erank(ee) if the diagonal element is the largest correlation
            % save a 2 is it's the 2nd largest, etc.
            erank(ee) = length(colsort) - find(sdiag(ee)==colsort) + 1;
        end
        
        % subj_eranks is a numscenes x numsubj matrix where for each scene we record
        % what rank [1:50] the true match was at, among all the 50 scenes.
        
        % subj_eexact records standard classification results (perfect matches only).
        eexact = sum(erank==1)/length(sdiag); % chance = 1/50 = 2%
        
        erank_iters(n,:) = erank; % save the ranks
        eexact_iters(n) = eexact; % save the "exact match" results
    end
    numscenes = length(erank);
    
    mean_erank = mean(mean(erank_iters,1));
      
    bar(s,mean(eexact_iters),'FaceColor',([0 0 0]));
    exact_jittervec = s*ones(numperms,1) + (rand(numperms,1)-0.5)/3;
    plot(exact_jittervec,eexact_iters,'g.');
end

plot([0 s+1],[1/numscenes 1/numscenes],'r--'); % P random
xlabel('Group 1 size');
xticks(1:s)
ylabel('Classification Accuracy');
title('Accuracy of Movie vs Movie');

    
