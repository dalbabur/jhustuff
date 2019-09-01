function [docs] = sliding_window(documents, windowLength)
    P = length(documents)+1-windowLength;
    new_docs = cell(1,P);
    for i = 1:P
        new_docs{i} = [documents{i:i+windowLength-1}];
    end
    
    doc2 = tokenizedDocument(string(new_docs));
    doc2 = erasePunctuation(doc2);
    doc2 = removeWords(doc2,stopWords);
    doc2 = lower(doc2);
    docs = normalizeWords(doc2);
end