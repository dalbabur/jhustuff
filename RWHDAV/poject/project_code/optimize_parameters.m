function [dataSub,sceneTopics,extras] = optimize_parameters(scenes,all,w,N,subjects,recallQ)
for k = 1:length(w)
    train_bag = doc2bag(sliding_window(all,w(k)));
    descriptions = count_docs(train_bag,scenes);
    
    for j = 1:length(N)
        rng(0)
        ldaTEST = fitlda(train_bag,N(j));
        sceneTopics(j,k) = {transform(ldaTEST,descriptions)};
        extras.lda(j,k) = {ldaTEST};

        for i = 1:17
            dummy = {subjects(i).allscenes.transcript};
            dummy(cellfun(@(dummy) any(isnan(dummy)),dummy)) = {' '};
            recallection.subject(i) = {count_docs(train_bag,dummy)};

            topicsRecalled(:,:,i) = transform(ldaTEST,recallection.subject{i});
            correlation(:,:,i) = corr(topicsRecalled(:,:,i)',sceneTopics{j,k}');
            diagonal(:,i) = diag(correlation(:,:,i));
        end   
        
        dataSub(:,j,k) = diag(corr(diagonal,recallQ'));
        dataSce(:,j,k) = diag(corr(diagonal',recallQ));  
        clear topicsRecalled correlation diagonal recollection
    end
    extras.w = w;
    extras.N = N;
end
end
