function [shift_standard_val, trend, seasonal, remain, trainData, valData, testData] = preprocessing(dataset, columnToStandard)
    % Preprocessing Steps
    % Step 1: Standardize the specified column
    shift_standard_val = standardize(dataset, columnToStandard);
    
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

function shifted = shift_non_negative(dataset)
    minimum = min(dataset);
    shifted = dataset - minimum;
end

% 2. Standardize Data
function shift_standard_val = standardize(dataset, columnToStandard)
    % Extract the column to standardize
    col = dataset(:, columnToStandard); % Extract column as vector
    
    % Calculate mean and standard deviation
    avr = mean(col);                    % Mean
    standarddev = std(col);             % Standard deviation
    
    % Standardize the column
    dev = col - avr;                    % Deviation from mean
    standardval = dev / standarddev;    % Standardized values

    shift_standard_val = shift_non_negative(standardval);
end

% 3. Splitting Data
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
