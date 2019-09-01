function  [documents, extras] =  loadData()

[~,~,rawSegments] = xlsread('Sherlock_Segments.xlsx');
rawSegments(:,end)=[];
labelsSegments = rawSegments(1,:);
rawSegments(1,:) = [];
rawSegments(end,:) = [];

filter = cellfun(@length, rawSegments(:,6));
interval = find(filter>mean(filter));
interval(:,2) = [interval(2:end,1)-1; length(filter)]; % scenes

for i = 1:50
    scenes(i) = ...
        {cell2struct(rawSegments(interval(i,1):interval(i,2),:),labelsSegments,2)};
    arousal(i) = nanmean(([scenes{i}.Arousal_Rater1]+[scenes{i}.Arousal_Rater2]+...
        [scenes{i}.Arousal_Rater3]+[scenes{i}.Arousal_Rater4])/4);
    valence(i) = nanmean(([scenes{i}.Valence_Rater1]+[scenes{i}.Valence_Rater2]+...
        [scenes{i}.Valence_Rater3]+[scenes{i}.Valence_Rater4])/4);
    documents{i} = [scenes{i}.SceneDetails];
end

extras.arousal = arousal;
extras.valence = valence;
extras.all = rawSegments(:,7);
end