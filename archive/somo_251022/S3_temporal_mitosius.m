clear; clc;
% =====================================================
% Author: Yiwei Jia
% Date: Feb 5
% ------------------------------------------------
% Coil sensitivity -> binning mask eMask -> [Mitosius]
% Update: the eyeGenerateBinning is replaced with eyeGenerateBinningWin
% Add a new txt file saved along side with the mask to log the details
% =====================================================


%%
subject_num = 1;
datatype = 1;
subject_suffix = {'_hemo'};

datasetDir = ['/Users/cag/Documents/Dataset/datasets/251022/', 'sub',num2str(subject_num), subject_suffix(subject_num), '/'];
seqFolder = ['/Users/cag/Documents/Dataset/datasets/251022/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];
reconDir = ['/Users/cag/Documents/Dataset/recon_results/251022/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];
datasetDir = [datasetDir{:}];
reconDir = [reconDir{:}];
seqFolder = [seqFolder{:}];
resultsDir = fullfile(reconDir, 'temp_masks');  % Results folder
seqName =  'yj_seq3_t1w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_mreye_track_trajPTP.seq';



brainScanFile = [datasetDir, 'meas_MID00408_FID04433_YJ_head.dat'];
if subject_num == 1
    otherDir = [reconDir, '/temp_masks/'];
end


% Check if the directory exists
if ~isfolder(otherDir)
    % If it doesn't exist, create it
    mkdir(otherDir);
    disp(['Directory created: ', otherDir]);
else
    disp(['Directory already exists: ', otherDir]);
end


if subject_num == 1
    saveCDirList = {'/T1_LIBRE_Binning/C/','/T1_LIBRE_woBinning/C/mask_noBin/'};
end

%% Step 1: Load the Raw Data

% load the previously saved main_readouts
nav_readouts = load('/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/nav_readouts.mat');
main_readouts = load('/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/main_readouts.mat');
%%
flagSS = 1; % filter non SS off
flagExcludeSI = 1; % filter SI off
acquisitionParams = bmMriAcquisitionParam([]);
% Siemens-specific data extraction logic
myTwix = mapVBVD_JH_for_hemo(brainScanFile, 'fidnav', 1);

acquisitionParams.nShot = 1597;
acquisitionParams.nSeg = 44;
acquisitionParams.nCh = 42;
acquisitionParams.N = 480;
acquisitionParams.FoV = 240;
acquisitionParams.nEcho = 1;
acquisitionParams.nShot_off = 14;
acquisitionParams.selfNav_flag = flagExcludeSI;
acquisitionParams.nLine = acquisitionParams.nShot *acquisitionParams.nSeg;
timestamp_withFID   = myTwix.image.timestamp;
acquisitionParams.timestamp = timestamp_withFID(:,1:2:end);


%%
main_readouts   = permute(main_readouts, [2, 1, 3]);
main_readouts   = reshape(main_readouts, [acquisitionParams.nCh, acquisitionParams.N, acquisitionParams.nSeg, acquisitionParams.nShot]);
if flagSS
    if acquisitionParams.nShot_off  > 0
        main_readouts(:, :, :, 1:acquisitionParams.nShot_off) = [];
        nShot = acquisitionParams.nShot - acquisitionParams.nShot_off;
    else
        nShot = acquisitionParams.nShot;
    end
else
        nShot = acquisitionParams.nShot;
end


if flagExcludeSI
    main_readouts(:, :, 1, :) = [];
    nSeg = acquisitionParams.nSeg - 1;
else
    nSeg = acquisitionParams.nSeg;
end
% Reshape the output to [nCh, N, nSeg*nShot]
y_tot  = reshape(main_readouts, [acquisitionParams.nCh, acquisitionParams.N, nSeg*nShot]);

%% Extract trajectory from pulseq and compute volume elements
acquisitionParams.traj_type = 'pulseq';
acquisitionParams.pulseqTrajFile_name = strcat(seqFolder, seqName);
% check if the hash from pulseq sequence and from twix match each other
isMatch = check_hash(brainScanFile,acquisitionParams.pulseqTrajFile_name);

t_tot = bmTraj(acquisitionParams);                       % Compute trajectory
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements

%% Step 2: Load Coil Sensitivity Maps
% Load the coil sensitivity previously measured
saveCDir     = [reconDir,saveCDirList{2}];
CfileName = 'C.mat';
CfilePath = fullfile(saveCDir, CfileName);
load(CfilePath, 'C');  % Load sensitivity maps
disp(['C is loaded from:', CfilePath]);

%% 
matrix_size = 120;  % Max nominal spatial resolution
N_u = [matrix_size, matrix_size, matrix_size];
dK_u = [1, 1, 1]./acquisitionParams.FoV;
%
C = bmImResize(C, [48, 48, 48], N_u);
%% Step 3: Normalize the Raw Data
if N_u >240
    normalization = false;
else 
    normalization = true;
end
if normalization
    x_tot = bmMathilda(y_tot, t_tot, ve_tot, C, N_u, N_u, dK_u); 
    %
    bmImage(x_tot)
    %
    temp_im = getimage(gca);  
    bmImage(temp_im); 
    temp_roi = roipoly; 
    normalize_val = mean(temp_im(temp_roi(:))); 
    % The normalize_val is super small, it is 5e-10, very small
    % again 3e-9
    % The value of one complex point is like: -0.0396 - 0.1162i
    disp('normalize_val')
    disp(normalize_val)
    y_tot(1,1,123)
end
% only once !!!!
if real(y_tot)<1
    if normalization
        y_tot = y_tot/normalize_val; 
        y_tot(1,1,123)
    else
        y_tot = y_tot/(3e-9); 
        y_tot(1,1,123)
    end
else
    disp("it is already normalized!")
end



%% Set the folder for mitosius saving
temporalWindowSec = 15;
maskName = sprintf('sequentialBinning_win%.1fs.mat', temporalWindowSec);
[~, maskNameNoExt] = fileparts(maskName);
saveName = fullfile(resultsDir, maskName);

if subject_num == 1
    mDir = [reconDir, '/Sub001/T1_LIBRE_Binning/mitosius/', maskNameNoExt, '/'];
end
% Prepare eye mask

tempMaskFilePath = fullfile(otherDir,maskName);

tempMask = load(tempMaskFilePath); 

fields = fieldnames(tempMask);  % Get the field names
firstField = fields{1};  % Get the first field name
tempMask = tempMask.(firstField);  % Access the first field's value
disp(tempMaskFilePath)
disp('is loaded!')
% Eleminate the first segment of all the spokes for accuracies

%
size_Mask = size(tempMask);
nbins = size_Mask(1);
tempMask = reshape(tempMask, [nbins, acquisitionParams.nSeg, acquisitionParams.nShot]); 
tempMask(:, 1, :) = []; 

tempMask(:, :, 1:acquisitionParams.nShot_off) = []; 
tempMask = bmPointReshape(tempMask); 


% Run the mitosis function and compute volume elements

[y, t] = bmMitosis(y_tot, t_tot, tempMask); 
y = bmPermuteToCol(y); 
ve  = bmVolumeElement(t, 'voronoi_full_radial3' ); 

% Save all the resulting datastructures on the disk. You are now ready
% to run your reconstruction

bmMitosius_create(mDir, y, t, ve); 
disp('Mitosius files are saved!')
disp(mDir)
































