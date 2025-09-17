% ADD MONALISA TO PATH
addpath(genpath('/Users/mauroleidi/Desktop/monalisa'))

pathseq1 = '/Users/mauroleidi/Desktop/MattechGit/pulseSeqYiwei/gre_first_experiments_4_9_25/recon_results/250829/Sub001/mask_reference/xrms.mat';
pathseq2 = '/Users/mauroleidi/Desktop/MattechGit/pulseSeqYiwei/gre_first_experiments_4_9_25/recon_results/250829/Sub002/mask_half_gz_spoil/xrms.mat';
pathseq3 = '/Users/mauroleidi/Desktop/MattechGit/pulseSeqYiwei/gre_first_experiments_4_9_25/recon_results/250829/Sub003/mask_no_gz_spoil/xrms.mat';
pathseq4 = '/Users/mauroleidi/Desktop/MattechGit/pulseSeqYiwei/gre_first_experiments_4_9_25/recon_results/250829/Sub004/mask_4x_gz_spoil/xrms.mat';
pathseq5 = '/Users/mauroleidi/Desktop/MattechGit/pulseSeqYiwei/gre_first_experiments_4_9_25/recon_results/250829/Sub005/mask_no_rf_spoil/xrms.mat';
pathseq6 = '/Users/mauroleidi/Desktop/MattechGit/pulseSeqYiwei/gre_first_experiments_4_9_25/recon_results/250829/Sub006/mask_fibonacci/xrms.mat';
pathseq7 = '/Users/mauroleidi/Desktop/MattechGit/pulseSeqYiwei/gre_first_experiments_4_9_25/recon_results/250829/Sub007/mask_not_fibonacci/xrms.mat';
pathseq8 = '/Users/mauroleidi/Desktop/MattechGit/pulseSeqYiwei/gre_first_experiments_4_9_25/recon_results/250829/Sub008/mask_flexyphy/xrms.mat';


%% Helper function to load xrms
loadXRMS = @(p) load(p, 'xrms').xrms;

% Images proably need to be aligned before joint display. this can be done
% within the imaging function

x1 = loadXRMS(pathseq1);
x2 = loadXRMS(pathseq2);





% Coronal slice
showImagesSideBySide('coronal', round(size(x1,2)/2), [0 0.05], x1, x2);

% Sagittal slice
showImagesSideBySide('sagittal', round(size(x1,1)/2), [0 0.05], x1, x2);


%% FIRST PLOT (1,2,3,4)
x1 = loadXRMS(pathseq1);
x2 = loadXRMS(pathseq2);
%x2 = permute(x2, [2 1 3]);   % swap row/col, keep 3rd dim
x2 = flip( permute(x2, [2 1 3]), 2 );

x3 = loadXRMS(pathseq3);
x4 = loadXRMS(pathseq4);
%x4 = permute(x4, [2 1 3]);   % swap row/col, keep 3rd dim
x4 = flip( permute(x4, [2 1 3]), 2 );

savefolder = '/Users/mauroleidi/Desktop/MattechGit/pulseSeqYiwei/gre_first_experiments_4_9_25/recon_results/';

% Axial middle slice
showImagesSideBySide('axial', 60, [0 2.5], ...
    x3, x2, x1, x4, ...
    'Titles', {'No GZ spoil', 'Half GZ spoil', 'Reference', '4x GZ spoil'});
exportgraphics(gcf, [savefolder,'plot_axial_slice60_exp1.png'], 'Resolution', 300);


% Axial middle slice
showImagesSideBySide('axial', 120, [0 2.5], ...
    x3, x2, x1, x4, ...
    'Titles', {'No GZ spoil', 'Half GZ spoil', 'Reference', '4x GZ spoil'});
exportgraphics(gcf, [savefolder,'plot_axial_slice120_exp1.png'], 'Resolution', 300);
% Axial middle slice
showImagesSideBySide('axial', 180, [0 2.5], ...
    x3, x2, x1, x4, ...
    'Titles', {'No GZ spoil', 'Half GZ spoil', 'Reference', '4x GZ spoil'});
exportgraphics(gcf, [savefolder,'plot_axial_slice180_exp1.png'], 'Resolution', 300);


% Coronal middle slice
showImagesSideBySide('coronal', 60, [0 2.5], ...
    x3, x2, x1, x4, ...
    'Titles', {'No GZ spoil', 'Half GZ spoil', 'Reference', '4x GZ spoil'});
exportgraphics(gcf, [savefolder,'plot_coronal_slice60_exp1.png'], 'Resolution', 300);

% Coronal middle slice
showImagesSideBySide('coronal', 120, [0 2.5], ...
    x3, x2, x1, x4, ...
    'Titles', {'No GZ spoil', 'Half GZ spoil', 'Reference', '4x GZ spoil'});
exportgraphics(gcf, [savefolder,'plot_coronal_slice120_exp1.png'], 'Resolution', 300);

% Coronal middle slice
showImagesSideBySide('coronal', 180, [0 2.5], ...
    x3, x2, x1, x4, ...
    'Titles', {'No GZ spoil', 'Half GZ spoil', 'Reference', '4x GZ spoil'});
exportgraphics(gcf, [savefolder,'plot_coronal_slice180_exp1.png'], 'Resolution', 300);

% Saggital middle slice
showImagesSideBySide('sagittal', 60, [0 2.5], ...
    x3, x2, x1, x4, ...
    'Titles', {'No GZ spoil', 'Half GZ spoil', 'Reference', '4x GZ spoil'});
exportgraphics(gcf, [savefolder,'plot_sagittal_slice60_exp1.png'], 'Resolution', 300);

% Saggital middle slice
showImagesSideBySide('sagittal', 120, [0 2.5], ...
    x3, x2, x1, x4, ...
    'Titles', {'No GZ spoil', 'Half GZ spoil', 'Reference', '4x GZ spoil'});
exportgraphics(gcf, [savefolder,'plot_sagittal_slice120_exp1.png'], 'Resolution', 300);

% Saggital middle slice
showImagesSideBySide('sagittal', 180, [0 2.5], ...
    x3, x2, x1, x4, ...
    'Titles', {'No GZ spoil', 'Half GZ spoil', 'Reference', '4x GZ spoil'});
exportgraphics(gcf, [savefolder,'plot_sagittal_slice180_exp1.png'], 'Resolution', 300);



% --- Create PPT
import mlreportgen.ppt.*
ppt = Presentation('comparison_results.pptx');
open(ppt);

imgFiles = dir('plot_*.png');
for k = 1:numel(imgFiles)
    slide = add(ppt, 'Title and Content');
    pic = Picture(fullfile(imgFiles(k).folder, imgFiles(k).name));
    pic.X = '0in'; 
    pic.Y = '0in';
    pic.Width  = ppt.PageSize.Width;
    pic.Height = ppt.PageSize.Height;
    replace(slide, 'Content', pic);
    replace(slide, 'Title', erase(imgFiles(k).name, '.png'));
end

close(ppt);
disp('PowerPoint generated: comparison_results.pptx');







%% SECOND PLOT (1,5)
x5 = loadXRMS(pathseq5);

% Axial middle slice
showImagesSideBySide('axial', 60, [0 2.5], ...
    x1, x5, ...
    'Titles', {'Reference', 'No RF SPOIL'});
exportgraphics(gcf, [savefolder,'plot_axial_slice60_exp2.png'], 'Resolution', 300);


% Axial middle slice
showImagesSideBySide('axial', 120, [0 2.5], ...
    x1, x5, ...
    'Titles', {'Reference', 'No RF SPOIL'});
exportgraphics(gcf, [savefolder,'plot_axial_slice120_exp2.png'], 'Resolution', 300);
% Axial middle slice
showImagesSideBySide('axial', 180, [0 2.5], ...
    x1, x5, ...
    'Titles', {'Reference', 'No RF SPOIL'});
exportgraphics(gcf, [savefolder,'plot_axial_slice180_exp2.png'], 'Resolution', 300);


% Coronal middle slice
showImagesSideBySide('coronal', 60, [0 2.5], ...
    x1, x5, ...
    'Titles', {'Reference', 'No RF SPOIL'});
exportgraphics(gcf, [savefolder,'plot_coronal_slice60_exp2.png'], 'Resolution', 300);

% Coronal middle slice
showImagesSideBySide('coronal', 120, [0 2.5], ...
    x1, x5, ...
    'Titles', {'Reference', 'No RF SPOIL'});
exportgraphics(gcf, [savefolder,'plot_coronal_slice120_exp2.png'], 'Resolution', 300);

% Coronal middle slice
showImagesSideBySide('coronal', 180, [0 2.5], ...
    x1, x5, ...
    'Titles', {'Reference', 'No RF SPOIL'});
exportgraphics(gcf, [savefolder,'plot_coronal_slice180_exp2.png'], 'Resolution', 300);

% Saggital middle slice
showImagesSideBySide('sagittal', 60, [0 2.5], ...
    x1, x5, ...
    'Titles', {'Reference', 'No RF SPOIL'});
exportgraphics(gcf, [savefolder,'plot_sagittal_slice60_exp2.png'], 'Resolution', 300);

% Saggital middle slice
showImagesSideBySide('sagittal', 120, [0 2.5], ...
    x1, x5, ...
    'Titles', {'Reference', 'No RF SPOIL'});
exportgraphics(gcf, [savefolder,'plot_sagittal_slice120_exp2.png'], 'Resolution', 300);

% Saggital middle slice
showImagesSideBySide('sagittal', 180, [0 2.5], ...
    x1, x5, ...
    'Titles', {'Reference', 'No RF SPOIL'});
exportgraphics(gcf, [savefolder,'plot_sagittal_slice180_exp2.png'], 'Resolution', 300);

%% THIRD PLOT (1,6,7)
x6 = loadXRMS(pathseq6);
x6 = flip( permute(x6, [2 1 3]), 2 );
x7 = loadXRMS(pathseq7);
x7 = flip( permute(x7, [2 1 3]), 2 );

% Axial middle slice
showImagesSideBySide('axial', 60, [0 2.5], ...

exportgraphics(gcf, [savefolder,'plot_axial_slice60_exp3.png'], 'Resolution', 300);

% Axial middle slice
showImagesSideBySide('axial', 60, [0 2.5], ...
    x1, x6, x7, ...
    'Titles', {'Reference (good)', 'Fibonacci number (best)','Not Fibonacci Number (eddy currents?)'});
exportgraphics(gcf, [savefolder,'plot_axial_slice60_exp3.png'], 'Resolution', 300);


% Axial middle slice
showImagesSideBySide('axial', 120, [0 2.5], ...
    x1, x6, x7, ...
    'Titles', {'Reference (good)', 'Fibonacci number (best)','Not Fibonacci Number (eddy currents?)'});
exportgraphics(gcf, [savefolder,'plot_axial_slice120_exp3.png'], 'Resolution', 300);
% Axial middle slice
showImagesSideBySide('axial', 180, [0 2.5], ...
    x1, x6, x7, ...
    'Titles', {'Reference (good)', 'Fibonacci number (best)','Not Fibonacci Number (eddy currents?)'});
exportgraphics(gcf, [savefolder,'plot_axial_slice180_exp3.png'], 'Resolution', 300);


% Coronal middle slice
showImagesSideBySide('coronal', 60, [0 2.5], ...
    x1, x6, x7, ...
    'Titles', {'Reference (good)', 'Fibonacci number (best)','Not Fibonacci Number (eddy currents?)'});
exportgraphics(gcf, [savefolder,'plot_coronal_slice60_exp3.png'], 'Resolution', 300);

% Coronal middle slice
showImagesSideBySide('coronal', 120, [0 2.5], ...
    x1, x6, x7, ...
    'Titles', {'Reference (good)', 'Fibonacci number (best)','Not Fibonacci Number (eddy currents?)'});
exportgraphics(gcf, [savefolder,'plot_coronal_slice120_exp3.png'], 'Resolution', 300);

% Coronal middle slice
showImagesSideBySide('coronal', 180, [0 2.5], ...
    x1, x6, x7, ...
    'Titles', {'Reference (good)', 'Fibonacci number (best)','Not Fibonacci Number (eddy currents?)'});
exportgraphics(gcf, [savefolder,'plot_coronal_slice180_exp3.png'], 'Resolution', 300);

% Saggital middle slice
showImagesSideBySide('sagittal', 60, [0 2.5], ...
    x1, x6, x7, ...
    'Titles', {'Reference (good)', 'Fibonacci number (best)','Not Fibonacci Number (eddy currents?)'});
exportgraphics(gcf, [savefolder,'plot_sagittal_slice60_exp3.png'], 'Resolution', 300);

% Saggital middle slice
showImagesSideBySide('sagittal', 120, [0 2.5], ...
    x1, x6, x7, ...
    'Titles', {'Reference (good)', 'Fibonacci number (best)','Not Fibonacci Number (eddy currents?)'});
exportgraphics(gcf, [savefolder,'plot_sagittal_slice120_exp3.png'], 'Resolution', 300);

% Saggital middle slice
showImagesSideBySide('sagittal', 180, [0 2.5], ...
    x1, x6, x7, ...
    'Titles', {'Reference (good)', 'Fibonacci number (best)','Not Fibonacci Number (eddy currents?)'});
exportgraphics(gcf, [savefolder,'plot_sagittal_slice180_exp3.png'], 'Resolution', 300);

% FOURTH PLOT (NEED TO RECON AT LEAST TWO BINS)

