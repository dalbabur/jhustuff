
function v = nkit_get_subj_info(infostr,cond)

switch cond
    case 'PiemanIntact'
        names = {'subj01','subj02','subj03','subj04'};
        crop_special = [1 6 14; 2 12 8; 3 11 9; 4 10 10];
        crop_beginning = 10; % default crop
        crop_end = 10; % default crop
end

switch infostr
    case 'names', v = names;
    case 'crop_beginning', v = crop_beginning;
    case 'crop_end', v = crop_end;
    case 'crop_special', v = crop_special;
end
