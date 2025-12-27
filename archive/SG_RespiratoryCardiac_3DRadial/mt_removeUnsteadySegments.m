function [data ,time] = mt_removeUnsteadySegments(data, time, Segment)
%
% Syntax:       [data, time] = mt_removeUnsteadySegments(data, time, Segment)
%
% Inputs:       data:          Input data matrix [2D, 3D, or 4D].
%               time:          Time vector corresponding to the data.
%               Segment:       Segments in a shot.
%
% Outputs:      data:          Data matrix with unsteady segments removed.
%               time:          Corresponding time vector with unsteady segments removed.
%
% Description: Removes unsteady segments from the data and time vectors by:
%              1. Identifying acceptable time segments based on a threshold.
%              2. Remove unsteady data.
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch
%
% Date:         Last Updated: 19.08.2024
%

timeThreshold =10;
timeSI = time(1:Segment:end);
% Find the indices of the time vector that are within the acceptable range
accepted = find(timeSI > timeThreshold & timeSI < timeSI(end) - timeThreshold);

% Calculate the first and last values for the acceptable range
first_value = (accepted(1) - 1) * Segment + 1;
last_value = accepted(end) * Segment;

% Get the dimensions of the input data
dims = ndims(data);

% Adjust the slicing based on the number of dimensions
switch dims
    case 2
        % For 2D data, slice the 2nd dimension
        data = data(:, first_value:last_value);

    case 3
        % For 3D data, slice the 2nd dimension
        data = data(:, first_value:last_value, :);

    case 4
        % For 4D data, slice the 2nd dimension
        data = data(:, first_value:last_value, :, :);

    otherwise
        error('Unsupported number of dimensions. This function supports only 2D, 3D, or 4D data.');
end

time=time(:,first_value:last_value);
end