function [subjects, recallQuality] = loadSubjects
% LOAD LABELS FROM S1 FIRST
[~,~,rawSubject] = xlsread('S1_Scene_Matches_edit4matlab.xlsx','A1:H1');
labelsSubjects = rawSubject(1,:);

for i = 1:17
    [~,~,rawSubject] = xlsread(['S',num2str(i),'_Scene_Matches_edit4matlab.xlsx']);
    rawSubject(1,:) = [];
    rawSubject(:,8+1:end)=[];
    subjects(i) = struct('allscenes',cell2struct(rawSubject,labelsSubjects,2));
    if length(subjects(i).allscenes) ~= 50
        numbers = [subjects(i).allscenes.scene_number];
        dummy = tabulate(numbers);
        rep = dummy(dummy(:,2)>1,1);
        for j = 1:length(rep)
            index = find(numbers == rep(j));
            subjects(i).allscenes(index(1)).transcript =...
                [subjects(i).allscenes(index(1):index(end)).transcript];
            subjects(i).allscenes(index(2):index(end)) = [];
            numbers = [subjects(i).allscenes.scene_number];
        end
    end
    if length(subjects(i).allscenes) ~= 50
        subjects(i).allscenes(51) = [];
    end
    recallQuality(i,:) = [subjects(i).allscenes(1:50).quality];
end
recallQuality(isnan(recallQuality))=0;
end