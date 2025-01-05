% Preprocessing Steps
function [shift_standard_val, trend, seasonal, remain, trainData, valData, testData] = preprocessing(dataset, columnToStandard)
    % Step 1: Standardize the specified column
    shift_standard_val = scaling(dataset, columnToStandard);
    
    % Step 2: Extract trend from the dataset
    [trend, seasonal, remain] = timeseries_Extract(dataset(:, 'value'));
    
    % Step 3: Split the dataset into training, validation, and testing sets
    [trainData, valData, testData] = split(dataset);
end

% 1. Trend extraction
function [trend, seasonal, remain] = timeseries_Extract(column)
    % Decompose the time-series data into trend using STL
    % Requires MATLAB's MathWorks toolkits like Econometrics Toolbox
    if ~isvector(column)
        error('Trend extraction requires a vector input.');
    end
    
    % Example using STL decomposition (seasonal-trend decomposition)
    [trend, seasonal, remain] = trenddecomp(column, 'stl', 'Period', 24 * 2 * 7); % Weekly period
end

% 2. Scaling Data
function shift_standard_val = scaling(dataset, columnToScale)
    % Extract the column to standardize
    col = dataset(:, columnToScale); % Extract column as vector

    minimum = min(col);
    maximum = max(col);
    range = maximum - minimum;

    shift_standard_val = (col - minimum) / range;

end

function dataset = lag(dataset, columnToLag, num_lags)
    % Adds lagged columns and fills missing values in a timetable.
    % Inputs:
    % - dataset: The timetable containing the data.
    % - columnToLag: The name of the column to create lagged values for (as a string).
    % - num_lags: Number of lagged columns to create.
    % Output:
    % - dataset: The updated timetable with lagged columns and filled missing values.

    % Create lagged columns
    for lag = 1:num_lags
        lagged_column_name = sprintf('lag_%d', lag);
        dataset.(lagged_column_name) = [nan(lag, 1); dataset{1:end-lag, columnToLag}];
    end

    % Add day_of_week and hour columns
    dataset.day_of_week = day(dataset.timestamp, 'dayofweek'); % 1 (Sunday) to 7 (Saturday)
    dataset.hour = hour(dataset.timestamp) + minute(dataset.timestamp) / 60;

    % Fill missing values for each lagged column
    for lag = 1:num_lags
        lagged_column_name = sprintf('lag_%d', lag);
        
        % Group by day_of_week and hour, calculate mean ignoring NaN
        group_means = varfun(@mean, dataset, ...
            'InputVariables', lagged_column_name, ...
            'GroupingVariables', {'day_of_week', 'hour'});
        
        % Create mapping of group means
        for i = 1:height(group_means)
            day = group_means.day_of_week(i);
            hr = group_means.hour(i);
            mean_value = group_means.(sprintf('mean_%s', lagged_column_name))(i);
            
            % Find missing values in the lag column and corresponding groups
            idx = isnan(dataset.(lagged_column_name)) & ...
                  dataset.day_of_week == day & ...
                  dataset.hour == hr;
            
            % Replace NaNs with the corresponding mean value
            dataset.(lagged_column_name)(idx) = mean_value;
        end
    end
end



% 4. Splitting Data
function [trainData, valData, testData] = split(dataset)
    % Split data into (60%-20%-20%) for training, validation, and testing
    n = size(dataset, 1); % Number of rows
    trainIdx = round(0.6 * n);
    valIdx = round(0.8 * n);
    
    % Splitting
    trainData = dataset(1:trainIdx, :);
    valData = dataset(trainIdx+1:valIdx, :);
    testData = dataset(valIdx+1:end, :);
end
