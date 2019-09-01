function [ matrixB ] = center( matrixX )
    dim = size(matrixX)-1;
    matrixB = matrixX(2:dim(1),2:dim(2));
end

