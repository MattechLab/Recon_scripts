function img1_scaled = norm_image(img1, clipRange)
    % img1: input image
    % clipRange: e.g. [0.1 1]

    if nargin < 2
        clipRange = [0 1];  % default behaviour = no clipping beyond [0,1]
    end

    img1 = double(abs(img1));

    % Normalize to [0, 1]
    img1_scaled = (img1 - min(img1(:))) / (max(img1(:)) - min(img1(:)));
    disp('normalization done!')
    % Clip to user range [a, b]
    a = clipRange(1);
    b = clipRange(2);

    % Ensure clipping range makes sense
    if a < 0 || b > 1 || a >= b
        error('clipRange must be within [0,1] and increasing, e.g. [0.1 1]');
    end

    % Clip values outside [a, b]
    img1_scaled(img1_scaled < a) = a;
    img1_scaled(img1_scaled > b) = b;
end