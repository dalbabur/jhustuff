

% 4. Do people aged 18-26 mention school-related topics more often than other age ranges? how much more?
% come up with a list of school-related words and characterize how frequently they appear for the different age groups. 
% use bar plots similar to the ones in section 8 above.
% you will first want to check your words to see what variants are present in the Vocabulary.
% when answering "how much more", report your answers as % of statements out of the total for that age group,
% rather than as absolute # statements.
%
% the answer that you turn in should consist of:
% - the bar plot figure, appropriately labeled (axes, title, legend)
% - a quantitative description of the result. for example, 
%   "people in age group 18-26 mention school-related topics in 11.5% of their statements, while for all other ages 
%   school-related topics are mentioned only in 0.3% of statements. school-related topics were measured by identifying 
%   statements containing any of the following words: school, class, student, ..."
% - all of the code that you wrote in order to get to this result. do not add onto the end of this tutorial; instead, 
%   create a new script file and copy in whatever sections are needed from this tutorial. DO include the "step 0" cell 
%   for setting paths at the top of your script.
%


% class, profesor, college, university, high school, school,
% mates, homework, exam, test, quiz, lecture, grades, score
%% step 0: cd to the HappyDB directory

clear all
close all
basepath = pwd;
[filepath,dirname] = fileparts(basepath);
if ~strcmp(dirname,'HappyDB')
    fprintf('Your current folder is not HappyDB -- make sure you are starting in the correct directory.\n');
else
    addpath(basepath);
end
% helper functions: https://www.dropbox.com/sh/yowqme68b0659jk/AAByvh--d64PfYj4oFACHVTOa?dl=0

%% 1. load and preprocess the text data

% load text data
fprintf('Loading text data.... ');
happydata = readtable(fullfile(basepath,'data\data','cleaned_hm.csv'),'TextType','string');
happydata(1:10,:); % display the table

textData = happydata.cleaned_hm; % the authors already cleaned the data a little bit, as described in the paper

% the happy statements were labeled with category and the reflection period
true_categoryLabels = happydata.ground_truth_category;
pred_categoryLabels = happydata.predicted_category;
periodLabels = happydata.reflection_period;

cleanTextData = erasePunctuation(textData); % remove punctuation
cleanTextData = lower(cleanTextData); % convert to lowercase
cleanDocuments = tokenizedDocument(cleanTextData); % create an array of tokenized documents

% words like "a", "and", "to", and "the" (known as stop words) can add noise to data
% remove a list of stop words using the stopWords and removeWords functions
myStopWords = stopWords; % stopWords is is a function that returns a predefined list of stop words

% note that 'i', 'my', 'me', 'we' are in the stopWords list. depending on
% the analysis, we might want to remove them from the stopWords.
keep_these_words = {};
% keep_these_words = {'i', 'my', 'me', 'we'};
for i = 1:length(keep_these_words)
    k = strmatch(keep_these_words{i},myStopWords,'exact');
    myStopWords(k) = [];
end

fprintf('\nPreprocessing text data.... ');
% remove the stop words
cleanDocuments = removeWords(cleanDocuments,myStopWords);

% sometimes you will want to remove short words, eg with 2 or fewer characters
% cleanDocuments = removeShortWords(cleanDocuments,2);

% and/or long words, eg with 15 or greater characters
cleanDocuments = removeLongWords(cleanDocuments,15);

% normalize the words using the Porter stemmer
cleanDocuments = normalizeWords(cleanDocuments);

% create a bag-of-words model
cleanBag = bagOfWords(cleanDocuments);

% you may want to remove words that don't appear often, eg that don't appear more than 2 times
cleanBag = removeInfrequentWords(cleanBag,2);

% some preprocessing steps such as removeInfrequentWords leave empty documents in the bag-of-words model. 
% to ensure that no empty documents remain in the bag-of-words model after preprocessing, 
% use removeEmptyDocuments as the last step.

% remove empty documents from the bag-of-words model and the corresponding labels.
[cleanBag,idx] = removeEmptyDocuments(cleanBag);
% remove the rows with empty documents from the labels
true_categoryLabels(idx) = []; 
pred_categoryLabels(idx) = [];
periodLabels(idx) = [];
cleanTextData(idx) = [];
% idx is an important variable- we will need it later to sync up other
% labels with cleanBag.

fprintf('\nDone preprocessing text data.\n');

%% 3. load demographic data
demographic = readtable(fullfile(basepath,'data\data','demographic.csv'),'TextType','string');
demographic(1:10,:); % display the table
ageDemo = demographic.age; 
countryDemo = demographic.country; 
genderDemo = demographic.gender;
maritalDemo = demographic.marital;
parentDemo = demographic.parenthood;
widDemo = demographic.wid;

%% 4. match WID to cleanBag
% the demographic data are organized differently from the text data. there is one entry per worker in the demographics file.
% but the text data has a lot more entries-- because workers generated more than one statement each.
% in order to match the demographic data to the text data, we need to
% identify which statements (documents) were generated by which mTurk workers (WID = Worker ID).
widLabels = happydata.wid;

% we defined idx above as the rows where there are empty documents; now remove those rows from widLabels too
widLabels(idx) = []; 

% create demographics labels matched to cleanBag
ageLabels = nan(size(widLabels)); countryLabels = cell(size(widLabels)); % intialize
genderLabels = cell(size(widLabels)); maritalLabels = cell(size(widLabels)); parentLabels = cell(size(widLabels));
for w = 1:length(widDemo)
    wid_from_demo = widDemo(w);
    rows = find(widLabels==wid_from_demo);
    
    agenum = str2num(ageDemo(w)); % convert string to numeric
    if ~isempty(agenum) % it's necessary to check because some entries are empty or non-numbers, like "prefer not to say"
        ageLabels(rows) = str2num(ageDemo(w));
    end
    
    countryLabels(rows) = {countryDemo{w}}; % convert to char and store in cell array
    genderLabels(rows) = {genderDemo{w}}; % convert to char and store in cell array
    maritalLabels(rows) = {maritalDemo{w}}; % convert to char and store in cell array
    parentLabels(rows) = {parentDemo{w}}; % convert to char and store in cell array
    
end

% now all of these labels have the same number of entries, in the same order, as cleanBag
cleanBag;
% whos widLabels ageLabels countryLabels genderLabels maritalLabels parentLabels true_categoryLabels pred_categoryLabels periodLabels 

%% Check some school related words

schoolWords = {'class','classroom', 'professor', 'college','school',...
'mate','homework','exam', 'test', 'quiz', 'grade', 'score'};

for i = 1:length(schoolWords) % check for variants
    cleanBag.Vocabulary(strmatch(schoolWords{i},cleanBag.Vocabulary))
end % variants are acceptable 

%% Make Histograms
figure; clf
topnum = length(schoolWords);
ageGroups = [[18:8:80]' [26:8:82]'];
ageWordCounts = zeros(length(schoolWords),size(ageGroups,1));
xticks = {};
for a = 1:size(ageGroups,1)
    age_idx = (ageLabels>=ageGroups(a,1))&(ageLabels<ageGroups(a,2));
    all_appearances = [];
    for b = 1:length(schoolWords)
        w = strmatch(schoolWords{b},cleanBag.Vocabulary,'exact'); % faster to use exact than loop through variants
        statements = find(cleanBag.Counts(age_idx,w));
        ageWordCounts(b,a) = length(unique(statements)); % count statments, not word appearances
        all_appearances = [all_appearances, statements'];
    end
    [sorted_ageWordCounts,order_ageWordCounts] = sort(ageWordCounts(:,a),'descend');
    subplot(2,4,a)
    bh1(a) = barh(sorted_ageWordCounts); hold on
    set(gca,'YTick',[1:topnum],'YTickLabels',schoolWords(order_ageWordCounts)); 
    xlabel('# statements')
    totalcount(a) = sum(age_idx); % 
    percent(a) = 100*length(unique(all_appearances))/totalcount(a);
    title(['Ages ' num2str(ageGroups(a,1)) '-' num2str(ageGroups(a,2)),', n = ',num2str(totalcount(a))]);
    text(0.7*max(sorted_ageWordCounts),9,[num2str(round(percent(a),2)),'%'],'Color','red','FontSize',14)
    
    xticks = {xticks num2str(ageGroups(a,1)) '-' num2str(ageGroups(a,2))};
end

mtit(gcf,'Mentions of "school" by age group','xoff',0,'yoff',.035,'fontsize',16); % this function is in the "helpers" folder

autoArrangeFigures

figure
bar(percent)
set(gca,'XTick',[1:topnum],'XTickLabels',{'18-26','26-34','34-42','42-50','50-58','66-74','74-82'});
xlabel('Age Group')
ylabel('Percentage of "School" Words')
title('Mention of school-related words by age group')

% From this graph it's inconclusive that the mention of school or
% school-related words as a source of happines is inversely proportional to
% the age group. One could make the statement that this is only the case
% when comparing people between 18-50 and 50-82. 
% The analyzed school-related words were: class,classroom, professor,
% college,school, mate, homework, exam, test, quiz , grade, score.