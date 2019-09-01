function [cleanBag,idx] = preprocessTextData(textFile,opts)
% load text data
fprintf('Loading text data.... ');
happydata = readtable(textFile);
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
% keep_these_words = {};
% keep_these_words = {'i', 'my', 'me', 'we'};
for i = 1:length(opts.keep_these_words)
    k = strmatch(opts.keep_these_words{i},myStopWords,'exact');
    myStopWords(k) = [];
end
myStopWords = [myStopWords, opts.remove_more_words];

fprintf('\nPreprocessing text data.... ');
% remove the stop words
cleanDocuments = removeWords(cleanDocuments,myStopWords);

% sometimes you will want to remove short words, eg with 2 or fewer characters
cleanDocuments = removeShortWords(cleanDocuments,opts.removeShortWords); % 2

% and/or long words, eg with 15 or greater characters
cleanDocuments = removeLongWords(cleanDocuments,opts.removeLongWords); % 15

% normalize the words using the Porter stemmer
cleanDocuments = normalizeWords(cleanDocuments);

% create a bag-of-words model
cleanBag = bagOfWords(cleanDocuments);

% you may want to remove words that don't appear often, eg that don't appear more than 2 times
cleanBag = removeInfrequentWords(cleanBag,opts.removeInfrequentWords); % 2

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

end