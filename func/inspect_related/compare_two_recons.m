function out = compare_two_recons(x1, x2, varargin)
%COMPARE_TWO_RECONS Compare two 3D recon volumes already in the workspace.
%
% Usage:
%   out = compare_two_recons(x_clean, x_clean05);
%   out = compare_two_recons(x1, x2, 'Show', true, 'AxialOffset', 8);
% 1) HOW TO CALL THIS
% =========================
% Minimal (most common):
%   out = compare_two_recons(x1, x2);
%
% With name-value options:
%   out = compare_two_recons(x1, x2, 'Show', false);
%   out = compare_two_recons(x1, x2, 'AxialStart', 80, 'AxialEnd', 140, 'AxialInc', 5);
%   out = compare_two_recons(x1, x2, 'UseRobustClim', true, 'RobustPct', 99);
%
% Requires your functions:
%   - norm_image()   : normalize a single 3D volume
%   - diff_vol()     : compute difference volume (img1 - img2) or whatever you defined
%   - bmImage()      : display helper
%
% Output:
%   out: struct with normalized volumes, derived planes, diff maps, montages.

%% ---------------- Input checks ----------------
if nargin < 2
    error('compare_two_recons requires two input volumes: compare_two_recons(x1, x2)');
end
validateattributes(x1, {'numeric'}, {'3d','nonempty'}, mfilename, 'x1', 1);
validateattributes(x2, {'numeric'}, {'3d','nonempty'}, mfilename, 'x2', 2);

ip = inputParser;
ip.addParameter('Show', true, @(x)islogical(x) && isscalar(x));

% Axial montage (your script values)
ip.addParameter('AxialOffset', 0, @(x)isnumeric(x) && isscalar(x));
ip.addParameter('AxialStart',  210, @(x)isnumeric(x) && isscalar(x));
ip.addParameter('AxialEnd',   270, @(x)isnumeric(x) && isscalar(x));
ip.addParameter('AxialInc',     10, @(x)isnumeric(x) && isscalar(x));

% Sagittal montage
ip.addParameter('SagStart', 105, @(x)isnumeric(x) && isscalar(x));
ip.addParameter('SagEnd',  150, @(x)isnumeric(x) && isscalar(x));
ip.addParameter('SagInc',   10, @(x)isnumeric(x) && isscalar(x));

% Coronal montage
ip.addParameter('CorStart', 150, @(x)isnumeric(x) && isscalar(x));
ip.addParameter('CorEnd',  200, @(x)isnumeric(x) && isscalar(x));
ip.addParameter('CorInc',   10, @(x)isnumeric(x) && isscalar(x));

% Diff display scaling (optional)
ip.addParameter('UseRobustClim', false, @(x)islogical(x) && isscalar(x)); % if you want percentile-based caxis
ip.addParameter('RobustPct', 99, @(x)isnumeric(x) && isscalar(x) && x>0 && x<=100);

ip.parse(varargin{:});
opt = ip.Results;

%% ---------------- Normalize (single-image normalization) ----------------
img1_trans = norm_image(x1);
img2_trans = norm_image(x2);

% Derived planes (same conventions you had)
img1_sag = norm_image(rot90(permute(img1_trans, [1, 3, 2]), 1));
img2_sag = norm_image(rot90(permute(img2_trans, [1, 3, 2]), 1));

img1_cor = norm_image(permute(img1_trans, [3, 2, 1]));
img2_cor = norm_image(permute(img2_trans, [3, 2, 1]));

% Stacked compare (top/bottom)
img_1_2_trans = cat(1, img1_trans, img2_trans);
img_1_2_sag   = cat(1, img1_sag,   img2_sag);
img_1_2_cor   = cat(1, img1_cor,   img2_cor);

%% ---------------- Diffs ----------------
ax_diff  = diff_vol(img1_trans, img2_trans);
sag_diff = diff_vol(img1_sag,   img2_sag);
cor_diff = diff_vol(img1_cor,   img2_cor);

%% ---------------- Montages ----------------
axStart = opt.AxialStart + opt.AxialOffset;
axEnd   = opt.AxialEnd   + opt.AxialOffset;

ax_montage      = buildSliceMontage(img_1_2_trans, axStart, axEnd, opt.AxialInc);
ax_diff_montage = buildSliceMontage(ax_diff,       axStart, axEnd, opt.AxialInc);

sag_montage      = buildSliceMontage(img_1_2_sag, opt.SagStart, opt.SagEnd, opt.SagInc);
sag_diff_montage = buildSliceMontage(sag_diff,    opt.SagStart, opt.SagEnd, opt.SagInc);

cor_montage      = buildSliceMontage(img_1_2_cor, opt.CorStart, opt.CorEnd, opt.CorInc);
cor_diff_montage = buildSliceMontage(cor_diff,    opt.CorStart, opt.CorEnd, opt.CorInc);

%% ---------------- Display ----------------
if opt.Show
    % quick overview
    bmImage(img_1_2_trans);

    % axial
    close all;
    bmImage(ax_montage);
    showDiffFigure(ax_diff_montage, ax_diff, 'Axial', axStart, axEnd, opt.AxialInc, opt);

    % sagittal
    bmImage(sag_montage);
    showDiffFigure(sag_diff_montage, sag_diff, 'Sagittal', opt.SagStart, opt.SagEnd, opt.SagInc, opt);

    % coronal
    bmImage(cor_montage);
    showDiffFigure(cor_diff_montage, cor_diff, 'Coronal', opt.CorStart, opt.CorEnd, opt.CorInc, opt);
end

%% ---------------- Pack outputs ----------------
out = struct();
out.opts = opt;

out.norm = struct( ...
    'img1_trans', img1_trans, 'img2_trans', img2_trans, 'img_1_2_trans', img_1_2_trans, ...
    'img1_sag',   img1_sag,   'img2_sag',   img2_sag,   'img_1_2_sag',   img_1_2_sag, ...
    'img1_cor',   img1_cor,   'img2_cor',   img2_cor,   'img_1_2_cor',   img_1_2_cor);

out.diff = struct('axial', ax_diff, 'sagittal', sag_diff, 'coronal', cor_diff);

out.montage = struct( ...
    'axial',         ax_montage,      'axial_diff',    ax_diff_montage, ...
    'sagittal',      sag_montage,     'sagittal_diff', sag_diff_montage, ...
    'coronal',       cor_montage,     'coronal_diff',  cor_diff_montage);

end

%% ================= Local helpers =================
function M = buildSliceMontage(V, sl_start, sl_end, inc)
% Concatenate slices left->right.
sl_start = max(1, round(sl_start));
sl_end   = min(size(V,3), round(sl_end));
inc      = max(1, round(inc));

if sl_start > sl_end
    error('Invalid slice range: start (%d) > end (%d).', sl_start, sl_end);
end

M = V(:,:,sl_start);
for s = (sl_start+inc):inc:sl_end
    M = cat(2, M, V(:,:,s));
end
end

function showDiffFigure(montage2D, diffVol, planeName, sl_start, sl_end, inc, opt)
figure('Color','white'); ax = gca; ax.Color = 'white';
imagesc(montage2D); axis image off;
colormap(getRedBlue(256)); colorbar;

clim = getClim(diffVol, opt);
if clim > 0
    caxis([-clim, clim]);
end
title(sprintf('%s diff (img1 - img2), slices %d:%d:%d', planeName, sl_start, inc, sl_end));
end

function clim = getClim(V, opt)
A = abs(V(:));
A = A(isfinite(A));
if isempty(A)
    clim = 1;
    return;
end

if opt.UseRobustClim
    % percentile-based limit (no toolbox)
    A = sort(A);
    k = max(1, round((opt.RobustPct/100) * numel(A)));
    clim = A(k);
else
    clim = max(A);
end
end

function cmap = getRedBlue(n)
% Simple diverging red-blue colormap (no external dependency).
if nargin < 1, n = 256; end
n = max(2, round(n));
t = linspace(0,1,n)';

r = min(1, 2*t);
b = min(1, 2*(1-t));
g = 1 - abs(2*t - 1);

cmap = [r g b];
end