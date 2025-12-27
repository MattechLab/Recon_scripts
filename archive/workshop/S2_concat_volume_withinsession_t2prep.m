%%
close all;clc
x{1}= xrms_idea;
x{2} =xrms_hs;
% x{3} = flip(flip(flip(x3,1),2),3);
% x{4} = x4;
%%

x1_sag = norm_image(x{1});
x1_trans = norm_image(rot90(permute(x1_sag, [1,3,2]), 1));
x1_coronal = norm_image(permute(x1_sag, [3,2,1]));
bmImage(x1_trans);
bmImage(x1_sag);

% bmImage(x1_coronal);

x2_sag = norm_image(x{2});
x2_trans = norm_image(rot90(permute(x2_sag, [1,3,2]),1));
x2_coronal = norm_image(permute(x2_sag, [3,2,1]));
bmImage(x2_trans);
bmImage(x2_sag);
% bmImage(x2_coronal);

% x3_trans = norm_image(x{3});
% x3_sag = norm_image(rot90(permute(x3_trans, [1,3,2]),1));
% x3_coronal = norm_image(permute(x3_trans, [3,2,1]));
% bmImage(x3_trans);
% bmImage(x3_sag);
% bmImage(x3_coronal);

% x4_trans = norm_image(flip(flip(permute(x{4}, [2,3,1]),1),2));
% x4_sag = norm_image(flip(flip(permute(x4_trans, [1,3,2]),1),2));
% x4_coronal = norm_image(permute(x4_trans, [3,2,1]));
% % bmImage(x4_trans);
% bmImage(x4_sag);
% % bmImage(x4_coronal)
%% Compare hypersech T2-prep 
% x2_sag T=40ms, x4_sag T=80ms
show_image = [];
offset = -2;
sl_start = 106+offset;
inc=2;
sl_end=112+offset;
show_image = cat(1, norm_image(x2_sag(:,:,sl_start)), norm_image(x4_sag(:,:,offset+sl_start)));

for slice = (sl_start+inc):inc:sl_end
    show_image = cat(2, show_image, cat(1, norm_image(x2_sag(:,:,slice)), norm_image(x4_sag(:,:,slice+offset))));
    % show_image = cat(2,[show_image, img2_trans(:,:,slice)]);
end

bmImage(show_image);
%%

img_1_2_3_trans = cat(2,x1_trans, x2_trans, x3_trans);
bmImage(img_1_2_3_trans)


img_1_2_3_sag = cat(2,x1_sag, x2_sag, x3_sag);
bmImage(img_1_2_3_sag)
 
% img_trans_sag = cat(2,img_1_2_trans, img_1_2_sag);
% bmImage(img_trans_sag);

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





