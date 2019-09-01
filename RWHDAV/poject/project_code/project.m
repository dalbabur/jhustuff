%% Add folders

addpath(genpath('transcripts_segmented'))
addpath(genpath('subjects_folder_for_sherlock_tutorial'))
addpath(genpath('code'))
addpath(genpath('helpers'))

% add colormaps
colors = {'#ffffe0','#fffddb','#fffad7','#fff7d1','#fff5cd','#fff2c8','#fff0c4','#ffedbf','#ffebba','#ffe9b7','#ffe5b2','#ffe3af','#ffe0ab','#ffdda7','#ffdba4','#ffd9a0','#ffd69c','#ffd399','#ffd196','#ffcd93','#ffca90','#ffc88d','#ffc58a','#ffc288','#ffbf86','#ffbd83','#ffb981','#ffb67f','#ffb47d','#ffb17b','#ffad79','#ffaa77','#ffa775','#ffa474','#ffa172','#ff9e70','#ff9b6f','#ff986e','#ff956c','#fe916b','#fe8f6a','#fd8b69','#fc8868','#fb8567','#fa8266','#f98065','#f87d64','#f77a63','#f67862','#f57562','#f37261','#f37060','#f16c5f','#f0695e','#ee665d','#ed645c','#ec615b','#ea5e5b','#e85b59','#e75859','#e55658','#e45356','#e35056','#e14d54','#df4a53','#dd4852','#db4551','#d9434f','#d8404e','#d53d4d','#d43b4b','#d2384a','#cf3548','#cd3346','#cc3045','#ca2e43','#c72b42','#c52940','#c2263d','#c0233c','#be213a','#bb1e37','#ba1c35','#b71933','#b41731','#b2152e','#b0122c','#ac1029','#aa0e27','#a70b24','#a40921','#a2071f','#a0051c','#9d0419','#990215','#970212','#94010e','#91000a','#8e0006','#8b0000'};
colors = hex2rgb(erase(colors,'#'))/255;
colors50 = colors(1:2:end,:);

colors = {'#f0ffff','#e9fdfd','#e2fcfa','#dcf9f8','#d6f7f6','#d1f5f3','#ccf3f1','#c7efef','#c3eded','#beebeb','#bae8e9','#b7e5e8','#b2e3e6','#aedfe4','#acdde2','#a8dbe0','#a4d7de','#a1d5dc','#9ed1da','#9bcfd9','#98ccd7','#96c9d5','#93c6d4','#90c3d2','#8dc0d0','#8abdce','#88bacc','#85b8cb','#83b6c9','#81b3c7','#7eb0c5','#7cacc3','#7aa9c2','#77a7c0','#75a3be','#73a1bc','#719ebb','#6f9bb9','#6d99b7','#6b96b5','#6993b3','#6790b1','#658caf','#648bad','#6288ab','#6084a9','#5e82a7','#5c7fa5','#5a7ca3','#587aa1','#57779f','#55749d','#53719b','#526e99','#506b97','#4e6895','#4c6693','#4b6391','#49618e','#475e8c','#465b8a','#445988','#435685','#415483','#3f5081','#3e4e7f','#3c4c7c','#3a4979','#394777','#374475','#364173','#343f6f','#333d6d','#313a6b','#303868','#2f3566','#2d3362','#2c3160','#2a2e5d','#292b5a','#272957','#262754','#242551','#23224e','#22214b','#201e48','#1f1c44','#1e1b41','#1c183d','#1b1639','#191535','#181332','#16112e','#150f29','#150c25','#130921','#10061c','#0c0415','#06020d','#000000'};
colors = hex2rgb(erase(colors,'#'))/255;
colors100 = colors;
%% Load Scene Data

% Load data from Sherlock Segments
% interested in having duration of scenes and all words

[scene_docs, extras] = loadData();

w = 20;
train_bag = doc2bag(sliding_window(extras.all,w));

N = 100;
rng(0); ldaW = fitlda(train_bag,N);

descriptions = count_docs(train_bag,scene_docs);    
sceneTopics = transform(ldaW,descriptions);

figure
subplot(1,2,1); imagesc(sceneTopics')   
title('Scene Topic Distribution')
xlabel('Scene #')
ylabel('Topic #')
subplot(1,2,2); imagesc(corr(sceneTopics'));
title('Scene-Scene Topic Correlation')
xlabel('Scene #')
ylabel('Scene #')

figure; hold on; yyaxis left
uniqueness = -(nansum(corr(sceneTopics))-1);
[~,I]= sort(uniqueness);
ylabel('Uniqueness')
plot(uniqueness(I),'.-','MarkerSize',20)
yyaxis right
set(gca, 'ColorOrder', colors50,'NextPlot', 'replacechildren')
b1 = bar(sceneTopics(:,I)','stacked');
ylabel('Contribution')
% colormap(colors50); c = colorbar; c.Limits = [0 50]; c.Label.String = 'Scene';
xticks(1:1:N)
xticklabels(I)
xlabel('Topic #')
title('LDA Topic Analysis')

%% Wordclouds
[~,I2] = sort(sum(sceneTopics));
topics = [I(1) I(end-1) I2(1) I2(end)];
titles = {': Least Uniq',': Most Uniq',': Least Contr',': Most Contr'};

figure;
for i =1:length(topics)
    subplot(2,2,i) % two topics
    wordcloud(ldaW,topics(i));
    title("Topic " + string(topics(i))+titles{i})
end

%% Load Subject Recollection Data

% Load data for each subject

[subjects,recallQuality] = loadSubjects;
for i = 1:17
    dummy = {subjects(i).allscenes.transcript};
    dummy(cellfun(@(dummy) any(isnan(dummy)),dummy)) = {' '};
    recallection2.subject(i) = {count_docs(train_bag,dummy)};
end
clear dummy

%% Apply LDA Model to scene recollection
clear topicsRecalled2
for i = 1:17
    topicsRecalled2(:,:,i) = transform(ldaW,recallection2.subject{i});        
end

%% Correlate
for i = 1:17
    correlation(:,:,i) = corr(topicsRecalled2(:,:,i)',sceneTopics');
    diagonal(:,i) = diag(correlation(:,:,i));
end

%% Recall Quality
for i = 1:17
    for j = 1:50
        dummy = recallection2.subject{i};
        recallWords(i,j) = sum(dummy(j,:));
    end
end

%% Best and worst
[~,maxSub] = maxk(sum(diagonal),1);
[~,minSub] = mink(sum(diagonal),1);
subject = [maxSub fliplr(minSub)];

%% Conf. Matrix

for i = 1:length(subject)
    figure
    
    subplot(1,3,1)
    set(gca, 'ColorOrder', colors100,'NextPlot', 'replacechildren')
    bar(sceneTopics,1,'stacked')
    ylim([0 1])
    xlim([0.5 49.5])
    title("Topic Mixtures, Description")
    ylabel("Topic Probability")
    xlabel("Scene")
    
    subplot(1,3,2)
    set(gca, 'ColorOrder', colors100,'NextPlot', 'replacechildren')
    bar(topicsRecalled2(:,:,subject(i)),1,'stacked')
    ylim([0 1])
    xlim([0.5 49.5])
    title("Topic Mixtures, Subject " + string(subject(i)))
    ylabel("Topic Probability")
    xlabel("Scene")
%     legend("Topic " + string(1:46),'Location','northeastoutside')

    subplot(1,3,3)
    imagesc(correlation(:,:,subject(i))'); colorbar;
    xlabel('Recalled Scene')
    ylabel('Scene Description')
end
autoArrangeFigures

%% Similarity between subjects, within scene (recallection quality/consistency)

figure;
set(gcf, 'Position', get(0, 'Screensize'));
for i = 1:50
    subplot(5,10,i)
    set(gca, 'ColorOrder', colors100,'NextPlot', 'replacechildren')
    bar([sceneTopics(i,:)' squeeze(topicsRecalled2(i,:,:))]',1,'stacked')
    ylim([0 1])
    xlim([0.5 17.5])
end

%% Compare with Quality
figure;
subplot(1,3,1)
imagesc(diagonal'); colorbar
xlabel('Scene')
ylabel('Subject')
title('LDA Recallection Score')
subplot(1,3,2)
imagesc(recallQuality); colorbar
xlabel('Scene')
ylabel('Subject')
title('Manual Recallection Score')
subplot(1,3,3)
imagesc(corr(diagonal,recallQuality')); colorbar;
xlabel('Subject # LDA Recallection')
ylabel('Subject # Manual Recallection')
title('Recallection Score Correlation')

% also recall Words
figure
bar([mean(corr(extras.valence',diagonal))...
mean(corr(extras.valence',recallQuality'));
mean(corr(extras.arousal',diagonal))...
mean(corr(extras.arousal',recallQuality'));
mean(diag(corr(recallWords',diagonal)))...
mean(diag(corr(recallWords',recallQuality')))])
legend('LDA','Manual','Location','northwest')
ylabel('Average Subject Correlation')
xticklabels({'Valence','Arousal','# Words'})
title('What Influences Recallection Score?')
    
%% look at shift of topic vectors

for i = 1:50
    [~,C(i,:),~,D(i,:)] = kmeans(squeeze(topicsRecalled2(i,:,:))',1);
    dif(i,:) = C(i,:)-sceneTopics(i,:);
    shift(i) = norm(dif(i,:));
end

for i = 1:50
    for j = 1:17
        subjects_dif(i,:,j) = topicsRecalled2(i,:,j)-sceneTopics(i,:);
        subjects_shift(i,j) = norm(subjects_dif(i,:,j));
    end
end

figure; hold on
bar(shift+2*std(D'),'k')
bar(shift-2*std(D'),'w','EdgeColor','w')
plot(subjects_shift,'g.','MarkerSize',12)
plot([0 50], [0 0],'k--')
xlim([0 51])
xlabel('Scene #')
ylabel('Distance')
title('Shift in Recallections')

[gained, gained_topics] = maxk(dif',3);
[lost, lost_topics] = mink(dif',3);
figure; hold on
bg = bar(gained','stacked','FaceColor','flat');
bl = bar(lost','stacked','FaceColor','flat');
for i = 1:3
    bg(i).CData = colors100(gained_topics(i,:),:);
    bl(i).CData = colors100(lost_topics(i,:),:);
end
plot([0 50], [0 0],'k--')
xlabel('Scene #')
ylabel('Distance')
title('Compression of Topics')

span = 24;
[B,I] = sort(sum(dif));
only = [1:span,N-(span-1):N];
figure; hold on
set(gca, 'ColorOrder', colors50,'NextPlot', 'replacechildren')
ba = bar(dif(:,I(only))','stacked');
xticks(1:2*span)
xticklabels(I(only))
xlabel('Topic #')
ylabel('Distance')
title('Average Topic Shift')

% %% Same diff across subjects?
% % figure
% % imagesc(corr(subjects_shift)); colorbar; caxis([0 1])
% % 
% % figure
% % for i = 1:50
% %     subplot(5,10,i)
% %     imagesc(corr(squeeze(subjects_dif(i,:,:))))
% % end
% 
% %%
% [mapped_data, mapping] = compute_mapping([sceneTopics([2:27,29:50],:);sceneTopics([1,28],:)], 'Isomap',2,8);
% 
% figure
% hold on
% view(2)
% colors = {'#ffffe0','#fffad6','#fff5cc','#ffefc2','#ffeaba','#ffe5b2','#ffe0ab','#ffdaa3','#ffd59c','#ffd095','#ffca90','#ffc58a','#ffbf85','#ffb880','#ffb27c','#ffad78','#ffa775','#ffa072','#ff9a6e','#ff936b','#fd8d6a','#fb8768','#f98266','#f87c64','#f57762','#f37160','#f06b5f','#ee655d','#eb5f5b','#e85959','#e55457','#e14e55','#de4952','#da4450','#d73e4d','#d3394a','#ce3347','#ca2e43','#c52940','#c1243c','#bc1f38','#b71a34','#b3152f','#ae112a','#a80b24','#a2071f','#9c0418','#970112','#92010b','#8b0000'};
% colors = hex2rgb(erase(colors,'#'))/255;
% plot(mapped_data(:,1),mapped_data(:,2),'-o')
% for i = 1:50
%     text(mapped_data(i,1),mapped_data(i,2),['  ',num2str(i)]);
% end
% plot(mapped_data(51:100,1),mapped_data(51:100,2),'-o')
% for i = 51:100
%     text(mapped_data(i,1),mapped_data(i,2),['  ',num2str(i-50)]);
% end
% %% word topics
% 
% % topkWords = 5;
% % [maxs,index] = maxk(lda.TopicWordProbabilities,topkWords);
% % 
% % [topWords,ia,ic] = unique(index(1,:));
% % TWP = lda.TopicWordProbabilities(topWords,:);
% % [~,is] = sort(maxs(1,:),'descend');
% % figure
% % imagesc(TWP(:,is));
% % colormap(flipud(bone))
% % xticklabels(string(is))
% 
% %% Python stuff
% a = 1:50:900;
% b = 50:50:900;
% for i=1:18
%     C(a(i):b(i),:) = B(:,:,i);
% end
% 
%     C = sceneTopics;
%     cstr = cell(1, size(C, 1));
%     for row = 1:size(C, 1)
%     cstr(row) = {C(row, :)};
%     end
%     ndarray = py.numpy.array(cstr);
%     reducedPy = py.umap.UMAP(pyargs('n_neighbors',int32(50))).fit(ndarray);
%     reducedMat = double(py.array.array('d',py.numpy.nditer(reducedPy.embedding_)));
%     data(1,:) = reducedMat(1:2:end);
%     data(2,:) = reducedMat(2:2:end);
%     figure; plot(data(1,:),data(2,:),'o')
% 
%     
% figure;
% for i = 1:18
%     HDTOPICS = B(:,:,i);
%     
%     cstr = cell(1, size(HDTOPICS, 1));
%     for row = 1:size(HDTOPICS, 1)
%     cstr(row) = {HDTOPICS(row, :)};
%     end
%     ndarray = py.numpy.array(cstr);
%     reducedPy = py.umap.UMAP().fit(ndarray);
%     reducedMat = double(py.array.array('d',py.numpy.nditer(reducedPy.embedding_)));
% 
%     data(1,:) = reducedMat(1:2:end);
%     data(2,:) = reducedMat(2:2:end);
%     subplot(3,6,i)
%     plot(data(1,:),data(2,:),'o')
%     for j = 1:length(data)
%         text(data(1,j),data(1,j),[' ',num2str(j)]);
%     end
%     clear data cstr ndarray
% end
% 
