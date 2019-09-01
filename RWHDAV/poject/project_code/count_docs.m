function [counts] = count_docs(bag, doc)
    dummy = doc;
    dummy = cellfun(@(dummy) strsplit(dummy),dummy,'UniformOutput', false);
    counts = cell2mat(cellfun(@(dummy) full(encode(bag,dummy)),dummy,'UniformOutput',false)');
end