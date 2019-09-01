
function nkit_nifti_patternsim(basepath,names,roiname,condname)

% load ROI data
for n = 1:length(names)
    opts.crop_beginning = nkit_get_subj_info('crop_beginning',condname); 
    opts.crop_end = nkit_get_subj_info('crop_end',condname); 
    opts.crop_special = nkit_get_subj_info('crop_special',condname);
    rname = fullfile(basepath,'subjects',names{n},condname,[roiname '_trans_filtered_func_data.mat']);
    if ~exist(rname)
        fprintf(['ROI data not found for ' names{n} ' -- aborting\n']);
        keyboard
        return
    else
        r = load(rname);
        subj_roitc = crop_roitc(n,r.rdata,opts);
        roidata(n).(condname) = zscore(subj_roitc')'; % zscore across time
        roikeptvox(n).(condname) = r.keptvox;
    end
end

clear corrmat mdiag
for n = 1:length(names)
    
    % get data for this subject
    subj_data = roidata(n).(condname);
    
    % calculate average of all other subjects
    others = setdiff([1:length(names)],n);
    others_alldata = [];
    for k = 1:length(others)
        osubj = others(k);
        others_alldata(:,:,k) = roidata(osubj).(condname);
    end
    others_data = nanmean(others_alldata,3);
    
    corrmat = corr(subj_data,others_data);
    allsubs_corrmat(:,:,n) = corrmat;
    allsubs_mdiag(:,n) = diag(corrmat);
    
    fprintf(['subj ' num2str(n) ' ' num2str(mean(diag(corrmat))) '\n']);
end

mcorrmat = mean(allsubs_corrmat,3);
mdiag = mean(allsubs_mdiag,2);

if ~exist(fullfile(basepath,'intersubj','patternsim'))
    mkdir(fullfile(basepath,'intersubj'),'patternsim');
end
savename = fullfile(basepath,'intersubj','patternsim',[roiname '_' condname '_patternsim.mat']);
save(savename,'mcorrmat','mdiag','allsubs_corrmat','allsubs_mdiag');


















