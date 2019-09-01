function [ matrixC ] = diagonals( matrixX )
    matrixC = [diag(matrixX,1),diag(matrixX,-1)];
    
end
