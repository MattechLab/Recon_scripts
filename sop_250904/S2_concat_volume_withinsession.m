%% The workflow of post-processing
% Yiwei Jia Sept 15.
% import all the x images needed into the workspace manually
% align the image to the first image as reference
% save all the images into a cell
% bmImage to inspect the concatenated results
% slice the image volumes and calculate the diff map

close all;clc
x1 = norm_image(x1);
x2_aligned = align_gt_to_recon_magnitude(norm_image(x2),x1);
x3_aligned = align_gt_to_recon_magnitude(norm_image(x3),x1);
xidea_aligned = align_gt_to_recon_magnitude(norm_image(flip(flip(flip(x_idea,1),2),3)),x1);
x0905_aligned = align_gt_to_recon_magnitude(norm_image(permute(x0905, [2,1,3])),x1);

x = {x1, x2_aligned, x3_aligned, xidea_aligned, x0905_aligned};
%%

x1_trans = permute(x{1}, [2,1,3]);
x1_sag = rot90(permute(x1_trans, [1,3,2]), 1);
x1_coronal = permute(x1_trans, [3,2,1]);
bmImage(x1_trans);
bmImage(x1_sag);
bmImage(x1_coronal);
%
x2_trans = permute(x{5}, [2,1,3]);
x2_sag = rot90(permute(x2_trans, [1,3,2]),1);
x2_coronal = permute(x2_trans, [3,2,1]);
bmImage(x2_trans);
bmImage(x2_sag);
bmImage(x2_coronal);
%


%%
[img1_trans, img2_trans] = norm_two_image(x1_trans,x2_trans);
img_1_2_trans = cat(1,img1_trans, img2_trans);
bmImage(img_1_2_trans)

[img1_sag, img2_sag] = norm_two_image(x1_sag,x2_sag);
img_1_2_sag = cat(1,img1_sag, img2_sag);
bmImage(img_1_2_sag)

% img_trans_sag = cat(2,img_1_2_trans, img_1_2_sag);
% bmImage(img_trans_sag);

%% ===== transverse ====================
% close all;
sl_start = 90;
inc=10;
sl_end=120;
show_image = img2_trans(:,:,sl_start);
% show_image = img_1_2_trans(:,:,sl_start);

for slice = (sl_start+inc):inc:sl_end
    % show_image = cat(2,[show_image, img_1_2_trans(:,:,slice)]);
    show_image = cat(2,[show_image, img2_trans(:,:,slice)]);
end
% bmImage(show_image);
figure;
imagesc(show_image);
axis image off;
clim=[0,0.4];
colormap(gray);
if ~isempty(clim)
    caxis(clim);
end

%%
diff_map = diff_volume(img1_trans,img2_trans);
show_diff_image = diff_map(:,:,sl_start);
for slice_idx = sl_start+inc:inc:sl_end
show_diff_image = cat(2,[show_diff_image, diff_map(:,:,slice_idx)]);
end

figure('Color', 'white'); set(gca, 'Color', 'white'); 
imshow(show_diff_image);
colorbar;colormap('redblue'); caxis([-max(abs(diff_map(:))), max(abs(diff_map(:)))]);

% loLev = -1;upLev = 0.1;[imClip, rgb_vec] = relaxationColorMap('T1', show_diff_image, loLev, upLev);
% figure('Color', 'white'); set(gca, 'Color', 'white'); 
% imshow(imClip, 'DisplayRange', [loLev, upLev], 'InitialMagnification', 'fit'); 
% % title(strcat('difference map-', num2str(slice_idx)));
% colormap(rgb_vec); colorbar;

%% ===== sagittal left====================

sl_start = 100;
inc=10;
sl_end=140;

show_image = img_1_2_sag(:,:,sl_start);

for slice = (sl_start+inc):inc:sl_end
    show_image = cat(2,[show_image, img_1_2_sag(:,:,slice)]);
end
bmImage(show_image);

%%
diff_map = diff_volume(img1_sag,img2_sag);
show_diff_image = diff_map(:,:,sl_start);
for slice_idx = sl_start+inc:inc:sl_end
show_diff_image = cat(2,[show_diff_image, diff_map(:,:,slice_idx)]);
end

figure('Color', 'white'); set(gca, 'Color', 'white'); 
imshow(show_diff_image);
colorbar;colormap('redblue'); caxis([-max(abs(diff_map(:)))/4*3, max(abs(diff_map(:)))/4*3]);

%% ====coronal ====
sl_start = 94;
inc=4;
sl_end=110;

show_image = img_1_2_sag(:,:,sl_start);

for slice = (sl_start+inc):inc:sl_end
    show_image = cat(2,[show_image, img_1_2_sag(:,:,slice)]);
end
bmImage(show_image);


diff_map = diff_volume(img1_sag,img2_sag);
show_diff_image = diff_map(:,:,sl_start);
for slice_idx = sl_start+inc:inc:sl_end
show_diff_image = cat(2,[show_diff_image, diff_map(:,:,slice_idx)]);
end

figure('Color', 'white'); set(gca, 'Color', 'white'); 
imshow(show_diff_image);
colorbar;colormap('redblue'); caxis([-max(abs(diff_map(:)))/4*3, max(abs(diff_map(:)))/4*3]);


%%
function [img1_scaled] = norm_image(img1)
img1 = double(abs(img1));
% Scale img1 to [0, 1]
img1_scaled = (img1 - min(img1(:))) / (max(img1(:)) - min(img1(:)));

disp('Scaling Done')
end

function [img1_scaled, img2_scaled] = norm_two_image(img1,img2)
img1 = double(abs(img1));
img2 = double(abs(img2));

% Scale img1 to [0, 1]
img1_scaled = (img1 - min(img1(:))) / (max(img1(:)) - min(img1(:)));

% Scale img2 to [0, 1]
img2_scaled = (img2 - min(img2(:))) / (max(img2(:)) - min(img2(:)));
disp('Scaling Done')
end

function [diff_img]=diff_volume(img1,img2)
[img1_s,img2_s] = norm_two_image(img1,img2);
diff_img = img1_s-img2_s;
disp(max(diff_img(:)))
disp(min(diff_img(:)))
end

function V_rot = rotate_volume(V,theta)
V = double(abs(V));

% theta: degree
% positive: counterclockwise; negative: clockwise
    V_rot = zeros(size(V));
    for k = 1:size(V,3)
        V_rot(:,:,k) = imrotate(V(:,:,k), theta, 'bilinear', 'crop');  % or 'loose'
    end
end

function [gt_aligned, a, b] = align_gt_to_recon_magnitude(gt, recon, mask)
    % provided by Mauro Leidi
    % ALIGN_GT_TO_RECON_MAGNITUDE
    % Align ground truth magnitude to reconstruction magnitude
    % using least-squares affine mapping: recon ≈ a * gt + b.
    %
    % Inputs:
    %   gt    - ground truth complex image
    %   recon - reconstructed complex image
    %   mask  - optional logical mask (same size as gt), default = all true
    %
    % Outputs:
    %   gt_aligned - aligned ground truth (magnitude)
    %   a, b       - affine parameters
    
    if nargin < 3 || isempty(mask)
        mask = true(size(gt));
    end

    gt_vals = abs(gt(mask));
    recon_vals = abs(recon(mask));
    
    % Linear regression: recon ≈ a*gt + b
    covar = mean((gt_vals - mean(gt_vals)) .* (recon_vals - mean(recon_vals)));
    var_gt = mean((gt_vals - mean(gt_vals)).^2);

    a = covar / var_gt;
    b = mean(recon_vals) - a * mean(gt_vals);

    disp('Apply affine transform to full gt magnitude')
    gt_aligned = a * abs(gt) + b;
end