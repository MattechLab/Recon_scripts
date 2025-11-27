function [data] = mt_removeSI(data, Segment)
%
% Syntax:       [data] = mt_removeSI(data, Segment)
%
% Inputs:       data:          Input data array, either 2D [nx, ntviews] or 3D [nx, ntviews, X].
%               Segment:       Segment of each Shot.
%
% Outputs:      data:          Modified data array with SI readout removed.
%
% Description: Remove SI projection from input data
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch  
%
% Date:         Last Updated: 19.08.2024
%


dims = ndims(data);

if dims == 2

    data(:, 1:Segment:end) = [];
elseif dims == 3

    data(:, 1:Segment:end, :) = [];
else
    error('The function only supports 2D or 3D arrays.');
end

end
