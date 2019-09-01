
% j.chen october 2018
% week 5 homework 
% data from https://www.kaggle.com/mousehead/songlyrics/home

%% step 0: cd to the TextAnalytics directory
% 
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

%% select artist
artists = {'The Beatles'};
% artists = {'Metallica'};

%% choose a word embedding:

emb_options = {'word2vec','glove','wikipedia'};

for x = 1:3
    
    emb_choice = emb_options{x};
    
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
    
    %% create correlation matrix
    
    songvec.(emb_choice) = song_vectors;
    corrmat.(emb_choice) = corr(song_vectors');
    
end

%% examine the song vectors

% exercise 1: plot the song vectors for each word embedding.
% what's represented on the x-axis?
% are the inter-song correlations similar to each other across the
% different word embeddings?

% The x axis represent each of the dimensions of the low-dimensional
% embedding space the algorith found by examing each of the word's 
% surrounding context.

% The correlations are different across different word embeddings since 
% the algorithms and vocabulary for each differ. 

figure(1)
subplot(3,1,1)
imagesc(songvec.word2vec)
title('word2vec song vectors')
ylabel('songs')
colorbar
subplot(3,1,2)
imagesc(songvec.glove)
title('glove song vectors')
ylabel('songs')
colorbar
subplot(3,1,3)
imagesc(songvec.wikipedia)
title('Wikipedia song vectors')
ylabel('songs')
colorbar

% exercise 2:
% figure 1, top row: calculate the pairwise correlations between song
% vectors for each word embedding; plot the 3 correlation matrices

figure(2)
subplot(3,3,1)
imagesc(corr(songvec.word2vec'))
title('word2vec correlation matrix')
colorbar
caxis([0.6 1])
subplot(3,3,2)
imagesc(corr(songvec.glove'))
title('glove correlation matrix')
colorbar
caxis([0.9 1])
subplot(3,3,3)
imagesc(corr(songvec.wikipedia'))
title('wikipedia correlation matrix')
colorbar
caxis([0.6 1])

% exercise 3:
% figure 1, middle row: extract the upper triangular of each correlation
% matrix (all entries above the diagonal).
% you will need to read about the function "triu"; use it to create an
% index matrix to extract the values you want.
% plot a histogram for each matrix.

corrW2V = triu(corr(songvec.word2vec'),1);
corrG = triu(corr(songvec.glove'),1);
corrW = triu(corr(songvec.wikipedia'),1);

figure(2)
subplot(3,3,4)
histogram(nonzeros(corrW2V))
title('word2vec corr distribution')
subplot(3,3,5)
histogram(nonzeros(corrG))
title('glove corr distribution')
subplot(3,3,6)
histogram(nonzeros(corrW))
title('wikipedia corr distribution')

% exercise 4:
% figure 1, bottom row: 
% using the 3 sets of values that you extracted above (the upper triangular),
% plot a scatter plot for each pair.

figure(2)
subplot(3,3,7)
plot(nonzeros(corrW2V),nonzeros(corrG),'k.')
title('word2vec vs glove')
xlabel('word2vec')
ylabel('glove')
grid on
gca.XTick = 0:0.2:1;
gca.Ytick = 0:0.2:1;
subplot(3,3,8)
plot(nonzeros(corrW2V),nonzeros(corrW),'k.')
title('word2vec vs wikipedia')
xlabel('word2vec')
ylabel('wikipedia')
grid on
gca.XTick = 0:0.2:1;
gca.Ytick = 0:0.2:1;
subplot(3,3,9)
plot(nonzeros(corrG),nonzeros(corrW),'k.')
title('glove vs wikipedia')
xlabel('glove')
ylabel('wikipedia')
grid on
gca.XTick = 0:0.2:1;
gca.Ytick = 0:0.2:1;

% bonus question:
% why are there distinct clusters of points in the scatter plots?
    
    









