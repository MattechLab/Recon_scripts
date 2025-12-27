%% Author: Yiwei
% This function converts mat file into nifti nii format
% for the following control by spm
% Feb 23. 2025
% Define the path to your .mat file and the output NIfTI file
%% Drag the .mat file into matlab 
% and save x into volume_data

volume_data = x;

%% Replace with your desired output NIfTI file path
    
nifti_folder = fullfile('/Users/cag/Documents/Dataset/recon_results/251120_card/output/', ...
    'card_th10_low0.9_high1.1/nifti');

if isfolder(nifti_folder)
    disp('The nifti_folder will be: ')
    disp(nifti_folder)
else
    mkdir(nifti_folder);
    disp('The nifti_folder is created: ')
    disp(nifti_folder)
end

nvolume = size(volume_data, 1);
disp(['number of volumes: ',num2str(nvolume)]);
%%
for idx = 1:nvolume
    vol_i = abs(volume_data{idx});
    % Define NIfTI metadata (optional but recommended for completeness)
    % You can adjust these properties according to your needs.
    % NifTi file for each volume
    if idx<=0
        nifti_file = fullfile(nifti_folder, strcat('volume_0', num2str(idx), '.nii'));
    else
        nifti_file = fullfile(nifti_folder, strcat('volume_', num2str(idx), '.nii'));
    end
    niftiwrite(vol_i, nifti_file);
    disp(['NIfTI Data has been saved in folder: ', nifti_file]);
end



