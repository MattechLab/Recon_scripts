% For the Bern dataset
% 1. transfer all the subject/phantom to a good position
% 2. phantom: note the index from 1 to 18, 
%   calculate the SNR of each vial
%   calculate the CNR of each vial vs. water vial

%% Bern Phantom
x_phm_idea = load('/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub4_phantom/r_x_idea_ptp_back.mat');
x_phm_pq =  load('/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub4_phantom/x_pq_ptp_back.mat');
x_phm_idea =x_phm_idea.img;
x_phm_pq = x_phm_pq.img;
x_phm_idea = norm_image(permute(x_phm_idea, [1,3,2]));
x_phm_pq = norm_image(permute(x_phm_pq, [1,3,2]));

bmImage(x_phm_idea)
bmImage(x_phm_pq)
bmImage(cat(2,x_phm_idea, x_phm_pq))
% now jump to snr_roi_mask script for cropping the roi and get the data
% and then come back

%%
close all;
crop1 = norm_image(x_phm_idea(60:180, 50:180, 81:115));
crop2 = norm_image(x_phm_pq(60:180, 50:180, 81:115));

% crop1 = equal_func(crop1, 0, 0.6);
% crop2 = equal_func(crop2, 0, 0.7);

bmImage(cat(2, crop1, crop2));
%
ssimValue = computeSSIMPerVol(crop1, crop2)
%%
crop1 = sliceView(60:180,1:60,85:105 );crop2 = sliceView_1(60:180,1:60,85:105);
bmImage(cat(2, crop1, crop2));
ssimValues = computeSSIMPerSlice(crop1, crop2,1:size(crop1,3))
plot(1:size(crop1,3), ssimValues);
xlabel('Slice Index');
ylabel('SSIM');
title('SSIM per Slice');
%%

subject_num=4;
datadir= '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/';
mask_note_list = {'idea_ori', 'idea_ptp', 'pq_ori', 'pq_ptp'};
sub_list = {'sub1_ml', 'sub2_jb', 'sub3_yj', 'sub4_phantom'};
subFolder = sub_list{subject_num};

for datatype = [2,4]
    mask_note = mask_note_list{datatype};
    % Replace with your desired output NIfTI file path
    fname = sprintf('x_%s.nii', mask_note);          % build filename only
    nifti_file = fullfile(datadir, subFolder, fname);         % join safe path
    xi = norm_image(x_b_set{subject_num, datatype}.x);
    % Ensure the volume_data is in the correct format (3D or 4D matrix)
    if ndims(xi) < 3
        error('The data in the .mat file must be at least 3D.');
    end
    
    % Define NIfTI metadata (optional but recommended for completeness)
    % You can adjust these properties according to your needs.
    nii_hdr = struct;  % Create default NIfTI header
    nii_hdr.ImageSize = size(xi);
    nii_hdr.PixelDimensions = [1 1 1];  % Adjust these values if needed
    
    
    niftiwrite(xi, nifti_file);
    disp(['Data has been saved as a NIfTI file: ', nifti_file]);

end

%% spm registration

movingFile = ['/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub4_phantom/','x_idea_ptp.nii'];
fixedFile = '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub4_phantom/x_pq_ptp.nii';
[outFile, tformFile] = spm_register_volumes(fixedFile, movingFile);
nii2mat_batch('/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub4_phantom/', 1, '_back');

%% Load SNRs
datadir   = '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub4_phantom/ver2_bg_better/';   % adapt as needed
firstIdx  = 92;                               % first slice number
lastIdx   = 121;                              % last  slice number
outfile   = fullfile(datadir,'combined_SNRs.mat');
% -------------------------------------------------------------------------
nslices   = lastIdx - firstIdx + 1;
nvials    = 18;                               % by definition

snr1_all = NaN(nslices, nvials);   % rows = slices, columns = vials
snr2_all = NaN(nslices, nvials);

for k = 1:nslices
    sliceNum = firstIdx + k - 1;                          % actual slice #
    fname    = fullfile(datadir, sprintf('snr_slice%d.mat', sliceNum));

    S = load(fname);                                      % brings snr1, snr2
    % --- safety checks (optional) ---------------------------------------
    assert(isfield(S,'snr1') && isfield(S,'snr2'), ...
           'File %s does not contain snr1/snr2', fname);
    assert(numel(S.snr1)==nvials && numel(S.snr2)==nvials, ...
           'File %s does not have 18-element vectors', fname);
    % --------------------------------------------------------------------

    snr1_all(k,:) = S.snr1(:).';   % ensure row vector
    snr2_all(k,:) = S.snr2(:).';
end

save(outfile, 'snr1_all', 'snr2_all', 'firstIdx', 'lastIdx');
fprintf('Loaded %d slices and saved combined matrix to %s\n', nslices, outfile);
%% Compute summary statistics of snr
mean1 = mean(snr1_all, 1);
mean2 = mean(snr2_all, 1);

p25_1 = prctile(snr1_all, 25, 1);   p75_1 = prctile(snr1_all, 75, 1);
p25_2 = prctile(snr2_all, 25, 1);   p75_2 = prctile(snr2_all, 75, 1);
min_1 = min(snr1_all, [], 1);   % 1×18  minimum SNR₁ across slices
max_1 = max(snr1_all, [], 1);   % 1×18  maximum SNR₁ across slices

min_2 = min(snr2_all, [], 1);   % 1×18  minimum SNR₂ across slices
max_2 = max(snr2_all, [], 1);   % 1×18  maximum SNR₂ across slices

%% Compute summary statistics of cnr
% column indices for vial-1 (water) and vial-18 (fat)
iWater = 1;
iFat   = 18;

% CNR per slice for each reconstruction
cnr1_all = abs( snr1_all - snr1_all(:,iFat) );   % 30 × 18
cnr2_all = abs( snr2_all - snr2_all(:,iFat) );   % 30 × 18

mean_cnr1 = mean(cnr1_all);
mean_cnr2 = mean(cnr2_all);
min_cnr1 = min(cnr1_all, [], 1);   % 1×18  minimum SNR₁ across slices
max_cnr1 = max(cnr1_all, [], 1);   % 1×18  maximum SNR₁ across slices

min_cnr2 = min(cnr2_all, [], 1);   % 1×18  minimum CNR across slices
max_cnr2 = max(cnr2_all, [], 1);   % 1×18  maximum CNR across slices

% mean_cnr1(iFat) = NaN; mean_cnr2(iFat) = NaN;
% min_cnr1(iFat)  = NaN; min_cnr2(iFat)  = NaN;
% max_cnr1(iFat)  = NaN; max_cnr2(iFat)  = NaN;

fprintf('Mean CNR (IDEA): %.2f\n', mean_cnr1);
fprintf('Mean CNR (pulseq): %.2f\n', mean_cnr2);

%%
vials = 1:nvials;


% ── 1.  Colour-blind safe palette (Okabe & Ito) ──
cb = [  0 114 178;    % blue      
      213  94   0; % vermillion
        86 180 233;    % sky-blue    
      204 121 167;    % magenta     
       0  158 115;    % bluish-green (spare, if needed)
        230 159   0;    % orange       (spare, if needed)
     ] / 255;  
lighten = @(c,f) c + f*(1-c);  % move colour c towards white by factor f

col1 = cb(1,:); %blue
col2 = lighten(cb(2,:), 0.2); % orange 
% col3 =cb(3, :);   % skyblue
% col4 = lighten(cb(6,:),0.45); % light orange 
col3= col1;
col4= col2;
% Face (band) colours  – even lighter for ribbons 
face1 = lighten(col1, 0.60);   % SNR IDEA band
face2 = lighten(col2, 0.60);   % SNR Pulseq band
face3 = lighten(col3, 0.60);   % CNR IDEA band
face4 = lighten(col4, 0.60);   % CNR Pulseq band

% ── 2. SNR  Figure & axes settings ──
fig = figure('Color','w','Position',[100 100 920 500]);
ax  = axes(fig); hold(ax,'on'); box(ax,'on');
% nicer typography
set(ax,'FontName','Helvetica','FontSize',16,'LineWidth',2,...
       'TickDir','out','GridAlpha',.15, ...
       'XGrid','off','YGrid','on');
ax.MinorGridLineStyle = 'none';
% ── 3.  Shaded inter-quartile bands (patch keeps line on top) ──
patch([vials, fliplr(vials)], [min_1, fliplr(max_1)], face1, ...
      'EdgeColor','none','FaceAlpha',0.25, 'Parent',ax);
patch([vials, fliplr(vials)], [min_2, fliplr(max_2)], face2, ...
      'EdgeColor','none','FaceAlpha',0.25, 'Parent',ax);

% ── 4.  Mean curves ──
l1 = plot(ax, vials, mean1, '-o', 'Color',col1, 'LineWidth',3,...
     'MarkerFaceColor',col1, 'MarkerSize',6);
l2 = plot(ax, vials, mean2, '-s', 'Color',col2, 'LineWidth',3,...
     'MarkerFaceColor',col2, 'MarkerSize',6);


% ── 5.  Labels & legend ──
xlabel(ax,'Vial #','FontWeight','bold');
ylabel(ax,'SNR','FontWeight','bold');
title(ax,'SNR across vials', 'FontWeight','bold');

% % 6.  Two-block legend (grouped)
% % block-1  → SNR
lg = legend(ax,[l1 l2],{'IDEA SNR','Pulseq SNR'},...
             'Location','northeast','Box','off');
set(lg,'Units','pixels');  
set(ax, 'TickDir', 'in', 'TickLength',[0.005 0.005]); 


ax.XLim = [1 18]; ax.XTick = 1:18;
% current axes rectangle in normalised units
p0 = get(ax,'Position');        % e.g. [0.13 0.11 0.775 0.77]

% choose the margin you want   (values are fractions of figure width/height)
margL = 0.07;   % left   7 %
margR = 0.03;   % right  3 %
margB = 0.1;   % bottom 7 %
margT = 0.1;   % top    5 %

% compute new rectangle
p = [margL , margB , 1-margL-margR , 1-margB-margT];

set(ax,'Position',p);

% ── 6.  Tighten whitespace (needs File-Exchange “tightfig” or use built-in) ──

set(fig,'PaperPositionMode','auto');   % good for exportgraphics

% ── 7.  Export vector graphic ──
exportgraphics(fig, '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub4_phantom/ver2_bg_better/SNR_trend_vial.pdf', 'ContentType','vector');




%% ── 2. CNR  Figure & axes settings ──
fig = figure('Color','w','Position',[100 100 920 500]);
ax  = axes(fig); hold(ax,'on'); box(ax,'on');
% nicer typography
set(ax,'FontName','Helvetica','FontSize',16,'LineWidth',2,...
       'TickDir','out','GridAlpha',.15, ...
       'XGrid','off','YGrid','on');
ax.MinorGridLineStyle = 'none';
% ── 3.  Shaded inter-quartile bands (patch keeps line on top) ──
patch([vials, fliplr(vials)], [min_cnr1, fliplr(max_cnr1)], face3, ...
      'EdgeColor','none','FaceAlpha',0.25, 'Parent',ax);
patch([vials, fliplr(vials)], [min_cnr2, fliplr(max_cnr2)], face4, ...
      'EdgeColor','none','FaceAlpha',0.25, 'Parent',ax);

% ── 4.  Mean curves ──
l3 = plot(ax, vials, mean_cnr1, '--o', 'Color',col3, 'LineWidth',3,...
     'MarkerFaceColor',col3, 'MarkerSize',6);
l4 = plot(ax, vials, mean_cnr2, '--s', 'Color',col4, 'LineWidth',3,...
     'MarkerFaceColor',col4, 'MarkerSize',6);

% ── 5.  Labels & legend ──
xlabel(ax,'Vial #','FontWeight','bold');
ylabel(ax,'CNR','FontWeight','bold');
title(ax,'CNR across vials', 'FontWeight','bold');

% % 6.  Two-block legend (grouped)
% % block-1  → CNR
lg = legend(ax,[l3 l4],{'IDEA CNR','Pulseq CNR'},...
             'Location','northeast','Box','off');
set(lg,'Units','pixels');  
set(ax, 'TickDir', 'in', 'TickLength',[0.005 0.005]); 


ax.XLim = [1 18]; ax.XTick = 1:18;
% current axes rectangle in normalised units
p0 = get(ax,'Position');        % e.g. [0.13 0.11 0.775 0.77]

% choose the margin you want   (values are fractions of figure width/height)
margL = 0.07;   % left   7 %
margR = 0.03;   % right  3 %
margB = 0.1;   % bottom 7 %
margT = 0.1;   % top    5 %

% compute new rectangle
p = [margL , margB , 1-margL-margR , 1-margB-margT];

set(ax,'Position',p);

% ── 6.  Tighten whitespace (needs File-Exchange “tightfig” or use built-in) ──

set(fig,'PaperPositionMode','auto');   % good for exportgraphics

% ── 7.  Export vector graphic ──
exportgraphics(fig, '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub4_phantom/ver2_bg_better/CNR_trend_vial.pdf', 'ContentType','vector');

%%
% create mask to exclude the noise outside the phantom
xrange = 30:210;
yrange = 20:190;
x_idea_crop = x_phm_idea(xrange, yrange, :);
x_idea_crop = norm_image(x_idea_crop);
x_pq_crop = x_phm_pq(xrange, yrange, :);
x_pq_crop = norm_image(x_pq_crop);
x_cat = cat(1, x_idea_crop, x_pq_crop);
bmImage(x_cat)
%% ===== transverse ====================
close all;
offset = 0;
sl_start = 100+offset;
inc=4;
sl_end=110+offset;

% show_image = img1_trans(:,:,sl_start); %90:6:126
% show_image = img2_trans(:,:,sl_start);%90+14:6:126+14
show_image = x_cat(:,:,sl_start);%90+14:6:126+14
% show_image = img_1_2_trans(:,:,sl_start);

for slice = (sl_start+inc):inc:sl_end
    show_image = cat(2,[show_image, x_cat(:,:,slice)]);
end
bmImage(abs(show_image));
set(gca,'XTick',[],'YTick',[], ...   % no tick marks
        'XColor','none','YColor','none');   % no tick labels
%%
diff_map = diff_volume(x_idea_crop,x_pq_crop);
show_diff_image = diff_map(:,:,sl_start);
for slice_idx = sl_start+inc:inc:sl_end
show_diff_image = cat(2,[show_diff_image, diff_map(:,:,slice_idx)]);
end

figure('Color', 'white'); set(gca, 'Color', 'white'); 
imshow(show_diff_image);
colorbar;colormap('redblue'); caxis([-max(abs(diff_map(:))), max(abs(diff_map(:)))]);


%% ================other plots============

%% SNR Bland–Altman
diffSNR = mean2 - mean1;
meanSNR = (mean1 + mean2)/2;
mu  = mean(diffSNR);
loa = 1.96*std(diffSNR);

figure('Color','w');
scatter(meanSNR, diffSNR, 60, 'filled'); hold on
yline(mu,'r-','Mean bias');
yline(mu+loa,'k--','+1.96×SD'); yline(mu-loa,'k--','-1.96×SD');
xlabel('Mean of methods (SNR)'); ylabel('Pulseq - IDEA');
title('Bland–Altman  SNR');
grid on





%% helper colour
fig = figure('Color','w','Position',[100 100 950 420]);
tiledlayout(1,2,'TileSpacing','compact');
names = {'SNR','CNR'};
X     = {mean1, mean_cnr1};
Y     = {mean2, mean_cnr2};

cFit  = [0.15 0.55 0.15];   % dark green for regression line
cBand = cFit + 0.6*(1-cFit); % lighter for CI patch

for k = 1:2
    x = X{k}(:);  y = Y{k}(:);

    nexttile;
    scatter(x,y,70,'filled','MarkerFaceColor',[0.2 0.55 0.9],...
                         'MarkerEdgeColor','none'); hold on

    % --- regression line & CI ------------------------------------------
    mdl   = fitlm(x,y);
    xfit  = linspace(min(x),max(x),100)';
    [yfit,ci] = predict(mdl,xfit,'Alpha',0.05);   % 95 % CI

    % CI patch
    fill([xfit; flipud(xfit)], [ci(:,1); flipud(ci(:,2))], cBand, ...
         'EdgeColor','none', 'FaceAlpha',0.20);

    % regression line
    plot(xfit,yfit,'-','Color',cFit,'LineWidth',2);

    % unity line
    lims = [0 max([x; y])*1.05];
    plot(lims,lims,'k--','LineWidth',1.4);

    axis equal tight; xlim(lims); ylim(lims);
    grid on; box on

    % labels & title
    xlabel(sprintf('IDEA %s',names{k}), 'FontSize', 16, 'FontName','Helvetica');
    ylabel(sprintf('Pulseq %s',names{k}), 'FontSize', 16, 'FontName','Helvetica');

    [R,P] = corrcoef(x,y);  r = R(2);  p = P(2);
    slope = mdl.Coefficients.Estimate(2);
    title(sprintf('%s   r = %.3f (p = %.1e)   slope = %.2f',...
          names{k}, r, p, slope),'FontWeight','bold', 'FontSize', 16, 'FontName','Helvetica');
end

% hide interactive toolbar for a cleaner export
set(gcf,'Toolbar','none');

% ── 7.  Export vector graphic ──
exportgraphics(fig, ['/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/' ...
    'sub4_phantom/ver2_bg_better/corre_snr_cnr.pdf'], 'ContentType','vector');
