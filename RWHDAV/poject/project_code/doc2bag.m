function [bag] = doc2bag(doc)
    doc = tokenizedDocument(doc);
    doc = erasePunctuation(doc);
    doc = removeWords(doc,stopWords);
    doc = lower(doc);
    doc = normalizeWords(doc);
    bag = bagOfWords(doc);
end