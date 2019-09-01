function subj_roitc = crop_roitc(sid,subj_roitc,opts)
if ~ismember(sid,opts.crop_special(:,1))
    subj_roitc(:,1:opts.crop_beginning) = []; % crop TRs from beginning of time series
    subj_roitc(:,end-opts.crop_end+1:end) = []; % crop TRs from end of time series
elseif ismember(sid,opts.crop_special(:,1)) % crop different begin/end TRs for specified subjects
    cid = find(sid==opts.crop_special(:,1));
    crop_begin = opts.crop_special(cid,2);
    crop_end = opts.crop_special(cid,3);
    if crop_begin<0 % adds timepoints to the beginning of series if needed
        for k = 1:crop_begin*-1
            subj_roitc(:,2:end+1) = subj_roitc;
%             subj_roitc(:,1) = NaN; % jc added this 01/21/2015
        end
    end
    subj_roitc(:,1:crop_begin) = []; % crop TRs from beginning of time series
    if crop_end<0
        for k = 1:crop_end*-1
            subj_roitc(:,end+1) = subj_roitc(:,end);
%             subj_roitc(:,end+1) = NaN; % jc modified this 01/21/2015
        end
    end
    subj_roitc(:,end-crop_end+1:end) = []; % crop TRs from end of time series
end