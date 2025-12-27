clear; clc;
% =====================================================
% Author: Yiwei Jia
% Date: Feb 5
% ------------------------------------------------
% Coil sensitivity -> [binning mask eMask] -> Mitosius
% Update: the eyeGenerateBinning is replaced with eyeGenerateBinningWin
% Add a new txt file saved along side with the mask to log the details
% =====================================================
%%
subject_num = 1;
datasetDir = '/Users/cag/Documents/Dataset/datasets/MREyeTrack/';
reconDir = '/Users/cag/Documents/Dataset/recon_results/250917MREyeTrack_nomo/';
ETDir = '/Users/cag/Documents/forclone/hcph-sops-fork/code/eyetracking_MREyeTrack/masks_nomo/';

% 'subject_1_mask_clean_0.3_0.mat'


if subject_num == 1
    otherDir = [reconDir, '/Sub001/nomo//'];
elseif subject_num == 2
    otherDir = [reconDir, '/Sub002/nomo/'];
elseif subject_num == 3
    otherDir = [reconDir, '/Sub003/nomo/'];
else
    otherDir = [reconDir, '/Sub004/nomo/'];
end

% Check if the directory exists
if ~isfolder(otherDir)
    % If it doesn't exist, create it
    mkdir(otherDir);
    disp(['Directory created: ', otherDir]);
else
    disp(['Directory already exists: ', otherDir]);
end

%%
th_ratio = 0.9;
nShotOff = 0; 
nSeg = 22; 
winLen = 7;
cri='nomo';
mask_note = [sprintf('eMask_win%d_th%.2f_',winLen, th_ratio), cri];
eMask = eyeGenerateBinningWin(datasetDir, nShotOff, nSeg,th_ratio, ETDir, winLen, true);
disp(['Preserved readout number: ',num2str(nnz(eMask))])
% Saving data and Convert to Monalisa format
%--------------------------------------------------------------------------    

%save(fullfile(param.savedir,'cMask.mat'),'param');
%disp(['param is saved here:', param.savedir, '\cMask.mat'])

eMaskFilePath = [otherDir, mask_note, '.mat'];

% Save the CMask to the .mat file
save(eMaskFilePath, 'eMask');
disp('eMask has been saved here:')
disp(eMaskFilePath)

% save the log txt
% Define the filename
filename = [otherDir, mask_note, '.txt'];

% Open the file for writing ('w' mode overwrites, 'a' appends)
fid = fopen(filename, 'w');

% Check if the file opened successfully
if fid == -1
    error('Cannot open file for writing.');
end

% Write some text to the file
fprintf(fid, '.\n');
fprintf(fid,['winLen: ', num2str(winLen), '.\n']);
fprintf(fid,['threshold: ', num2str(th_ratio), '.\n']);
fprintf(fid,['criteria: ', cri, '.\n']);
fprintf(fid, ['with Binning, preserved #line: ',num2str(sum(eMask)), ' out of ', num2str(length(eMask)), '.\n' ]);

% Close the file
fclose(fid);

disp('File saved successfully：');
disp(filename)


