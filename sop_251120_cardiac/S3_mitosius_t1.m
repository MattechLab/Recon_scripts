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
% subject_num = 1;
datasetDir = '/Users/cag/Documents/Dataset/datasets/250127_acquisition/';
reconDir = '/Users/cag/Documents/Dataset/recon_results/251120_card/';

bodyCoilFile     = [datasetDir, '/meas_MID00345_FID214641_BEAT_LIBREon_eye_BC_BC.dat'];
arrayCoilFile    = [datasetDir, '/meas_MID00346_FID214642_BEAT_LIBREon_eye_HC_BC.dat'];
measureFile = [datasetDir, '/meas_MID00332_FID214628_BEAT_LIBREon_eye_(23_09_24)_sc_trigger.dat'];

otherDir = [reconDir, '/other/'];

% Check if the directory exists
if ~isfolder(otherDir)
    % If it doesn't exist, create it
    mkdir(otherDir);
    disp(['Directory created: ', otherDir]);
else
    disp(['Directory already exists: ', otherDir]);
end


saveCDirList = {'/C/'};



%% Step 1: Load the Raw Data
autoFlag = true;  % Disable validation UI
reader = createRawDataReader(measureFile, autoFlag);
p = reader.acquisitionParams;
p.nSeg = 22;
p.nShot = 2055;
p.traj_type = 'full_radial3_phylotaxis';  % Trajectory type
p.nShot_off = 14; % in case no validation UI
%%
% Load the raw data and compute trajectory and volume elements
y_tot = reader.readRawData(true, true);  % Filter nshotoff and SI
t_tot = bmTraj(p);                       % Compute trajectory
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements

%% Step 2: Load Coil Sensitivity Maps
% Load the coil sensitivity previously measured
saveCDir     = [reconDir,saveCDirList{1}];
CfileName = 'C.mat';
CfilePath = fullfile(saveCDir, CfileName);
load(CfilePath, 'C');  % Load sensitivity maps
disp(['C is loaded from:', CfilePath]);
% Adjust grid size for coil sensitivity maps
FoV = p.FoV;  % Field of View


% ===============================================
matrix_size = 120;  % Max nominal spatial resolution
N_u = [matrix_size, matrix_size, matrix_size];
dK_u = [1, 1, 1]./FoV;
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
end



%% Set the folder for mitosius saving

lowcut_card =  0.9;
highcut_card = 1.1; 
nrCardThreshold = 10;
mask_note = sprintf('card_th%d_low%.1f_high%.1f', nrCardThreshold, lowcut_card, highcut_card);

mDir = [reconDir, '/mitosius/', mask_note, '/'];

%% Prepare eye mask
MaskFilePath = [otherDir, mask_note, '.mat'];
% Save the CMask to the .mat file

cMask = load(MaskFilePath); 

fields = fieldnames(cMask);  % Get the field names
firstField = fields{1};  % Get the first field name
cMask = cMask.(firstField);  % Access the first field's value
disp(MaskFilePath)
disp('is loaded!')
% Eleminate the first segment of all the spokes for accuracies

%
size_Mask = size(cMask);
nbins = size_Mask(1);
cMask = reshape(cMask, [nbins, p.nSeg, p.nShot]); 
cMask(:, 1, :) = []; 

cMask(:, :, 1:p.nShot_off) = []; 
cMask = bmPointReshape(cMask); 


%% Run the mitosis function and compute volume elements

[y, t] = bmMitosis(y_tot, t_tot, cMask); 
y = bmPermuteToCol(y); 
ve  = bmVolumeElement(t, 'voronoi_full_radial3' ); 

% Save all the resulting datastructures on the disk. You are now ready
% to run your reconstruction

bmMitosius_create(mDir, y, t, ve); 
disp('Mitosius files are saved!')
disp(mDir)






















