function showImagesSideBySide(orientation, sliceIdx, clim, varargin)
% showImagesSideBySide(orientation, sliceIdx, clim, img1, img2, ..., 'Titles', titles)
%   orientation : 'axial', 'coronal', or 'sagittal'
%   sliceIdx    : which slice index to display along chosen orientation
%   clim        : [min max] display range for imagesc ([] for auto)
%   imgN        : variable number of 3D complex images
%   'Titles'    : optional name-value argument, cell array of strings for subtitles
%
%   All images are aligned in magnitude to the last one passed in.

    % --- Parse inputs
    p = inputParser;
    addRequired(p, 'orientation', @(s)ischar(s) || isstring(s));
    addRequired(p, 'sliceIdx', @isscalar);
    addRequired(p, 'clim', @(x)isnumeric(x) && (isempty(x) || numel(x)==2));
    addParameter(p, 'Titles', {}, @(x)iscellstr(x) || isstring(x));

    [imgs, namevals] = parseImgsAndArgs(varargin{:});
    parse(p, orientation, sliceIdx, clim, namevals{:});
    titles = p.Results.Titles;

    nImgs = numel(imgs);
    if nImgs < 2
        error('Need at least 2 images to align.');
    end

    % --- Alignment
    ref = imgs{end};
    mags = cell(1, nImgs);

    for k = 1:nImgs
        img = imgs{k};
        if ndims(img) < 3
            error('Image %d is not 3D.', k);
        end

        if k < nImgs
            img_aligned = align_gt_to_recon_magnitude(img, ref);
        else
            img_aligned = abs(img); % reference unchanged
        end

        switch lower(orientation)
            case 'axial'
                mags{k} = img_aligned(:,:,sliceIdx);
            case 'coronal'
                mags{k} = rot90(squeeze(img_aligned(:,sliceIdx,:)));
            case 'sagittal'
                mags{k} = rot90(squeeze(img_aligned(sliceIdx,:,:)));
            otherwise
                error('Unknown orientation: %s. Use axial, coronal, or sagittal.', orientation);
        end
    end

    % --- Plot (using tiledlayout for no gaps)
    figure;
    t = tiledlayout(1, nImgs, 'Padding', 'none', 'TileSpacing', 'none');

    for k = 1:nImgs
        nexttile;
        imagesc(mags{k});
        axis image off;
        colormap(gray);
        if ~isempty(clim)
            caxis(clim);
        end
        if k <= numel(titles)
            title(titles{k}, 'Interpreter', 'none');
        else
            title(sprintf('Image %d', k));
        end
    end

    sgtitle(sprintf('%s slice %d (aligned to last image)', orientation, sliceIdx));
    cb = colorbar;
    cb.Layout.Tile = 'east'; % put shared colorbar on the right
end


function [imgs, namevals] = parseImgsAndArgs(varargin)
% Helper: separate images from name-value pairs
    isName = cellfun(@(x) ischar(x) || isstring(x), varargin);
    if any(isName)
        firstNameIdx = find(isName, 1, 'first');
        imgs = varargin(1:firstNameIdx-1);
        namevals = varargin(firstNameIdx:end);
    else
        imgs = varargin;
        namevals = {};
    end
end
