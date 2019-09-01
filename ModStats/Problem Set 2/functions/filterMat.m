function [evens,odds] = filterMat( matrix )
    dummy = rem(matrix,2);
    odds = matrix(find(dummy));
    evens = matrix(find(~dummy));
end

