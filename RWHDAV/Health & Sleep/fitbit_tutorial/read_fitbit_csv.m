
function [hr_value,hr_time,hr_date,steps_value,steps_time,steps_date] = read_fitbit_csv(filepath)


fitdata = readtable(filepath);

hr_idx = strmatch('heart rate',fitdata.type);
hr_value = fitdata.value(hr_idx);
hr_time = fitdata.time(hr_idx); % this is in seconds, 1 row per minute
hr_date = fitdata.date(hr_idx);
steps_idx = strmatch('steps',fitdata.type);
steps_value = fitdata.value(steps_idx);
steps_time = fitdata.time(steps_idx);
steps_date = fitdata.date(steps_idx);