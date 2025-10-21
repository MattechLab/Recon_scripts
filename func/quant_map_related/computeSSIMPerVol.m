function ssimValue = computeSSIMPerVol(vol1, vol2)
% computeSSIMPerSlice - Compute SSIM between corresponding slices of two 3D volumes.
%
% Syntax:
%   ssimValues = computeSSIMPerSlice(vol1, vol2, sliceRange)
%
% Inputs:
%   vol1       - 3D volume (numeric array)
%   vol2       - 3D volume (numeric array)
%   sliceRange - Vector specifying slice indices to evaluate (e.g. 10:50)
%
% Output:
%   ssimValues - Vector of SSIM values for each slice pair in the range
%
% Example:
%   ssimVals = computeSSIMPerSlice(vol1, vol2, 1:100);
%   plot(1:100, ssimVals); xlabel('Slice'); ylabel('SSIM');

    % Check input dimensions
    if ndims(vol1) ~= 3 || ndims(vol2) ~= 3
        error('Both inputs must be 3D volumes.');
    end

    if ~isequal(size(vol1), size(vol2))
        error('Input volumes must be the same size.');
    end


    % Initialize output vector

    vol1n = mat2gray(vol1);
    vol2n = mat2gray(vol2);
    fixed  = vol1n;
    moving = vol2n;
    [optimizer, metric] = imregconfig('monomodal'); % or 'multimodal' for MRI/CT
    registered = imregister(moving, fixed, 'rigid', optimizer, metric);
    % bmImage(cat(2, registered,fixed));

    ssimValue = multissim3(registered, fixed);

end