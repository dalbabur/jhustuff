function [ matrixA ] = odds( matrixX )
    dim = size(matrixX);
    matrixA = matrixX(1:2:dim(1),1:2:dim(2));
end

