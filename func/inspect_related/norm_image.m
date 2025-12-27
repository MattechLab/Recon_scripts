function img1_scaled = norm_image(img1, clipRange)
    % img1: input image
    % clipRange: e.g. [0.1 1]

    if nargin < 2
        clipRange = [0 1];  % default behaviour = no clipping beyond [0,1]
    end
    
    if iscell(img1)
        % Preserve cell size/shape
        img1_scaled = cell(size(img1));
        for ii=1:numel(img1)
            img1_scaled{ii} = norm_image_single(img1{ii}, clipRange);
        end
    else
        img1_scaled = norm_image_single(img1, clipRange);
    end
    disp('normalization done!');
end


% --- helper for a single numeric matrix ---
function img_scaled = norm_image_single(img, clipRange)
    img = double(abs(img));

    % Normalize to [0, 1]
    minv = min(img(:));
    maxv = max(img(:));

    if maxv > minv
        img_scaled = (img - minv) / (maxv - minv);
    else
        % Constant image: avoid division by zero
        img_scaled = zeros(size(img));
    end

    % Clip to user range [a, b]
    a = clipRange(1);
    b = clipRange(2);

    % Ensure clipping range makes sense
    if a < 0 || b > 1 || a >= b
        error('clipRange must be within [0,1] and increasing, e.g. [0.1 1]');
    end

    % Clip values outside [a, b]
    img_scaled(img_scaled < a) = a;
    img_scaled(img_scaled > b) = b;

end