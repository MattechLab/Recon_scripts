close all;clc;
%% please load your recon image here
% processing Bern sub1
subject_num = 1;
bern = 1; chuv=0;

    dataset_label ='bern';% 'chuv';
    
 
    imgSlice_idea =normImage(x_b_set_back{subject_num,2}.img);
    imgSlice_pulseq =normImage(x_b_set_back{subject_num,4}.img);
    imgSlice_site =normImage(x_c_set_back{subject_num,2}.img);

        
    bmImage(imgSlice_idea)
    bmImage(imgSlice_pulseq)
    bmImage(imgSlice_site)

    imgSlice_idea_t = equal_func(imgSlice_idea, 0, 0.7);
    imgSlice_pulseq_t = equal_func(imgSlice_pulseq, 0, 0.7);
    imgSlice_site_t = equal_func(imgSlice_site, 0, 0.10);

    bmImage(imgSlice_idea_t);bmImage(imgSlice_pulseq_t);bmImage(imgSlice_site_t);
    
    

    % Prepare the ROI masks
    mask_mode_list = {'trans', 'sag', 'coro'};
    mask_mode = 'trans';
    
    switch mask_mode
        case 'trans' 
            sliceIdxRange = 98 :102;
            sliceView = imgSlice_idea_t;
            sliceView_1 = imgSlice_pulseq_t;
            sliceView_2 = imgSlice_site_t;
        case 'coro'
            sliceIdxRange = 50:60;
            sliceView = flip(permute(imgSlice_idea_t, [3,1,2]),1);
            sliceView_1 = flip(permute(imgSlice_pulseq_t, [3,1,2]),1);
            sliceView_2 = flip(permute(imgSlice_site_t, [3,1,2]),1);
        case 'sag'
            sliceIdxRange = [96,97,98, 145,146,147];
            sliceView = flip(permute(imgSlice_idea_t, [3,2,1]),1);
            sliceView_1 = flip(permute(imgSlice_pulseq_t, [3,2,1]),1);
            sliceView_2 = flip(permute(imgSlice_site_t, [3,2,1]),1);
        otherwise
            error('the mask mode is not set correctly!')
    end
    
    bmImage(cat(2,sliceView, sliceView_1, sliceView_2))
%% SSIM
crop1 = sliceView_2(60:180,1:60,85:105 );crop2 = sliceView_1(60:180,1:60,85:105);
bmImage(cat(2, crop1, crop2));
%%
ssimValue = computeSSIMPerVol(crop1, crop2)
%%
ssimValues = computeSSIMPerSlice(crop1, crop2,1:size(crop1,3))
plot(1:size(crop1,3), ssimValues);
xlabel('Slice Index');
ylabel('SSIM');
title('SSIM per Slice');
%% Draw the ROI manually

[bg_values, maskBg] = select_ROI(sliceView_2(:,:,102), 'rect');
%%
for sliceIdx = sliceIdxRange
    CalSNR = 0; % 1: calculate SNR -- 0: no SNR
    fprintf('\n processing slice: %d\n', sliceIdx);
    for cc = 4 % set the phantom circle index
        imgIdx = 1; % set the image index for defining note suffix
        note_suffix = strcat(dataset_label,'_', mask_mode, num2str(subject_num), 'cc', num2str(cc), '_sl', num2str(sliceIdx) ); % cc1 for 'circle 1'
        roiShape = 'poly'; %option: 'circle' 'rect' 'poly'
            if (cc==1)&& sliceIdx == sliceIdxRange(1)
                SelectBack=1;
            else
                SelectBack=0;
            end
        cal_roi_mask(sliceView_2(:,:,sliceIdx), roiShape, SelectBack, CalSNR, note_suffix);
    end

end

%% save the mask into the folder
maskNames = who(strcat('maskROI_',dataset_label,'_',mask_mode,'*'));   

if isempty(maskNames)
    warning('No variables that match the pattern were found.');
    return
end

masks = cell(size(maskNames));

for k = 1:numel(maskNames)
    masks{k} = eval(maskNames{k});        
end

%
maskFolder = '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub1_ml/masks/';
maskPath = fullfile(maskFolder, strcat(dataset_label,'_', mask_mode,'_masks.mat'));
save(maskPath,'masks','maskNames');
disp(['Saved ', num2str(numel(maskNames)), ...
     maskPath]);
%%
maskBgPath = fullfile(maskFolder, 'maskBg.mat');
save(maskBgPath,'masks','maskBg');
disp(['Saved: ', maskBgPath]);



%%
check_overlay_mask_img(maskROI_bern_trans1cc2_sl102, imgSlice_site);
%%
close all; 
checkOverlay=0;
maskROI = NaN;
for sliceIdx = sliceIdxRange % select the slice index
imgSlice_idea =normImage(imgSlice_idea_t(:,:,sliceIdx));
imgSlice_pulseq =normImage(imgSlice_pulseq_t(:,:,sliceIdx));
imgSlice_site =normImage(imgSlice_site_t(:,:,sliceIdx));
check_overlay_mask_img(maskBg, imgSlice_site);
% IDEA---------

snr_estimate_list_idea = {};
for cc = 1:6
    pat   = sprintf('maskROI_%s_%s%dcc%d_sl%d', ...
                'bern', mask_mode, subject_num, cc, sliceIdx);
    vlist = who(pat);                         % cell array with the matches
assert(isscalar(vlist), ...
       'Expected exactly one variable for pattern %s, but found %d.', ...
       pat, numel(vlist));

maskROI = evalin('base', vlist{1});       % read that variable from the base workspace

    if isempty(maskROI)
        error('No maskROI is found!');
    end

    if checkOverlay
    check_overlay_mask_img(maskROI, imgSlice_idea);
    end
    roi_values = imgSlice_idea(maskROI);
    bg_values = imgSlice_idea(maskBg);
    snr_estimate = calSNR(roi_values, bg_values);
    snr_estimate_list_idea{subject_num, cc} = snr_estimate;

end

% Pulseq--------
clear roi_values bg_values snr_estimate;
snr_estimate_list_pulseq = {};
for cc = 1: 6
    pat   = sprintf('maskROI_%s_%s%dcc%d_sl%d', ...
                'bern', mask_mode, subject_num, cc, sliceIdx);
    vlist = who(pat);                         % cell array with the matches
assert(isscalar(vlist), ...
       'Expected exactly one variable for pattern %s, but found %d.', ...
       pat, numel(vlist));

maskROI = evalin('base', vlist{1});       % read that variable from the base workspace

    if isempty(maskROI)
        error('No maskROI is found!');
    end

    if checkOverlay
    check_overlay_mask_img(maskROI, imgSlice_pulseq);
    end
    roi_values = imgSlice_pulseq(maskROI);
    bg_values = imgSlice_pulseq(maskBg);
    snr_estimate = calSNR(roi_values, bg_values);
    snr_estimate_list_pulseq{subject_num, cc} = snr_estimate;


    % site--------
clear roi_values bg_values snr_estimate;
snr_estimate_list_site = {};
for cc = 1: 6
    pat   = sprintf('maskROI_%s_%s%dcc%d_sl%d', ...
                'chuv', mask_mode, subject_num, cc, sliceIdx);
    vlist = who(pat);                         % cell array with the matches
assert(isscalar(vlist), ...
       'Expected exactly one variable for pattern %s, but found %d.', ...
       pat, numel(vlist));

maskROI = evalin('base', vlist{1});       % read that variable from the base workspace

    if isempty(maskROI)
        error('No maskROI is found!');
    end

    if checkOverlay
    check_overlay_mask_img(maskROI, imgSlice_site);
    end
    roi_values = imgSlice_site(maskROI);
    bg_values = imgSlice_site(maskBg);
    snr_estimate = calSNR(roi_values, bg_values);
    snr_estimate_list_site{subject_num, cc} = snr_estimate;


end

clear roi_values bg_values snr_estimate;
%
snr1 = cell2mat(snr_estimate_list_idea);
snr2 = cell2mat(snr_estimate_list_pulseq);
snr3 = cell2mat(snr_estimate_list_site);
% Format the filename with slice number (zero-padded to 2 digits)
filename = sprintf('%s_snr_slice%02d.mat',mask_mode, sliceIdx);
snrPath = ['/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub1_ml/masks/', filename];
save(snrPath, 'snr1', 'snr2', 'snr3');
fprintf('Saved: %s\n', snrPath);

end

%
% Plot
figure; hold on;
plot(1:size(snr1,2), snr1, '-o', 'LineWidth', 2, 'DisplayName', 'IDEA LIBRE 6p2' );
plot(1:size(snr2,2), snr2, '-s', 'LineWidth', 2, 'DisplayName', 'pulseq LIBRE 6p2');
plot(1:size(snr3,2), snr3, '-.', 'LineWidth', 2, 'DisplayName', 'multi-site LIBRE 6p2');

% Beautify
xlabel('Subject / Pair Index');
ylabel('SNR');
title('SNR Comparison Across Pairs');
legend('Location', 'best');
grid on;
set(gcf, 'Color', 'w');  % white figure background
end

%% =================Function zone=============================================
function cal_roi_mask(imageSlice, roiShape, SelectBack, CalSNR, note_suffix)
    % imageSlice: 2D matrix (e.g., one MRI slice)
   if CalSNR
       SelectBack = 1;
       warning('SelectBack should be 1 for SNR calculation!')
   end
   fprintf('select ROI!')
   [roi_values, maskROI] = select_ROI(imageSlice, roiShape);
   maskName =  strcat('maskROI_', note_suffix);

   assignin('base',maskName, maskROI);  % Optional: export to workspace
   assignin('base', 'roi_values', roi_values);  % Optional: export to workspace
   if SelectBack
       fprintf('select background!')
       [bg_values, maskBg] = select_ROI(imageSlice, 'rect');
       assignin('base', 'maskBg', maskBg);  % Optional: export to workspace
       fprintf('The background mask maskBg has been saved to workspace! \n')
       assignin('base', 'bg_values', bg_values);  % Optional: export to workspace
       fprintf('The background mean value bg_values has been saved to workspace! \n')
   end
   
   if SelectBack && CalSNR
      snr_estimate = calSNR(roi_values, bg_values);
      assignin('base', 'snr_estimate', snr_estimate);  % Optional: export to workspace
      fprintf('The SNR snr_estimate %f has been saved to workspace!', snr_estimate);
   end 
    
end


function [roi_values, mask]= select_ROI(imageSlice, shapeInfo)
    figure;
    imshow(imageSlice, [], 'InitialMagnification', 'fit');

    if strcmp(shapeInfo, 'circle')
        title('Draw a circle ROI. Double-click to confirm.'); 
        % Let user select circle ROI
        h = imellipse(gca, []);
    elseif strcmp(shapeInfo, 'rect')
        title('Draw a rect ROI. Double-click to confirm.'); 
        % Let user select rectangular background
        h = imrect(gca, []);
    elseif strcmp(shapeInfo, 'poly')
        title('Draw a poly ROI. Double-click to confirm.'); 
        % Let user select rectangular background
        h = impoly(gca, []);
    end

    % Create binary mask from the selected region
    position = wait(h);  % Wait for user to finish drawing
    mask = createMask(h); 

    check_overlay_mask_img(mask, imageSlice);
    roi_values = imageSlice(mask);

end

function check_overlay_mask_img(mask, imageSlice)
    % Show the mask overlay
    figure;
    imshow(imageSlice, [], 'InitialMagnification', 'fit'); hold on;
    visboundaries(mask, 'Color', 'r');
    title('Selected ROI Overlay');

end

function snr_estimate = calSNR(roi_values, bg_values)
        snr_estimate = mean(roi_values) / std(bg_values);
       fprintf('Estimated SNR in ROI: %.2f\n', snr_estimate);
end

function normedSlice = normImage(imgSlice)
    mag = abs(imgSlice);
    normedSlice = (mag - min(mag(:)))/(max(mag(:)) - min(mag(:)));
    disp('Image is normalized to [0,1]')
end