clc;clear;
%% Some Flags
FlagSaveSingleMask = false;
FlagSaveBinMask = false;
FlagReadrpTable = true;
FlagRot = true;
FlagTrans = true;
%% Get Path to the raw data
% Prompt user to select Siemens Raw Data file
basefolder = '/Users/cag/Documents/Dataset/datasets/251022/sub1_hemo/';
addpath(genpath(basefolder));
reconDir = '/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/';
% resultsDir = fullfile(reconDir, 'temp_masks_71win_trial');  % Results folder
resultsDir = ['/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/Sub001/' ...
    'T1_LIBRE_Binning/output/sequentialBinning_win15.0s'];
%
[fileName, filePath] = uigetfile({'*.dat', '(*.dat) Siemens Rawdatafile'}, ...
    'Select a Subject Rawdatafile', 'MultiSelect', 'off',basefolder);

if FlagReadrpTable
%%-- Start calculations
% Load the translation and rotation txt
rotTraslFile = "/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/Sub001/T1_LIBRE_Binning/output/sequentialBinning_win15.0s" + ...
    "/rp_volume_01.txt";

% check if the rotTrasFile exists
if exist(fullfile(rotTraslFile),'file')
    disp(['The transform matrix txt file: ', rotTraslFile])
else
    disp('Warning!!! The transform matrix txt file does not exist!!!')
end

rpTable = importdata(rotTraslFile);
% Convert tables in to vectors 
TransParam=[rpTable(:,1)';rpTable(:,2)';rpTable(:,3)']; % translational components
RotParam=[rpTable(:,4)';rpTable(:,5)';rpTable(:,6)']; % rotational components
clear rpTable
end


%% Read the raw data .dat
brainScanFile = fullfile(filePath, fileName);  % Brain scan data file
%
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

nSeg = acquisitionParams.nSeg;  % Number of segments
nShotOff = acquisitionParams.nShot_off;  % Number of off shots (non-steady state)
nMeasuresPerShot = acquisitionParams.nSeg;  % Measurements per shot
nExcludeMeasures = nShotOff * nMeasuresPerShot;  % Total number of measurements to exclude
nLines = acquisitionParams.nLine;  % Total number of radial lines
nShot = acquisitionParams.nShot;
nCol = acquisitionParams.N;


%% Calculate masks
% Define cost time (this is typically a fixed value depending on the scanner type)
costTime = 2.5;  % Siemens-specific, don't change unless known

% Extract timestamp in milliseconds (time of each acquisition)
timeStamp = double(acquisitionParams.timestamp);
timeStamp = timeStamp - min(timeStamp);  % Normalize timestamps to start from 0
timestampMs = timeStamp * costTime;  % Convert to milliseconds



if FlagSaveBinMask

%%%%%%% Bin the image with time sequential binning mask
%%%%%%%%% Teva_recon
% Define temporal window size in seconds
temporalWindowSec = 15;  
% Convert temporal window to milliseconds
temporalWindowMs = temporalWindowSec * 1000;
% Calculate the total duration of valid data
nMasks = size(RotParam, 2); %here I set nBin according to the given param
totalDuration = temporalWindowMs*nMasks;
% Exclude non-steady-state measurements by considering the first few off shots
% Adjust the start time to account for non-steady-state shots
startTime = timestampMs(nExcludeMeasures + 1);
endTime = startTime+totalDuration;

% Initialize the mask matrix with logical false
mask = false(nMasks, nLines);
% Fill the masks: Set to true for measurements that fall within the current temporal window
for i = 1:nMasks
    % Define the start and end of the current time window
    windowStart = startTime + (i - 1) * temporalWindowMs;
    windowEnd = windowStart + temporalWindowMs;
    
    % Create the mask for the current window (True for measurements within the window)
    singlemask = (timestampMs >= windowStart) & (timestampMs < windowEnd);
    
    % Exclude the non-steady-state lines (e.g., SI projection or other artifacts)
    for K = 0:floor(nLines / nMeasuresPerShot)
        idx = 1 + K * nSeg;
        if idx <= nLines
            singlemask(idx) = false;  % Set non-steady-state lines to false
        end
    end
    
    % Assign the mask to the binning matrix
    mask(i, :) = singlemask;
end
% Save Results
% Generate a timestamped filename for saving
if ~isfolder(resultsDir)
    % If it doesn't exist, create it
    mkdir(resultsDir);
    disp(['Directory created: ', resultsDir]);
end
saveName = fullfile(resultsDir, 'win71Binning.mat');

save(saveName, 'mask');
disp(['Sequential bins saved to: ', saveName]);

end


%%
if FlagSaveSingleMask
    nMasks = 1;
    startTime = timestampMs(nExcludeMeasures + 1);
    endTime = timestampMs(end);
    singlemask = false(nMasks, nLines);


    % Create the mask for the current window (True for measurements within the window)
    singlemask = (timestampMs >= startTime) & (timestampMs <= endTime);
    
    % Exclude the non-steady-state lines (e.g., SI projection or other artifacts)
    for K = 0:floor(nLines / nMeasuresPerShot)
        idx = 1 + K * nSeg;
        if idx <= nLines
            singlemask(idx) = false;  % Set non-steady-state lines to false
        end
    end
    
    % Save Results
    % Generate a timestamped filename for saving
    if ~isfolder(resultsDir)
        % If it doesn't exist, create it
        mkdir(resultsDir);
        disp(['Directory created: ', resultsDir]);
    end
    saveName = fullfile(resultsDir, 'singleMask.mat');
    
    save(saveName, 'singlemask');
    disp(['Single mask is saved to: ', saveName]);
  


end

%% Prepare the Rot and Trans according to the size of meas
% extend the param along each volume, so that all the readouts in one
% volume share the same param.
%Note: should exclude selfNav and ShotOff!!
rewrite = 1;
if rewrite
    disp('debugging')
    load('/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/temp_masks/sequentialBinning_win15.0s.mat');
    % repeat Params of 3, nFr for filter_nLines
    RotParam_volume = repmat(RotParam, [1,1,nLines]);
    TransParam_volume = repmat(TransParam, [1,1,nLines]);
    size_Mask = size(mask);
    nbins = size_Mask(1);
    % mask = reshape(mask, [nbins, acquisitionParams.nSeg, acquisitionParams.nShot]); 
    mask_temp = reshape(mask, [1,size(mask,1), size(mask,2)]);
    mask_expand = repmat(mask_temp, [3, 1, 1]);
    % 
    RotParam_volume = RotParam_volume .* mask_expand;
    RotParam_volume = sum(RotParam_volume, 2); 
    RotParam_volume = squeeze(RotParam_volume);
    % 
    TransParam_volume = TransParam_volume .* mask_expand;
    TransParam_volume = sum(TransParam_volume, 2); 
    TransParam_volume = squeeze(TransParam_volume);
    
    RotParam_volume = reshape(RotParam_volume, 3, nSeg, nShot);
    RotParam_volume(:, :, 1:nShotOff) = [];
    RotParam_volume(:, 1, :) = [];
    RotParam_volume = reshape(RotParam_volume, 3, []);
    
    TransParam_volume = reshape(TransParam_volume, 3, nSeg, nShot);
    TransParam_volume(:, :, 1:nShotOff) = [];
    TransParam_volume(:, 1, :) = [];
    TransParam_volume = reshape(TransParam_volume, 3, []);

else
    filter_nLines = nLines - nShotOff*nSeg-(nShot-nShotOff);
    
    % mask with sequential binning is loaded as below, size:[nFr, nLines]
    load('/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/temp_masks/sequentialBinning_win15.0s.mat');
    
    % repeat Params of 3, nFr for filter_nLines
    RotParam_volume = repmat(RotParam, [1,1,filter_nLines]);
    TransParam_volume = repmat(TransParam, [1,1,filter_nLines]);
    
    size_Mask = size(mask);
    nbins = size_Mask(1);
    mask = reshape(mask, [nbins, acquisitionParams.nSeg, acquisitionParams.nShot]); 
    mask(:, 1, :) = []; 
    
    mask(:, :, 1:acquisitionParams.nShot_off) = []; 
    mask = bmPointReshape(mask); 
    mask_temp = reshape(mask, [1,size(mask,1), size(mask,2)]);
    mask_expand = repmat(mask_temp, [3, 1, 1]);
    % 3 (x,y,z)  nFr   filter_nLines
    %
    RotParam_volume = RotParam_volume .* mask_expand;
    RotParam_volume = sum(RotParam_volume, 2); 
    RotParam_volume = squeeze(RotParam_volume);
    
    TransParam_volume = TransParam_volume .* mask_expand;
    TransParam_volume = sum(TransParam_volume, 2); 
    TransParam_volume = squeeze(TransParam_volume);
end

%% bmTraj for the full traj calculation
% In order to get the nLine of traj=total meas
% here I set selfNav_flag = False
% nShot_off = 0;
acquisitionParams.traj_type = 'pulseq';
acquisitionParams.pulseqTrajFile_name = ['/Users/cag/Documents/Dataset/datasets/251022/' ...
    'sub1_hemo/yj_seq3_t1w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_mreye_track_trajPTP.seq'];
% check if the hash from pulseq sequence and from twix match each other
isMatch = check_hash(brainScanFile,acquisitionParams.pulseqTrajFile_name);
%%
t_tot = bmTraj(acquisitionParams);                       % Compute trajectory
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements
acquisitionParams.traj_type = 'full_radial3_phylotaxis';  % Trajectory type


% Rotation
% convert the Euler angle in radians to 3 by 3 rotation matrix  
if FlagRot
    % The reason for assigning sign as -1: pulseq extracted trajectory is
    % the opposite of IDEA coordinates
    sign = -1;
    t_tot_clean = zeros(size(t_tot));

    for iLine = 1:size(RotParam_volume,2)
        Rot_mat = euler_to_rotation(RotParam_volume(:, iLine), sign);
        
        te_tot_reshape =    reshape(t_tot(:,:,iLine), 3, []);    
        te_tot_rotated = Rot_mat * te_tot_reshape; 
        te_tot_rotated = reshape(te_tot_rotated, 3, nCol, []);
    
        t_tot_clean(:,:,iLine) = te_tot_rotated;
    end
    % newkx=reshape(t_tot_rotated(1,:,:),[param.Np,param.Nseg,param.Nshot]);
    % newky=reshape(t_tot_rotated(2,:,:),[param.Np,param.Nseg,param.Nshot]);
    % newkz=reshape(t_tot_rotated(3,:,:),[param.Np,param.Nseg,param.Nshot]);
else
    t_tot_clean =  t_tot;


end
% Translation
if FlagTrans
    sign = -1;
    kx = t_tot(1,:,:);
    ky = t_tot(2,:,:);
    kz = t_tot(3,:,:);
    % Note: here we calculate with the original trajectory, not the new one from rotated...           
    
    tempx = kx.*reshape(sign * TransParam_volume(1,:), 1,1,[]);       
    tempy = ky.*reshape(sign * TransParam_volume(2,:), 1,1,[]); 
    tempz = kz.*reshape(sign * TransParam_volume(3,:), 1,1,[]);  
    PhaseOffset = exp(-2*pi*1i*(tempx + tempy + tempz));
    % add the PhaseOffset to y
    y_tot = load_y_tot(acquisitionParams, 1, 1);

    y_tot_phase = y_tot .* PhaseOffset;
    y_tot_clean = y_tot_phase;

               
else
    y_tot_clean = brainCoilReader.readRawData(true, true); % DO NOT filter nshotoff and SI

end
%%
clearvars y_tot t_tot y_tot_phase kx ky kz tempx tempy tempz

%% mitosius
mask_note = 'sequentialBinning_win15.0';
allLinesBinningPath = ['/Users/cag/Documents/Dataset/recon_results/251022/' ...
    'sub1_hemo/temp_masks/allLinesBinning.mat'];
CfileName = 'C.mat'; saveCDir = [reconDir, '/T1_LIBRE_woBinning/C/mask_noBin/'];
CfilePath = fullfile(saveCDir, CfileName); load(CfilePath); 
%%
correction_mitosius(t_tot_clean, y_tot_clean, reconDir, allLinesBinningPath, acquisitionParams, mask_note,C)
%%
x0 = correction_reconstruction(reconDir, mask_note,C);

 %%
 function R = euler_to_rotation(R_array, sign)
    % Compute rotation matrices for X, Y, Z axes
    Rx= sign*R_array(1); 
    Ry= sign*R_array(2); 
    Rz= sign*R_array(3);

    Rx_mat = [1  0       0      ;
              0  cos(Rx) -sin(Rx);
              0  sin(Rx)  cos(Rx)];

    Ry_mat = [cos(Ry)  0  sin(Ry);
              0        1  0      ;
             -sin(Ry)  0  cos(Ry)];

    Rz_mat = [cos(Rz) -sin(Rz)  0;
              sin(Rz)  cos(Rz)  0;
              0        0        1];

    % Combine rotations: R = Rz * Ry * Rx
    R = Rz_mat * Ry_mat * Rx_mat;
end


function correction_mitosius(t_tot_clean, y_tot_clean, reconDir, allLinesBinningPath, acquisitionParams, mask_note, C)
% Prepare the input variable
t_tot = t_tot_clean;
y_tot = y_tot_clean;
p = acquisitionParams;

mDir = [reconDir, '/Sub001/T1_LIBRE_Binning/mitosius/clean_', mask_note, '/'];


% Load the binning mask
tempMask = load(allLinesBinningPath); 
fields = fieldnames(tempMask);  % Get the field names
firstField = fields{1};  % Get the first field name
tempMask = tempMask.(firstField);  % Access the first field's value
disp(allLinesBinningPath)
disp('is loaded!')

% Prepare the binning mask
size_Mask = size(tempMask);
nbins = size_Mask(1);
tempMask = reshape(tempMask, [nbins, p.nSeg, p.nShot]); 
tempMask(:, 1, :) = []; 
p=acquisitionParams;
tempMask(:, :, 1:p.nShot_off) = []; 
tempMask = bmPointReshape(tempMask); 


% Adjust grid size for coil sensitivity maps
FoV = p.FoV;  % Field of View

matrix_size = 120;  % Max nominal spatial resolution
N_u = [matrix_size, matrix_size, matrix_size];
dK_u = [1, 1, 1]./FoV;
C = bmImResize(C, [48, 48, 48], N_u);

% Normalize the Raw Data
if real(y_tot)<1
    y_tot = y_tot/(3e-9); 
    y_tot(1,1,123)
    disp('y_tot is normalized by 3e-9.')
else
    disp("it is already normalized!")
end

[y, t] = bmMitosis(y_tot, t_tot, tempMask); 
y = bmPermuteToCol(y); 
ve  = bmVolumeElement(t, 'voronoi_full_radial3' ); 

bmMitosius_create(mDir, y, t, ve); 
disp('Mitosius files are saved!')
disp(mDir)

end


function x0 = correction_reconstruction(reconDir, mask_note, C)

mDir = [reconDir, '/Sub001/T1_LIBRE_Binning/mitosius/clean_', mask_note, '/'];


y   = bmMitosius_load(mDir, 'y'); 
t   = bmMitosius_load(mDir, 't'); 
ve  = bmMitosius_load(mDir, 've');
disp('Mitosius has been loaded!')

Matrix_size = 120;
ReconFov = 240; %mm
N_u     = [Matrix_size, Matrix_size, Matrix_size]; % Matrix size: Size of the Virtual cartesian grid in the fourier space (regridding)
n_u     = [Matrix_size, Matrix_size, Matrix_size]; % Image size (output)
dK_u    = [1, 1, 1]./ReconFov; % Spacing of the virtual cartesian grid
nFr     = size(y,1); 

C = bmImResize(C, [48, 48, 48], N_u);

x0 = cell(nFr, 1);
for i = 1:nFr
    x0{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, n_u, dK_u, [], [], [], []);
end

%
%
x0Dir = [reconDir, '/Sub001/T1_LIBRE_Binning/output/clean_',mask_note,'/'];
 
if ~isfolder(x0Dir)
    % If it doesn't exist, create it
    mkdir(x0Dir);
    disp(['Directory created: ', x0Dir]);
else
    disp(['Directory already exists: ', x0Dir]);
end
x0Path = fullfile(x0Dir, 'x0.mat');

bmImage(x0);
save(x0Path, 'x0', '-v7.3');
disp('x0 has been saved here:')
disp(x0Path);

end


function [y_tot] = load_y_tot(acquisitionParams, flagSS, flagExcludeSI)
    load('/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/main_readouts.mat');
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

end