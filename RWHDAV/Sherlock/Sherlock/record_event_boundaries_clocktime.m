
% record_event_boundaries_clocktime

function output = record_event_boundaries_clocktime

fprintf('Press enter to synchronize: ');
pause

output.sync_time = clock;

output.keytime = [];

while 1
    key = input('\nPress enter to record an event boundary (q to quit): ','s');
    output.keytime = [output.keytime; clock];
    if strcmp(key,'q')
        break
    end
end

save(['diego_eventbounds_' datestr(now,'yyyymmddTHHMMSS') '.mat']);
