% Main function

T = readtimetable('dataset.csv');  % Reads a CSV file into a table
disp(T)

dataset.day_of_week = day(T.timestamp, 'dayofweek');