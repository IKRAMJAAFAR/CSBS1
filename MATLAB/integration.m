% Numerical Method - Numerical Integration in Forecasting
function area = integration(dataset, start, last, type, points)
    % Numerical integration based on the chosen method
    if strcmp(type, 'trapezoidal')
        area = trapezoidal(dataset, start, last);
    elseif strcmp(type, 'monteCarlo')
        area = monteCarlo(dataset, start, last, points);
    else
        error('Unknown integration type. Use "trapezoidal" or "monteCarlo".');
    end
end

% Trapezoidal Rule - given an interval
function area = trapezoidal(dataset, start, last)
    % Assumes dataset is a two-column matrix: [id, value]
    val_start = dataset(dataset(:, 1) == start, 2); % Find value at 'start'
    val_last = dataset(dataset(:, 1) == last, 2);   % Find value at 'last'

    if isempty(val_start) || isempty(val_last)
        error('Start or last point not found in the dataset.');
    end

    % Apply trapezoidal rule
    area = (last - start) * (val_last + val_start) / 2;
end

% Monte Carlo Integration - given an interval
function area = monteCarlo(dataset, start, last, points)
    % Assumes dataset is a two-column matrix: [id, value]
    max_y = max(dataset(:, 2)); % Maximum value in the dataset (y-axis)
    underCounter = 0;

    % Perform Monte Carlo simulation
    for i = 1:points
        val_x = rand() * (last - start) + start; % Random x within the interval
        val_y = rand() * max_y;                 % Random y within [0, max_y]
        fx = linearInterpolate(dataset, val_x); % Interpolated value at x

        if val_y <= fx
            underCounter = underCounter + 1;    % Count points under the curve
        end
    end

    % Compute area
    area = underCounter / points * (last - start) * max_y;
end

% Helper function for linear interpolation
function interpolate = linearInterpolate(dataset, x)
    % Assumes dataset is a two-column matrix: [id, value]
    % Find the two closest points to x
    lower_idx = find(dataset(:, 1) <= x, 1, 'last');
    upper_idx = find(dataset(:, 1) >= x, 1, 'first');

    if isempty(lower_idx) || isempty(upper_idx) || lower_idx == upper_idx
        error('Cannot interpolate: invalid x value or insufficient data.');
    end

    % Extract values
    x1 = dataset(lower_idx, 1);
    y1 = dataset(lower_idx, 2);
    x2 = dataset(upper_idx, 1);
    y2 = dataset(upper_idx, 2);

    % Linear interpolation formula
    interpolate = y1 + (x - x1) * (y2 - y1) / (x2 - x1);
end

