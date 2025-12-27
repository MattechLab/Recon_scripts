


rdataDir = fullfile('/Users/cag/Documents/Dataset/recon_results/251120_card/output/', ...
    'card_th10_low0.9_high1.1/r_nifti');

rfiles = dir(fullfile(rdataDir, 'r*.nii')); % Find realigned NIfTI files
x = cell(size(rfiles));
for i = 1:numel(rfiles)
    niiPath = fullfile(rdataDir, rfiles(i).name);

    % Read nifti
    x{i}  = niftiread(niiPath);
    % info = niftiinfo(niiPath);
    
end

%% Create output .mat name

matPath = fullfile(rdataDir, 'x_r.mat');

% Save in v7.3 format
save(matPath, 'x', '-v7.3');