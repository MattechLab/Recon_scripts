% Registration for each subject from Bern

subject_num=[1,2,3];
datadir= '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/';
mask_note_list = {'idea_ori', 'idea_ptp', 'pq_ori', 'pq_ptp'};
sub_list = {'sub1_ml', 'sub2_jb', 'sub3_yj'};
subFolder = sub_list{subject_num};

for datatype = [1,2,3,4]
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
nii_name_list = {'x_idea_ori.nii','x_idea_ptp.nii','x_pq_ori.nii'};
sub_list = {'sub1_ml', 'sub2_jb', 'sub3_yj'};
subFolder = sub_list{subject_num};

for idx = [1, 2, 3]
    movingFile = ['/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub3_yj/', nii_name_list{idx}];
    fixedFile = '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub3_yj/x_pq_ptp.nii';
    [outFile, tformFile] = spm_register_volumes(fixedFile, movingFile);
end
%%
% Registration for each subject from CHUV

for subject_num=[1,2,3]
datadir= '/Users/cag/Documents/Dataset/recon_results/251007_chuv_abs/';
mask_note_list = {'pq_ori', 'pq_ptp'};
sub_list = {'sub1_ml', 'sub2_jb', 'sub3_yj'};
subFolder = sub_list{subject_num};

for datatype = [1,2]
    mask_note = mask_note_list{datatype};
    % Replace with your desired output NIfTI file path
    fname = sprintf('x_%s.nii', mask_note);          % build filename only
    nifti_file = fullfile(datadir, subFolder, fname);         % join safe path
    xi =x_c_set{subject_num, datatype};
    xi = norm_image(xi.x);
    bmImage(xi)
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
end
%% spm registration for CHUV
% keep the Bern ptp as reference
nii_name_list = {'x_pq_ori.nii', 'x_pq_ptp.nii'};
sub_list = {'sub1_ml', 'sub2_jb', 'sub3_yj'};

for subject_num = [1, 2, 3]
    for datatype = [1,2]
    subFolder = sub_list{subject_num};
    movingFile = fullfile('/Users/cag/Documents/Dataset/recon_results/251007_chuv_abs/', subFolder, nii_name_list{datatype});
    fixedFile = fullfile('/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/',subFolder, 'x_pq_ptp.nii');
    [outFile, tformFile] = spm_register_volumes(fixedFile, movingFile);
    end
end


%% Convert all the nii back to mat files
nii2mat_batch('/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/', 1, '_back');
nii2mat_batch('/Users/cag/Documents/Dataset/recon_results/251007_chuv_abs/', 1, '_back');
% now go to S5_check_all_recons import x_*_set_back
%% Now jump to head_snr_roi_mask to calculate the SNR/CNR and other things.
% open from command window
% >> head_snr_roi_mask



% ==========================================
%% Load SNRs
datadir   = '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub1_ml/masks/';   % adapt as needed
firstIdx  = 98;                               % first slice number
lastIdx   = 102;                              % last  slice number
outfile   = fullfile(datadir,'combined_SNRs.mat');
% -------------------------------------------------------------------------
nslices   = lastIdx - firstIdx + 1;
nvials    = 6;                               % by definition

snr1_all = NaN(nslices, nvials);   % rows = slices, columns = vials
snr2_all = NaN(nslices, nvials);
snr3_all = NaN(nslices, nvials);


for k = 1:nslices
    sliceNum = firstIdx + k - 1;                          % actual slice #
    fname    = fullfile(datadir, sprintf('trans_snr_slice%d.mat', sliceNum));

    S = load(fname);                                      % brings snr1, snr2
    % --- safety checks (optional) ---------------------------------------
    assert(isfield(S,'snr1') && isfield(S,'snr2'), ...
           'File %s does not contain snr1/snr2', fname);
    assert(numel(S.snr1)==nvials && numel(S.snr2)==nvials, ...
           'File %s does not have correct vectors', fname);
    % --------------------------------------------------------------------

    snr1_all_ori(k,:) = S.snr1(:).';   % ensure row vector
    snr2_all_ori(k,:) = S.snr2(:).';
    snr3_all_ori(k,:) = S.snr3(:).';
end
%%
save(outfile, 'snr1_all', 'snr2_all', 'snr3_all','firstIdx', 'lastIdx');
fprintf('Loaded %d slices and saved combined matrix to %s\n', nslices, outfile);
%% Compute summary statistics of snr
mergeIdx=[2,4];
snr1_all = merge_idx(snr1_all_ori, mergeIdx);
snr2_all = merge_idx(snr2_all_ori, mergeIdx);
snr3_all = merge_idx(snr3_all_ori, mergeIdx);
%%
mean1 = mean(snr1_all, 1);
mean2 = mean(snr2_all, 1);
mean3 = mean(snr3_all, 1);

p25_1 = prctile(snr1_all, 25, 1);   p75_1 = prctile(snr1_all, 75, 1);
p25_2 = prctile(snr2_all, 25, 1);   p75_2 = prctile(snr2_all, 75, 1);
p25_3 = prctile(snr3_all, 25, 1);   p75_3 = prctile(snr3_all, 75, 1);

min_1 = min(snr1_all, [], 1);   % 1×18  minimum SNR₁ across slices
max_1 = max(snr1_all, [], 1);   % 1×18  maximum SNR₁ across slices

min_2 = min(snr2_all, [], 1);   % 1×18  minimum SNR₂ across slices
max_2 = max(snr2_all, [], 1);   % 1×18  maximum SNR₂ across slices

min_3 = min(snr3_all, [], 1);      % 1×18  minimum SNR₃ across slices
max_3 = max(snr3_all, [], 1);      % 1×18  maximum SNR₃ across slices

%% Compute summary statistics of cnr
% column indices for vial-1 (water) and vial-18 (fat)

iFat   = 2;

% CNR per slice for each reconstruction
cnr1_all = abs( snr1_all - snr1_all(:,iFat) );   % 30 × 18
cnr2_all = abs( snr2_all - snr2_all(:,iFat) );   % 30 × 18
cnr3_all = abs( snr3_all - snr3_all(:, iFat) );   % 30 × 18

cnr1_all(:,2) = [];  
cnr2_all(:,2) = [];   
cnr3_all(:,2) = [];   
%%
mean_cnr1 = mean(cnr1_all);
mean_cnr2 = mean(cnr2_all);
mean_cnr3 = mean(cnr3_all);     % 1×18  mean CNR across slices


fprintf('Mean CNR (recon-3): %.2f\n', mean(mean_cnr3));  % prints grand mean
min_cnr1 = min(cnr1_all, [], 1);   % 1×18  minimum SNR₁ across slices
max_cnr1 = max(cnr1_all, [], 1);   % 1×18  maximum SNR₁ across slices

min_cnr2 = min(cnr2_all, [], 1);   % 1×18  minimum CNR across slices
max_cnr2 = max(cnr2_all, [], 1);   % 1×18  maximum CNR across slices


min_cnr3  = min(cnr3_all, [], 1);  % 1×18  minimum CNR₃ across slices
max_cnr3  = max(cnr3_all, [], 1);  % 1×18  maximum CNR₃ across slices


fprintf('Mean CNR (IDEA): %.2f\n', mean_cnr1);
fprintf('Mean CNR (pulseq): %.2f\n', mean_cnr2);

%%
vials = 1:nvials-1;


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
col3 = cb(5,:); %green

col4= col1;
col5= col2;
col6 = col3; %green
% Face (band) colours  – even lighter for ribbons 
face1 = lighten(col1, 0.60);   % SNR IDEA band
face2 = lighten(col2, 0.60);   % SNR Pulseq band
face3 = lighten(col3, 0.60);   % SNR site band

face4 = lighten(col4, 0.60);   % CNR IDEA band
face5 = lighten(col5, 0.60);   % CNR Pulseq band
face6 = lighten(col6, 0.60);   % CNR site band

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
patch([vials, fliplr(vials)], [min_3, fliplr(max_3)], face3, ...
      'EdgeColor','none','FaceAlpha',0.25, 'Parent',ax);
% ── 4.  Mean curves ──
l1 = plot(ax, vials, mean1, '-o', 'Color',col1, 'LineWidth',3,...
     'MarkerFaceColor',col1, 'MarkerSize',6);
l2 = plot(ax, vials, mean2, '-s', 'Color',col2, 'LineWidth',3,...
     'MarkerFaceColor',col2, 'MarkerSize',6);
l3 = plot(ax, vials, mean3, '-s', 'Color',col3, 'LineWidth',3,...
     'MarkerFaceColor',col3, 'MarkerSize',6);

% ── 5.  Labels & legend ──
xlabel(ax,'Vial #','FontWeight','bold');
ylabel(ax,'SNR','FontWeight','bold');
title(ax,'SNR across vials', 'FontWeight','bold');

% % 6.  Two-block legend (grouped)
% % block-1  → SNR
lg = legend(ax,[l1 l2 l3],{'IDEA Site 1 SNR','Pulseq Site1 SNR', 'Pulseq Site 2 SNR'},...
             'Location','northeast','Box','off');
set(lg,'Units','pixels');  
set(ax, 'TickDir', 'in', 'TickLength',[0.005 0.005]); 


ax.XLim = [1 nvials-1]; ax.XTick = 1:nvials-1;
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
exportgraphics(fig, '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub1_ml/masks/SNR_trend_vial.pdf', 'ContentType','vector');




%% ── 2. CNR  Figure & axes settings ──
fig = figure('Color','w','Position',[100 100 920 500]);
ax  = axes(fig); hold(ax,'on'); box(ax,'on');
% nicer typography
vials = 1:nvials-2;

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
l4 = plot(ax, vials, mean_cnr1, '--o', 'Color',col4, 'LineWidth',3,...
     'MarkerFaceColor',col4, 'MarkerSize',6);
l5 = plot(ax, vials, mean_cnr2, '--s', 'Color',col5, 'LineWidth',3,...
     'MarkerFaceColor',col5, 'MarkerSize',6);
l6 = plot(ax, vials, mean_cnr3, '--s', 'Color',col6, 'LineWidth',3,...
     'MarkerFaceColor',col6, 'MarkerSize',6);
% ── 5.  Labels & legend ──
xlabel(ax,'Vial #','FontWeight','bold');
ylabel(ax,'CNR','FontWeight','bold');
title(ax,'CNR across vials', 'FontWeight','bold');

% % 6.  Two-block legend (grouped)
% % block-1  → CNR
lg = legend(ax,[l4 l5 l6],{'IDEA Bern CNR','Pulseq Bern CNR', 'Pulseq CHUV CNR'},...
             'Location','northeast','Box','off');
set(lg,'Units','pixels');  
set(ax, 'TickDir', 'in', 'TickLength',[0.005 0.005]); 


ax.XLim = [1 nvials-1]; ax.XTick = 1:nvials-1;
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
exportgraphics(fig, '/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/sub1_ml/masks/CNR_trend_vial.pdf', 'ContentType','vector');

%%
% create mask to exclude the noise outside the phantom

    % Prepare the ROI masks
    mask_mode_list = {'trans', 'sag', 'coro'};
    mask_mode = 'sag';
    
    switch mask_mode
        case 'trans' 
            sliceIdxRange = 98 :102;
            sliceView = imgSlice_idea_t;
            sliceView_1 = imgSlice_pulseq_t;
            sliceView_2 = imgSlice_site_t;

            xrange = 60:180;
            yrange = 1:80;
            x_idea_bern = sliceView(xrange, yrange, :);
            x_idea_bern = permute(norm_image(x_idea_bern),[2,1,3]);
            
            x_pq_bern = sliceView_1(xrange, yrange, :);
            x_pq_bern = permute(norm_image(x_pq_bern),[2,1,3]);
            
            x_pq_chuv = sliceView_2(xrange, yrange, :);
            x_pq_chuv = permute(norm_image(x_pq_chuv),[2,1,3]);
            
            x_cat = cat(1, x_idea_bern, x_pq_bern, x_pq_chuv);
            bmImage(x_cat)


        case 'coro'
            sliceIdxRange = 50:60;
            sliceView = flip(permute(imgSlice_idea_t, [3,1,2]),1);
            sliceView_1 = flip(permute(imgSlice_pulseq_t, [3,1,2]),1);
            sliceView_2 = flip(permute(imgSlice_site_t, [3,1,2]),1);

            xrange = 60:180;
            yrange = 55:185;
            x_idea_bern = sliceView(xrange, yrange, :);
            x_pq_bern = sliceView_1(xrange, yrange, :);
            x_pq_chuv = sliceView_2(xrange, yrange, :);

            
            x_cat = cat(1, x_idea_bern, x_pq_bern, x_pq_chuv);
            bmImage(x_cat)


        case 'sag'
            sliceIdxRange = [96,97,98, 145,146,147];
            sliceView = flip(permute(imgSlice_idea_t, [3,2,1]),1);
            sliceView_1 = flip(permute(imgSlice_pulseq_t, [3,2,1]),1);
            sliceView_2 = flip(permute(imgSlice_site_t, [3,2,1]),1);

            xrange = 60:180;
            yrange = 1:80;
            x_idea_bern = sliceView(xrange, yrange, :);
            x_pq_bern = sliceView_1(xrange, yrange, :);
            x_pq_chuv = sliceView_2(xrange, yrange, :);

            
            x_cat = cat(1, x_idea_bern, x_pq_bern, x_pq_chuv);
            bmImage(x_cat)

        otherwise
            error('the mask mode is not set correctly!')
    end
    



%% ===== transverse ====================



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





%% helper colour , multi-vendor
fig = figure('Color','w','Position',[100 100 950 420]); 
tiledlayout(1,2,'TileSpacing','compact');
names = {'SNR','CNR'};
X     = {mean2, mean_cnr2};
Y     = {mean1, mean_cnr1};


cFit1  = col1;   % 
cBand1 = cFit1 + 0.6*(1-cFit1); % lighter for CI patch

cFit2  = col2;   % 
cBand2 = cFit2 + 0.6*(1-cFit2); % lighter for CI patch

cFit3  = col3;   %
cBand3 = cFit3 + 0.6*(1-cFit3); % lighter for CI patch

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
    fill([xfit; flipud(xfit)], [ci(:,1); flipud(ci(:,2))], cBand1, ...
         'EdgeColor','none', 'FaceAlpha',0.20);

    % regression line
    plot(xfit,yfit,'-','Color',cFit1,'LineWidth',2);

    % unity line
    lims = [0 max([x; y])*1.05];
    plot(lims,lims,'k--','LineWidth',1.4);

    axis equal tight; xlim(lims); ylim(lims);
    grid on; box on

    % labels & title
    xlabel(sprintf('Pulseq Site 1 %s',names{k}), 'FontSize', 16, 'FontName','Helvetica');
    ylabel(sprintf('IDEA Site 1 %s',names{k}), 'FontSize', 16, 'FontName','Helvetica');

    [R,P] = corrcoef(x,y);  r = R(2);  p = P(2);
    slope = mdl.Coefficients.Estimate(2);
    title(sprintf('%s   r = %.3f (p = %.1e)',...
          names{k}, r, p),'FontWeight','bold', 'FontSize', 16, 'FontName','Helvetica');
end

% hide interactive toolbar for a cleaner export
set(gcf,'Toolbar','none');

% ── 7.  Export vector graphic ──
exportgraphics(fig, ['/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/' ...
    'sub1_ml/masks/corre_snr_cnr_multi_vendor.pdf'], 'ContentType','vector');


%% helper colour mutisite
fig = figure('Color','w','Position',[100 100 950 420]);
tiledlayout(1,2,'TileSpacing','compact');
names = {'SNR','CNR'};

Y     = {mean2, mean_cnr2};
Z     = {mean3, mean_cnr3};



for k = 1:2
    x = Y{k}(:);  y = Z{k}(:);

    nexttile;
    scatter(x,y,70,'filled','MarkerFaceColor',[0.2 0.55 0.9],...
                         'MarkerEdgeColor','none'); hold on

    % --- regression line & CI ------------------------------------------
    mdl   = fitlm(x,y);
    xfit  = linspace(min(x),max(x),100)';
    [yfit,ci] = predict(mdl,xfit,'Alpha',0.05);   % 95 % CI

    % CI patch
    fill([xfit; flipud(xfit)], [ci(:,1); flipud(ci(:,2))], cBand2, ...
         'EdgeColor','none', 'FaceAlpha',0.20);

    % regression line
    plot(xfit,yfit,'-','Color',cFit2,'LineWidth',2);

    % unity line
    lims = [0 max([x; y])*1.05];
    plot(lims,lims,'k--','LineWidth',1.4);

    axis equal tight; xlim(lims); ylim(lims);
    grid on; box on

    % labels & title
    xlabel(sprintf('Pulseq Site 1 %s',names{k}), 'FontSize', 16, 'FontName','Helvetica');
    ylabel(sprintf('Pulseq Site 2 %s',names{k}), 'FontSize', 16, 'FontName','Helvetica');

    [R,P] = corrcoef(x,y);  r = R(2);  p = P(2);
    slope = mdl.Coefficients.Estimate(2);
    title(sprintf('%s   r = %.3f (p = %.1e)',...
          names{k}, r, p),'FontWeight','bold', 'FontSize', 16, 'FontName','Helvetica');
end

% hide interactive toolbar for a cleaner export
set(gcf,'Toolbar','none');

% ── 7.  Export vector graphic ──
exportgraphics(fig, ['/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/' ...
    'sub1_ml/masks/corre_snr_cnr_multi_site.pdf'], 'ContentType','vector');