% j.chen september 2018
% adapted from:
% https://www.mathworks.com/help/textanalytics/examples/prepare-text-data-for-analysis.html
% HappyDB dataset: https://arxiv.org/pdf/1801.07746.pdf 
% https://rit-public.github.io/HappyDB/

%% step 0: cd to the HappyDB directory

clear all
close all
basepath = pwd
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
happydata(1:10,:) % display the table

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

% exercise 1:
% turn the text compilation commands above into a function
% include these parameters:
% opts.removeShortWords = 0;
% opts.removeLongWords = 15;
% opts.removeInfrequentWords = 2;
% opts.keep_these_words = {'i', 'my', 'me', 'we'};
% opts.remove_more_words = {'happi'}; % << this one is not implemented above
% example usage:
%   textFile = fullfile(basepath,'cleaned_hm.csv')
%   [cleanBag,idx] = preprocessTextData(textFile,opts)

%% 2. compare the raw data and the cleaned data 

% raw data:
rawDocuments = tokenizedDocument(textData);
rawBag = bagOfWords(rawDocuments);

% calculate the reduction in data
numWordsClean = cleanBag.NumWords;
numWordsRaw = rawBag.NumWords;
reduction = 1 - numWordsClean/numWordsRaw

% visualize the two bag-of-words models using word clouds
figure(1); clf
subplot(1,2,1)
wordcloud(rawBag);
title('Raw Data')
subplot(1,2,2)
wordcloud(cleanBag);
title('Clean Data')
autoArrangeFigures % this function is in the "helpers" folder
% download it from the MATLAB Central File Exchange

%% 3. load demographic data
demographic = readtable(fullfile(basepath,'data\data','demographic.csv'),'TextType','string');
demographic(1:10,:) % display the table
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
cleanBag
whos widLabels ageLabels countryLabels genderLabels maritalLabels parentLabels true_categoryLabels pred_categoryLabels periodLabels 

%% 5. how many statements were generated by each worker?
figure(2); clf
histogram(widLabels,500);
xlabel('MTurk Worker ID'); ylabel('Number of Statements Generated'); title('Histogram of # Statements by WID'); 
wid_counts = histcounts(widLabels,length(widLabels));
avg_num_statements = mean(wid_counts(wid_counts>0));
max_num_statements = max(wid_counts);
text(2000,1500,['Avg # statements: ' num2str(avg_num_statements)]);
text(2000,1400,['Max # statements: ' num2str(max_num_statements)]);
autoArrangeFigures

%% 6. what countries are people from? how many statements from each country?
countries = unique(countryLabels); countries = countries(2:end); % remove first cell, which is empty
countryCount = zeros(size(countries));
for c = 1:length(countries)
    countryCount(c) = length(strmatch(countries{c},countryLabels));
end

figure(3); clf
pie(countryCount,countries); title('How many statements from each country?');
autoArrangeFigures

% as a bar chart:
% figure(3); clf
% bar(countryCount); grid on
% set(gca,'XTick',[1:length(countries)],'XTickLabel',countries);
% title('How many statements from each country?');

%% 7. what are the categories of happy statements? how many statements from each category?
clear true_categoryCount pred_categoryCount

true_categories = unique(true_categoryLabels); true_categories = true_categories(2:end); % remove first cell, which is empty
true_categoryCount = zeros(size(true_categories));
for c = 1:length(true_categories)
    true_categoryCount(c) = length(strmatch(true_categories{c},true_categoryLabels));
end
true_cat_pietxt = strcat(true_categories,repmat(": ",size(true_categories)),num2str(true_categoryCount));

pred_categories = unique(pred_categoryLabels);
pred_categoryCount = zeros(size(pred_categories));
for c = 1:length(pred_categories)
    pred_categoryCount(c) = length(strmatch(pred_categories{c},pred_categoryLabels));
end
pred_cat_pietxt = strcat(pred_categories,repmat(": ",size(pred_categories)),num2str(pred_categoryCount));

figure(31); clf
subplot(1,2,1); pie(true_categoryCount,true_cat_pietxt); title('How many TRUE statements from each category?');
subplot(1,2,2); pie(pred_categoryCount,pred_cat_pietxt); title('How many PREDICTED statements from each category?');
autoArrangeFigures

%% 8. what are the top words by age group?
figure(4); clf
histogram(ageLabels);
xlabel('Age'); ylabel('Number of Statements'); title('Histogram of # Statements by Age');
topnum = 40;

ageGroups = [[18:8:80]' [26:8:82]']; 
for a = 1:size(ageGroups,1)
    age_idx = (ageLabels>=ageGroups(a,1))&(ageLabels<ageGroups(a,2));
    ageWordCounts = sum(cleanBag.Counts(age_idx,:),1);
    [sorted_ageWordCounts sortorder_ageWordCounts] = sort(ageWordCounts,'descend');
    sorted_ageWords = cleanBag.Vocabulary(sortorder_ageWordCounts);
    topWordsByAge{a} = sorted_ageWords(1:topnum);
    sorted_AWC(a,:) = sorted_ageWordCounts(1:topnum); % save this for later
    subplot(2,4,a)
    bh1(a) = barh(sorted_ageWordCounts(1:topnum)); hold on
    set(gca,'YTick',[1:topnum],'YTickLabels',topWordsByAge{a}); 
    % xlim([0 6000]); % try with and without this line
    title(['Ages ' num2str(ageGroups(a,1)) '-' num2str(ageGroups(a,2))]);
    xlabel('# statements')
end

% find words that are new for this age group and color the bars green
for a = 2:size(ageGroups,1)
    subplot(2,4,a)
    diffWords = setdiff(topWordsByAge{a},topWordsByAge{a-1});
    for d = 1:length(diffWords)
        b = strmatch(diffWords{d},topWordsByAge{a});
        bh2(a) = barh(b,sorted_AWC(a,b),'g');
    end
end
% find words that are going away for the next age group and color the bars red
for a = 1:size(ageGroups,1)-1
    subplot(2,4,a)
    diffWords = setdiff(topWordsByAge{a},topWordsByAge{a+1});
    for d = 1:length(diffWords)
        b = strmatch(diffWords{d},topWordsByAge{a});
        bh3(a) = barh(b,sorted_AWC(a,b),'r');
    end
end

subplot(2,4,4)
legend([bh2(4) bh3(4)],'new','disappearing');
mtit(gcf,'Top words by age group','xoff',0,'yoff',.035,'fontsize',16); % this function is in the "helpers" folder

autoArrangeFigures

%% exercises

% 1. write a function preprocessTextData to compile the text: see end of section 1
%
% 2. describe in plain english: what is in each field of cleanBag?
%
% 3. what are some possible sources of bias or confounds in the HappyDB dataset?
% for example, in what way is the subject assignment non-random?
% what are some possible demand characteristics?
%
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
% 5. how might the biases or confounds or demand characteristics from #3 affect your results?
%
% 6. challenge exercise (optional): come up with a question of your own and test it.
%
% submission format:
% upload a zipped folder containing 
% 1. your MATLAB code files; make sure that the figure for #4 is generated by this code
% 2. a text file or word doc containing answers to questions 2-5


% the below may come in handy:

% all of these labels have the same number of entries, in the same order, as cleanBag
cleanBag
whos widLabels ageLabels countryLabels genderLabels maritalLabels parentLabels true_categoryLabels pred_categoryLabels periodLabels cleanTextData

% create a sorted list of words
cleanWordCount = sum(cleanBag.Counts,1);
[sorted_cleanWordCountx] = sort(cleanWordCount,'descend');
sorted_Words = cleanBag.Vocabulary(sortorder_cleanWordCount);

% find a specific word in cleanBag
strmatch('went',cleanBag.Vocabulary); % "went" appears at position #1 in the vocabulary
strmatch('class',cleanBag.Vocabulary); % versions of "class" appear at several positions in the vocabulary
cleanBag.Vocabulary(strmatch('class',cleanBag.Vocabulary)) % list all the versions
strmatch('class',cleanBag.Vocabulary,'exact'); % sometimes you may want to use only exact match

v = strmatch('classsam',cleanBag.Vocabulary,'exact'); % where in the Vocabulary is this word?
w = find(cleanBag.Counts(:,v)); % which statements contain this word?
cleanTextData(w(1)) % display an example


    
    
    
    
    
    
    
    
    