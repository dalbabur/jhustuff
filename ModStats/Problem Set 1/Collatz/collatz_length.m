%% 540.305 Problem Set 1: Matlab Introduction - Diego Alba
%% 7 Coding (and debugging!)

function length = collatz_length(start)
% This function finds the length of a Collatz sequence with the
% input value start.
% Note that start should be a natural number
if (floor(start) ~= start) || start < 0
    error('This function requires a natural number input.');
end
length = 0;
cur = start;
while cur > 1
    if rem(cur,2) == 1
        cur = cur*3 + 1;
    else
        cur = cur/2;
        %length = length + 1;  add to length should be out of the if
    end
%     if length < 2
%         cur
%     end
    length = length +1;
end
end