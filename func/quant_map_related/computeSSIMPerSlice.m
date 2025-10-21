function ssimValues = computeSSIMPerSlice(vol1, vol2, sliceRange)
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

    % Validate slice range
    if any(sliceRange < 1) || any(sliceRange > size(vol1, 3))
        error('sliceRange is out of bounds.');
    end

    % Initialize output vector
    ssimValues = zeros(1, numel(sliceRange));
    fixed  = vol1;
    moving = vol2;
    [optimizer, metric] = imregconfig('monomodal'); % or 'multimodal' for MRI/CT
    registered = imregister(moving, fixed, 'rigid', optimizer, metric);

    % Loop through slices
    for i = 1:numel(sliceRange)
        sliceIdx = sliceRange(i);
        img1 = fixed(:, :, sliceIdx);
        img2 = registered(:, :, sliceIdx);
        % bmImage(cat(2, img1,img2));
        % Compute SSIM for this slice
        ssimValues(i) = ssim(img1, img2);
    end
end