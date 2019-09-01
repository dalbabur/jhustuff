
% Tutorial for ISC and pattern similarity analyses with fMRI data
% j.chen october 2018
%
% This tutorial includes fmri data files from 4 subjects who listened to a
% 7-minute auditory story ("Pieman").
% It walks through the steps of:
% loading nifti files into Matlab,
% calculating inter-subject correlation (ISC) in an ROI within the group (correlation of timecourses across subjects),
% plotting ISC in an ROI,
% calculating ISC at every voxel within-group to create a whole-brain map,
% regressing a vector on a 4d functional,
% calculating pattern similarity in an ROI within the group (correlation of spatial patterns across subjects),
% plotting pattern similarity in an ROI

% All Nifti files must be unzipped

%% step 0: cd to the ISC directory

clear all
close all
basepath = pwd
[filepath,dirname] = fileparts(basepath);
if ~strcmp(dirname,'ISC')
    fprintf('Your current folder is not ISC -- make sure you are starting in the correct directory.\n');
else
    addpath(basepath);
end
addpath(fullfile(basepath,'NIFTI_tools'));

%% ROI Timecourses
% input: 4d functional nifti files for subj01, subj02, subj03
% output: a summary file roi_condname_roicorr.mat that contains ISC info for the ROI

x = 0;
x=x+1; rois{x} = 'a1_rev.nii';
x=x+1; rois{x} = 'early_visual.nii';
x=x+1; rois{x} = 'PMC_3mm.nii';
for rr = 1:length(rois)
    roi = rois{rr};
    
    % set roidata load/save flag:
    % 'savedata': run this the first time, after which a .mat will be saved
    % 'loaddata': uses the .mat (faster)
    % if you change the ROI, you need to run with the savedata flag again.
    roidataflag = 'savedata';
    
    condname = 'PiemanIntact';
    funcnames = []; roinames = [];
    names = nkit_get_subj_info('names',condname);
    for nn = 1:length(names)
        funcnames{nn} = fullfile(basepath,names{nn},condname,'trans_filtered_func_data.nii');
    end
    roinames = fullfile(basepath,'standard',roi);
    fprintf(['cond = ' condname ', output will be saved as ' rois{rr}(1:end-4) '_' condname '_roicorr.mat\n']);
    opts.outputPath = fullfile(basepath,'intersubj','roicorr');
    opts.outputName = condname;
    
    opts.crop_beginning = nkit_get_subj_info('crop_beginning',condname); % number of TRs to crop from beginning
    opts.crop_end = nkit_get_subj_info('crop_end',condname); % number of TRs to crop from end
    opts.crop_special = nkit_get_subj_info('crop_special',condname); % specify different crops for different subjects, otherwise defaults to crop_beginning and crop_end
    opts.roidata = roidataflag;
    nkit_nifti_roi_timecourse(funcnames, roinames, opts);
    if strcmp(roidataflag,'savedata') % if using savedata flag, auto-run loaddata afterward
        opts.roidata = 'loaddata';
        nkit_nifti_roi_timecourse(funcnames, roinames, opts);
    end
end


%% plot ROI timecourses

% select an ROI
roiname = 'a1_rev';
% roiname = 'early_visual';
% roiname = 'PMC_3mm';

% select a condition
condname = 'PiemanIntact'; % in this tutorial there is only one condition

names = nkit_get_subj_info('names',condname);
roicorrpath = fullfile(basepath,'intersubj','roicorr'); 
roicorr_file = [roiname '_' condname '_roicorr.mat'];
r = load(fullfile(roicorrpath,roicorr_file));
figure(1); clf; set(gcf,'Color',[1 1 1]); rcolors = 'rgbm';
for n = 1:length(r.roicorr)
    plot(r.roitc(:,n),rcolors(n),'LineWidth',2); hold on; 
end
plot(zscore(r.meantc),'k','LineWidth',3);
set(gca,'FontSize',16); grid on; xlabel('TR'); ylabel('Z')
rtitle = ['Indiv subject timecourses for ' roiname];
title(strrep(rtitle,'_','-'));
legend([names 'mean']);


%% plot lagged corrs for one pair of subjects for this ROI

% select an ROI
roiname = 'a1_rev';
% roiname = 'early_visual';
% roiname = 'PMC_3mm';

% select a condition
condname = 'PiemanIntact'; % in this tutorial there is only one condition

% select a pair of subjects
s1 = 1; s2 = 2;

% load subject timecourses
roicorrpath = fullfile(basepath,'intersubj','roicorr'); 
roicorr_file = [roiname '_' condname '_roicorr.mat'];
r = load(fullfile(roicorrpath,roicorr_file));

figure(2); clf; set(gcf,'Color',[1 1 1]); 
w = 40; % lag window
lagcc = lagcorr(r.roitc(:,s1),r.roitc(:,s2),[-1*w:w]);
plot([-1*w:w],lagcc,'b','LineWidth',2); hold on; grid on
m1 = plot(0,lagcc(w+1),'ok','LineWidth',2);
set(gca,'FontSize',16);
ylabel('Correlation'); xlabel('Lag');
rtitle = ['Subj' num2str(s1) ' vs Subj' num2str(s2) ' ' roiname ' Lagged Correlation']; 
title(strrep(rtitle,'_','-'));


%% plot lagged corrs for every subject for this ROI
% each subj vs. average others

% select an ROI
roiname = 'a1_rev';
% roiname = 'early_visual';
% roiname = 'PMC_3mm';

% select a condition
condname = 'PiemanIntact'; % in this tutorial there is only one condition

% load subject timecourses
roicorrpath = fullfile(basepath,'intersubj','roicorr'); 
roicorr_file = [roiname '_' condname '_roicorr.mat'];
r = load(fullfile(roicorrpath,roicorr_file));

% calculate average others
for n = 1:length(r.roicorr)
    r.otherstc(:,n) = nanmean(r.roitc(:,setdiff([1:size(r.roitc,2)],n)),2); 
end

figure(3); clf; set(gcf,'Color',[1 1 1]); 
w = 40; % lag window
for n = 1:length(r.roicorr)
    i1 = n*w-w; i2 = n*w+w;
    lagcc = lagcorr(r.roitc(:,n),r.otherstc(:,n),[-1*w:w]);
    plot([i1:i2],lagcc,rcolors(n),'LineWidth',2); hold on
    m1 = plot(n*w,lagcc(w+1),'ok','LineWidth',2);
end
set(gca,'FontSize',16,'XTick',[w:w:w*n],'XTickLabel',[1:n]); grid on
xlim([0 n*w+w]); xlabel('Subject #'); ylabel('Lagged Correlation');
rtitle = ['Each Subj x Mean-of-Others ' roiname]; 
title(strrep(rtitle,'_','-'));
yr = ylim(gca); yd = (yr(2)-yr(1))/10;
plot([0 w],[-1*yd -1*yd],'k-','LineWidth',4); text(1,-2*yd,[num2str(w) ' TRs']);

%% Exercise 1
% Calculate pairwise subject timecourse correlations
% Do this for each of the three ROIs below
% Plot the correlation matrices in subplots of one figure
roinames = {'a1_rev' 'early_visual' 'PMC_3mm'};

condname = 'PiemanIntact'; 
Labels = {'subj01' 'subj02' 'subj03' 'subj04'};

figure;
for i = 1:3
% load subject timecourses
roicorrpath = fullfile(basepath,'intersubj','roicorr'); 
roicorr_file = [roinames{i} '_' condname '_roicorr.mat'];
r = load(fullfile(roicorrpath,roicorr_file));

subplot(1,3,i);
tc_all = [r.roitc(:,1) r.roitc(:,2) r.roitc(:,3) r.roitc(:,4)];
roicorr = corr(tc_all);
imagesc(roicorr);
colorbar;
caxis([-0.5 0.5]);
set(gca, 'XTick', 1:4, 'XTickLabel', Labels); set(gca,'YTick', 1:4,'YTickLabel', Labels);
title(['Pairwise Corrs for ' roinames{i}],'Interpreter', 'none');
end
%% Correlation Maps - Within Group
% input: 4d functional nifti files for subj01, subj02, subj03
% output: a single correlation map of subj01, subj02, subj03 (one-to-avg-others)
% optional outputs: mean of all subjects as nifti (4d), avg others for each subject as nifti (4d)

condname = 'PiemanIntact';
funcnames{1} = fullfile(basepath,'subj01',condname,'trans_filtered_func_data.nii');
funcnames{2} = fullfile(basepath,'subj02',condname,'trans_filtered_func_data.nii');
funcnames{3} = fullfile(basepath,'subj03',condname,'trans_filtered_func_data.nii');
funcnames{4} = fullfile(basepath,'subj04',condname,'trans_filtered_func_data.nii');
opts.outputPath = fullfile(basepath,'intersubj','corrmap');
opts.outputName = condname;
opts.crop_beginning = nkit_get_subj_info('crop_beginning',condname); % number of TRs to crop from beginning
opts.crop_end = nkit_get_subj_info('crop_end',condname); % number of TRs to crop from end
opts.crop_special = nkit_get_subj_info('crop_special',condname); % specify different crops for different subjects, otherwise defaults to crop_beginning and crop_end
opts.mask = fullfile(basepath,'standard','MNI152_T1_3mm_brain_mask.nii'); % mask image is optional
opts.standard = fullfile(basepath,'standard','MNI152_T1_3mm_brain.nii'); % all hdr info will come from this file except for datatype=16 and bitpix=32
opts.mcutoff = 6000; % 6000 for Skyra data
opts.load_nifti = 0; % load data from nifti (specified in funcnames), save as .mat
opts.calc_avg = 1; % calculate the avg of others for each subject
opts.calc_corr = 1; % calculate intersubject correlations and save output maps as nifti
opts.save_avgothers_nii = 0; % save the avg others for each subject as nifti files (otherwise saves in .mat only)
opts.save_mean_nii = 0; % save the mean of all subjects as a nifti file (otherwise does not calculate the mean)
nkit_nifti_corrmap(funcnames, [], opts);


%% Regress a vector on a 4d functional
% for example, regress the audio envelope of a story onto the functional data for a subject
% saves output map in the same folder as original functional data

load(fullfile(basepath,'standard','pieman_intact_audenv.mat')); % loads audenv
figure(4); clf; set(gcf,'Color',[1 1 1]); 
plot(audenv,'k','LineWidth',2); grid on
title('Auditory Envelope'); xlabel('Timepoints'); ylabel('Amplitude');
condname = 'PiemanIntact';
names = nkit_get_subj_info('names',condname);

subjnum = 1;
funcname = fullfile(basepath,names{subjnum},condname,'trans_filtered_func_data.nii');
opts.outputName = [names{subjnum} '_audenv'];
subject_crop_info = nkit_get_subj_info('crop_special',condname); % specify different crops for different subjects, otherwise defaults to crop_beginning and crop_end
opts.crop_beginning = subject_crop_info(subjnum,2); % number of TRs to crop from beginning
opts.crop_end = subject_crop_info(subjnum,3); % number of TRs to crop from end

nkit_nifti_regressmap(funcname, audenv, opts);


%% Exercise 2
% ROI seed maps
% retrieve the mean timecourse for PMC_3MM across the four subjects
% regress this timecourse onto the functional data for each of the four subjects
% examine the resulting maps. what do the maps show?
condname = 'PiemanIntact';
names = nkit_get_subj_info('names',condname);
roicorrpath = fullfile(basepath,'intersubj','roicorr'); 
roicorr_file = ['PMC_3mm' '_' condname '_roicorr.mat'];
r = load(fullfile(roicorrpath,roicorr_file));
meantc = (r.roitc(:,1)+r.roitc(:,2)+r.roitc(:,3)+r.roitc(:,4))/4;

for i = 1:4
funcname = fullfile(basepath,names{i},condname,'trans_filtered_func_data.nii');
opts.outputName = [names{i} '_PMC'];
subject_crop_info = nkit_get_subj_info('crop_special',condname); % specify different crops for different subjects, otherwise defaults to crop_beginning and crop_end
opts.crop_beginning = subject_crop_info(i,2); % number of TRs to crop from beginning
opts.crop_end = subject_crop_info(i,3); % number of TRs to crop from end

nkit_nifti_regressmap(funcname, meantc, opts);
end
%The maps show the relationship between the mean activity in the PMC_3mm and the
%functional data for each subject

% bonus exercise:
% nkit_nifti_regressmap shows how to replace the .img field of a nii file,
% replace it, and save out a new nii file.
% write a function that accepts a list of nii files, calculates their
% average, and saves the average as a new nii file.


%% ROI Pattern Similarity
% input: mat files created (by nkit_nifti_roi_timecourse) from 4d functional nifti files for subj01, subj02, subj03
% output: a summary file roi_condname_patternsim.mat that contains pattern similarity info for the ROI
% pattern similarity is calculated 1-vs-avg-others at every timepoint
% then averaged across subjects

x = 0;
x=x+1; rois{x} = 'a1_rev';
x=x+1; rois{x} = 'early_visual';
x=x+1; rois{x} = 'PMC_3mm';
for rr = 1:length(rois)
    condname = 'PiemanIntact';
    names = nkit_get_subj_info('names',condname);
    roiname = rois{rr};
    nkit_nifti_patternsim(basepath,names,roiname,condname);
end

%% plot ROI pattern similarity

roiname = 'a1_rev';
% roiname = 'early_visual';
% roiname = 'PMC_3mm';

condname = 'PiemanIntact';
names = nkit_get_subj_info('names',condname);

roicorrpath = fullfile(basepath,'intersubj','patternsim'); 
roicorr_file = [roiname '_PiemanIntact_patternsim.mat'];
r = load(fullfile(roicorrpath,roicorr_file));
figure(9096); clf; set(gcf,'Color',[1 1 1]);
rcolors = 'rgbm';

% average pattern correlation matrix
subplot(1,2,1)
imagesc(r.mcorrmat,[-0.2 0.2]); colorbar
set(gca,'FontSize',14);
rtitle = ['Pattern correlation matrix ' roiname]; 
title(strrep(rtitle,'_','-'));

% get diagonal and non-diagonal values
for n = 1:length(names)
    subjmat = squeeze(r.allsubs_corrmat(:,:,n));
    sdiag{n} = diag(subjmat);
    ioffdiag = triu(ones(size(subjmat)),1) - triu(ones(size(subjmat))) + 1; % off-diagonal index
    offdiag{n} = subjmat(logical(ioffdiag));
    subj_sdiag(n) = nanmean(sdiag{n});
    subj_offdiag(n) = nanmean(offdiag{n});
end

% summary of diag vs nondiag for each subject
subplot(1,2,2)
plot([0 18],[0 0],'k-','LineWidth',2); hold on
for n = 1:length(names)
    h1 = plot(n,subj_sdiag(n),'o','Color',rcolors(n),'LineWidth',3,'MarkerSize',10); hold on
    h2 = plot(n,subj_offdiag(n),'s','Color',rcolors(n),'LineWidth',3,'MarkerSize',10);
    plot(n,subj_sdiag(n),'.','Color',rcolors(n),'LineWidth',3,'MarkerSize',10); hold on
    plot(n,subj_offdiag(n),'.','Color',rcolors(n),'LineWidth',3,'MarkerSize',10);
    plot([n n],[subj_offdiag(n) subj_sdiag(n)],'--','Color',rcolors(n),'LineWidth',2);
end
grid on
xlim([0 n+1]); ylim([-0.1 0.2]);
set(gca,'FontSize',14);
xlabel('Subject'); ylabel('R');
rtitle = ['Diagonal and non-diagonal values ' roiname]; 
title(strrep(rtitle,'_','-'));
legend([h1 h2],'Diagonal','Non-Diagonal');












