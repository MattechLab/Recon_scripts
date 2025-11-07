%%
clear;close all;clc;
%%
x1 = load(['/Users/cag/Documents/Dataset/recon_results/251030/Sub001/' ...
    'T1_LIBRE_woBinning/output/mask_JB_321p18_40/xrms.mat']);
x2 = load(['/Users/cag/Documents/Dataset/recon_results/251030/Sub002/' ...
    'T1_LIBRE_woBinning/output/mask_JB_646p92_40/xrms.mat']);
x3 = load(['/Users/cag/Documents/Dataset/recon_results/251030/Sub003/' ...
    'T1_LIBRE_woBinning/output/mask_pq_wurst_40/xrms.mat']);
x4 = load(['/Users/cag/Documents/Dataset/recon_results/251030/Sub004/' ...
    'T1_LIBRE_woBinning/output/mask_JB_646p92_80/xrms.mat']);
x5 = load(['/Users/cag/Documents/Dataset/recon_results/251030/Sub005/' ...
    'T1_LIBRE_woBinning/output/mask_pq_wurst_80/xrms.mat']);
x6 = load(['/Users/cag/Documents/Dataset/recon_results/251030/Sub006/' ...
    'T1_LIBRE_woBinning/output/mask_pq_wurst_40_321p18/xrms.mat']);
x7 = load(['/Users/cag/Documents/Dataset/recon_results/251030/Sub007/' ...
    'T1_LIBRE_woBinning/output/mask_JB_646p92_60/xrms.mat']);
x8 = load(['/Users/cag/Documents/Dataset/recon_results/251030/Sub008/' ...
    'T1_LIBRE_woBinning/output/mask_pq_wurst_60/xrms.mat']);
x1 = x1.xrms;x2 = x2.xrms;x3 = x3.xrms;x4 = x4.xrms;
x5 = x5.xrms;x6 = x6.xrms;x7 = x7.xrms;x8 = x8.xrms;

%%
x{1}=x1; x{2}=x2; x{3}=x3; x{4}=x4; 
x{5}=x5; x{6}=x6; x{7}=x7; x{8}=x8;
%%
% compare: x1 mask_JB_321p18_40 with x6 mask_pq_wurst_40_321p18
x1_trans = permute(norm_image(x{1}), [3,1,2]);
x2_trans = permute(norm_image(x{6}), [3,1,2]);
bmImage(cat(2, x1_trans, x2_trans));
%%
% compare: x2 mask_JB_646p92_40 with x3 mask_pq_wurst_40
x3_trans = permute(norm_image(x{2}), [3,1,2]);
x4_trans = permute(norm_image(x{3}), [3,1,2]);

%%
% compare: x4 mask_JB_646p92_80 with x5 mask_pq_wurst_80
x5_trans = permute(norm_image(x{4}), [3,1,2]);
x6_trans = permute(norm_image(x{5}), [3,1,2]);

%%
% compare: x7 mask_JB_646p92_60 with x8 mask_pq_wurst_60
x7_trans = permute(norm_image(x{7}), [3,1,2]);
x8_trans = permute(norm_image(x{8}), [3,1,2]);

%%
% compare idile time mask_JB_321p18_40 vs. mask_JB_646p92_40
bmImage(cat(2, x1_trans, x3_trans));

%% 
% compare t2-prep duration
% mask_JB_646p92_40 mask_JB_646p92_60 mask_JB_646p92_80
bmImage(cat(2, x2_trans, x7_trans, x4_trans));
%% 
% compare t2-prep duration
% mask_pq_wurst_40 mask_pq_wurst_60 mask_pq_wurst_60
bmImage(cat(2, x3_trans, x8_trans, x5_trans));


%% Joint comparison
x_jb = cat(2, x2_trans, x7_trans, x4_trans);

x_pq = cat(2, x3_trans, x8_trans, x5_trans);
bmImage(cat(1,x_jb,x_pq));
%%
img_1_2_trans = cat(1,x1_trans, x2_trans);
bmImage(img_1_2_trans)

img_1_2_sag = cat(1,x1_sag, x2_sag);
bmImage(img_1_2_sag)
 


%% ===== transverse ====================
% close all;
offset = 0;
sl_start = 90+offset;
inc=8;
sl_end=128+offset;

% show_image = img2_trans(:,:,sl_start);%90+14:6:126+14
show_image = img_1_2_trans(:,:,sl_start);

for slice = (sl_start+inc):inc:sl_end
    show_image = cat(2,[show_image, img_1_2_trans(:,:,slice)]);
    % show_image = cat(2,[show_image, img2_trans(:,:,slice)]);
end
bmImage(show_image);

%%
diff_map = diff_volume(x1_trans,x2_trans);
%%
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

sl_start = 70;
inc=6;
sl_end=110;

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