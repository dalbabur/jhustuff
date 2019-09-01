function [ detector ] = activity( acc, ~ )
    high = 55;
    low = 20;
    len = length(acc);
    detector = zeros(len, 1);
    
    for i = 1:len
        if acc(i) < low
            detector(i) = 0;
        elseif acc(i) > high || (i > 0 && detector(i-1) == 1 && acc(i)>low)
            detector(i) = 1;
        else
            detector(i) = 0.5;
        end
    end
end

