function [ oddless ] = odds2zero( matrix )
    oddless = matrix.*~rem(matrix,2);
end

