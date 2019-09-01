
% j.chen september 2018
% data from https://www.kaggle.com/mousehead/songlyrics/home

%% step 0: cd to the TextAnalytics directory

% clear all
% close all
% basepath = pwd
% [filepath,dirname] = fileparts(basepath);
% if ~strcmp(dirname,'TextAnalytics')
%     fprintf('Your current folder is not TextAnalytics -- make sure you are starting in the correct directory.\n');
% else
%     addpath(basepath);
% end
% % helper functions: https://www.dropbox.com/sh/yowqme68b0659jk/AAByvh--d64PfYj4oFACHVTOa?dl=0

%% load the song data
songdata = readtable('songdata.csv','TextType','string');

%% choose an artist

selected_artist = 'The Beatles'; 
% for example: Metallica, The Beatles, Britney Spears, Bob Dylan, Leonard Cohen
% Madonna, Nirvana, Michael Jackson

% extract lyrics for all songs by the selected artist
idx = strmatch(selected_artist,songdata.artist,'exact');


song_titles = songdata.song(idx);
lyrics = songdata.text(idx);
lyrics = erasePunctuation(lyrics);
lyrics = lower(lyrics);
token_lyrics = tokenizedDocument(lyrics);
        
% examine the lyrics
token_lyrics(1:10)

%% create the bag of words
myStopWords = stopWords; % stopWords is a function that returns a predefined list of stop words
keep_these_words = {};
% keep_these_words = {'i', 'my', 'me', 'we'};
for i = 1:length(keep_these_words)
    k = strmatch(keep_these_words{i},myStopWords,'exact');
    myStopWords(k) = [];
end
% remove the stop words
token_lyrics = removeWords(token_lyrics,myStopWords);
remove_more_words = {'oh'};
token_lyrics = removeWords(token_lyrics,remove_more_words);
% token_lyrics = normalizeWords(token_lyrics); % stemming is optional
lyrics_bag = bagOfWords(token_lyrics);
lyrics_bag = removeInfrequentWords(lyrics_bag,2);
[lyrics_bag,removed_idx] = removeEmptyDocuments(lyrics_bag);
song_titles(removed_idx) = []; % remove those rows from song_titles too

figure(1); clf
wordcloud(lyrics_bag);
title(['Lyrics of ' selected_artist])

cluster_sizes = [];
%% build LSA topic model

numComponents = 20;
myLSAmodel = fitlsa(lyrics_bag,numComponents);

dscores = myLSAmodel.DocumentScores;
distances = pdist(dscores,'cosine');
D = squareform(distances);

figure(2); clf
subplot(1,2,1)
imagesc(1-D); colorbar
title(['Song Similarity: ' selected_artist]);
xlabel('Song'); ylabel('Song');

% find song clusters

k = 6; % number of clusters that you want to find; you can play around with this
kidx = kmeans(D, k, 'Replicates', 5); % increasing the number of replicates might improve stability of solution
[sorted_kidx,I] = sort(kidx);
sorted_D = D(I,I);
subplot(1,2,2)
imagesc(1 - sorted_D); colorbar
title(['KMeans-Clustered Song Similarity: ' selected_artist]);
xlabel('Song (sorted)'); ylabel('Song (sorted)');

clear song_clusters
for m = 1:k
    song_clusters{m} = song_titles(kidx==m);
end

% record sizes of the clusters
for m = 1:k
    k_block_size(m) = sum(kidx==m);
end
k_block_size = sort(k_block_size);
cluster_sizes = [cluster_sizes; k_block_size];

%% you try it:

% pick 3 artists that you think are pretty different in terms of their lyrics
% make a word cloud for each one

% for example: Metallica, The Beatles, Britney Spears, Bob Dylan, Leonard Cohen
% Madonna, Nirvana, Michael Jackson
% extract lyrics for all songs by the selected artist

        
% examine the lyrics

% run the kmeans clustering a few times
% were the song clusters roughly similar each time? look in
% song_clusters{1}, song_clusters{2}, etc.

% can you think of an artist that you know has distinct types of lyrics,
% that would yield distinct clusters for this analysis? maybe someone who
% changed their lyrical style across their career?

% alternatively, you could build a single LSA model from the songs of two
% different artists, and see whether kmeans can detect that.


%% choose a word embedding:

emb_choice = 'wikipedia';

switch emb_choice
    
    case 'word2vec'
        % pre-trained word2vec word embedding (from Google, trained on Google News)
        % description & code: https://code.google.com/archive/p/word2vec/
        % direct download of FULL 3million word embeddings: https://drive.google.com/file/d/0B7XkCwpI5KDYNlNUTTlSS21pQmM/edit
        % SLIM 300k word embeddings: https://github.com/eyaler/word2vec-slim
        
        filename = "GoogleNews-vectors-negative300-SLIM.mat";
        load(filename);
        
    case 'glove'
        % pre-trained GloVe word embedding (from Stanford)
        % https://nlp.stanford.edu/projects/glove/
        
        % filename = "glove.6B.300d";
        filename = "glove.6B.50d"; % use this smaller one if the 300d is slow on your computer
        if exist(filename + '.mat', 'file') ~= 2
            emb = readWordEmbedding(filename + '.txt');
            save(filename + '.mat', 'emb', '-v7.3');
        else
            load(filename + '.mat')
        end
        
    case 'wikipedia'
        % MATLAB's pre-trained word embedding (unknown method, trained on Wikipedia)
        
        filename = "exampleWordEmbedding.vec";
        emb = readWordEmbedding(filename);
end

%% examine the word embedding

% how many dimensions? how many words in the vocabulary?
emb

%% try some distances and analogies

v_word = word2vec(emb,'senator');
vec2word(emb, v_word, 5) % find the 5 closest words in the embedding to v_result using vec2word

v_paris = word2vec(emb,'paris');
v_france = word2vec(emb,'france');
v_poland = word2vec(emb,'poland');
v_result = v_paris - v_france +  v_poland;
vec2word(emb, v_result, 5) % find the 5 closest words in the embedding to v_result using vec2word

% how close?
v_warsaw = word2vec(emb,'warsaw');
1 - pdist([v_france;v_poland],'cosine') % cosine similarity of two vectors
1 - pdist([v_result;v_warsaw],'cosine') % cosine similarity of two vectors

v_1 = word2vec(emb,'large');
v_2 = word2vec(emb,'enormous');
1 - pdist([v_1;v_2],'cosine') % cosine similarity of two vectors

v_1 = word2vec(emb,'elephant');
v_2 = word2vec(emb,'breakfast');
1 - pdist([v_1;v_2],'cosine') % cosine similarity of two vectors

v_king = word2vec(emb,'king');
v_man = word2vec(emb,'man');
v_woman = word2vec(emb,'woman');
v_result = v_king - v_man +  v_woman;
vec2word(emb, v_result, 5) % find the closest words in the embedding to v_result using vec2word

% they don't always work
v_1 = word2vec(emb,'mayor');
v_2 = word2vec(emb,'city');
v_3 = word2vec(emb,'country');
v_result = v_1 - v_2 +  v_3;
vec2word(emb, v_result, 5)

%% you try it:

% choose 3 different words and predict 2 synonyms for each one. are your
% synonyms in the top 5 closest words in the embedding? what about the other embeddings?

% come up with 3 analogies and predict the answer for each one. are your
% predictions in the top 5 words "guessed" by the embedding? what about the other embeddings?


%% what's the distribution of distances between words?

v_allwords = word2vec(emb,emb.Vocabulary(1:500)); % plotting the whole vocabulary might be too much for some people's laptops
corrmat_allwords = corr(v_allwords');

% Pearson Correlation Coefficient and Cosine Similarity are equivalent when X and Y have means of 0, 
% so we can think of Pearson Correlation Coefficient as de-meaned version of Cosine Similarity.
% pdist returns 1-cosine_similarity.
% try it both ways:
% dist_allwords = pdist(v_allwords-mean(v_allwords,2),'cosine'); % de-mean v_allwords
dist_allwords = pdist(v_allwords,'cosine'); % don't de-mean v_allwords

D = squareform(dist_allwords); % put the distances into 2d matrix format to match corrmat_allwords
v_corr_allwords = reshape(corrmat_allwords,[],1); % reshape into a vector for histogram plotting
cos_sim_allwords = reshape(1 - D,[],1); % reshape into a vector for histogram plotting

figure(3); clf
subplot(2,2,1)
imagesc(corrmat_allwords); colorbar; title('Pearson Correlation between all pairs of words');
xlabel('words'); ylabel('words');
subplot(2,2,2)
% imagesc(cos_sim_allwords); colorbar; title('1 - Cosine Similarity between all pairs of words');
plot(cos_sim_allwords,v_corr_allwords,'k.'); title('Correlation vs. Cosine Similarity');
xlabel('cosine similarity'); ylabel('correlation');
subplot(2,2,3)
histogram(v_corr_allwords); title('Distribution of Correlation');
xlabel('correlation'); ylabel('count');
subplot(2,2,4)
histogram(cos_sim_allwords); title('Distribution of Cosine Similarity');
xlabel('cosine similarity'); ylabel('count');

%% visualize some of the words as a text scatter plot

words = emb.Vocabulary(1:500);
V = word2vec(emb,words);

% reduce to 2 dimensions
fprintf('\nCalculating t-SNE...'); % https://www.oreilly.com/learning/an-illustrated-introduction-to-the-t-sne-algorithm
XY_tsne = tsne(V,'Verbose',1);
fprintf('\nCalculating MDS...'); % http://www.statsoft.com/Textbook/Multidimensional-Scaling
XY_mds = mdscale(pdist(V),2);
fprintf('\ndone.\n');

figure(4); clf
subplot(1,2,1)
textscatter(XY_mds,words); title('MDS');
subplot(1,2,2)
textscatter(XY_tsne,words); title('t-SNE');

% zoom in on the plots to see more of the words. similar words are nearby
% each other...

%% choose a few artists (that you think are different from each other)
% load('song_vectors.mat'); % 57650x50 i precalculated this in case you want to use it later- all artists all songs

artists = {'Britney Spears','Eminem','Leonard Cohen'}; 

% extract the word vectors and average for each song 
song_vectors = []; song_artists = []; song_titles = []; valid_words = [];
p = 1;
for n = 1:size(songdata,1)
%     if mod(n,1000)==0, fprintf([num2str(n) '\n']); end
    if ismember(songdata.artist{n},artists)
    lyrics = songdata.text(n);
    lyrics = erasePunctuation(lyrics);
    lyrics = lower(lyrics);
    lyrics = strsplit(lyrics);
    v_lyrics = word2vec(emb,lyrics); % word embedding for each word in this song
    % might want to check that a reasonable number of words were recognized
    valid_words(p) = length(lyrics(~isnan(v_lyrics(:,1))));
%     invalid_words(p) = lyrics(isnan(v_lyrics(:,1)));
    v_song = nanmean(v_lyrics,1); % average of word vectors for this song
    song_vectors(p,:) = v_song;
    song_artists{p} = songdata.artist{n};
    song_titles{p} = songdata.song{n};
    fprintf([num2str(n) ' ' song_artists{p} ' ' num2str(valid_words(p)) '\n']);
    p = p+1;
    end
end
fprintf('Done.\n');

%
fprintf('\nCalculating t-SNE...');
n = length(song_artists);
XY_tsne = tsne(song_vectors(1:n,:),'Verbose',1);

figure(3); clf
textscatter(XY_tsne,song_titles); title('t-SNE');
hold on
colors = 'brgcmky';
clear leg_h
for a = 1:length(artists)
    idx = strmatch(artists{a},song_artists);
    leg_h(a) = plot(XY_tsne(idx,1),XY_tsne(idx,2),[colors(a) '.'],'MarkerSize',16); hold on
end
legend(leg_h,artists)

%% you try it:

% choose 3 artists, 2 that you think are similar to each other and 1 that
% is different from the others. does the t-SNE visualization reflect your
% prediction?

% you can also try calculating the pairwise cosine similarity of all songs
% across your 3 selected artists. are your predicted "more similar" artists
% more similar to each other on average than they are to your predicted
% "different" artist?









