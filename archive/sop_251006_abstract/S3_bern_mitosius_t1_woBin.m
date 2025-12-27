clc;
addpath(genpath('/Users/cag/Documents/forclone/Recon_scripts'));
addpath(genpath('/Users/cag/Documents/forclone/pulseq_v15'));
addpath(genpath('/Users/cag/Documents/forclone/monalisa'));

saveflag = 1;
clear; close all;
%% Initialize the directories and acquire the Coil
for subject_num = [4]
for datatype = [4]

subject_suffix = {'_ml', '_jb', '_yj',  '_phantom'};
mask_note_list{1}= 'idea_ori'; mask_note_list{2}= 'idea_ptp';
mask_note_list{3}= 'pq_ori'; mask_note_list{4}= 'pq_ptp';
mask_note = mask_note_list{datatype};
if datatype == 1 || datatype == 3
    c_note = 'mask_ori';
else
    c_note = 'mask_ptp';
end

datasetDir = ['/Users/cag/Documents/Dataset/datasets/251006_bern_abs/', 'sub',num2str(subject_num), subject_suffix(subject_num), '/'];
seqFolder = ['/Users/cag/Documents/Dataset/datasets/251006_bern_abs/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];
reconDir = ['/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];

seqName_list = { 'yj_seq2_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_traj0Orig_PhNeg.seq', ...
    'yj_seq8_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_trajPTP_PhNeg.seq', ...
    'yj_seq2_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_traj0Orig_PhNeg.seq', ...
    'yj_seq8_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_trajPTP_PhNeg.seq', ...
    'yj0_seq2_t1w_libre_pre_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_traj0Orig_PhNeg.seq', ...
    'yj0_seq8_t1w_libre_pre_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_trajPTP_PhNeg.seq'};

seqName = seqName_list{datatype};

if subject_num == 1
meas_name_list = {'meas_MID00229_FID321180_JB_LIBRE2p2_a8_woPERewinder.dat', ...
                                'meas_MID00232_FID321183_EP_GRE_LIBRE2p2_triggered_pole_18x547.dat', ...
                                'meas_MID00233_FID321184_yj_seq2.dat', ...
                                'meas_MID00234_FID321185_yj_seq8.dat'};

nShot_list = {1000,233,1000,233};
nSeg_list = {22,88,22,88};

elseif subject_num == 2
    meas_name_list = {'meas_MID00262_FID321213_JB_LIBRE2p2_a8_woPERewinder.dat', ...
                                    'meas_MID00263_FID321214_EP_GRE_LIBRE2p2_triggered_pole_18x547.dat', ...
                                    'meas_MID00264_FID321215_yj_seq2.dat', ...
                                    'meas_MID00265_FID321216_yj_seq8.dat'};

    nShot_list = {1000,233,1000,233};
    nSeg_list = {22,88,22,88};

elseif subject_num == 3
    meas_name_list = {'meas_MID00289_FID321240_JB_LIBRE2p2_a8_woPERewinder.dat', ...
                                        'meas_MID00290_FID321241_EP_GRE_LIBRE2p2_triggered_pole_18x547.dat', ...
                                        'meas_MID00291_FID321242_yj_seq2.dat', ...
                                        'meas_MID00292_FID321243_yj_seq8.dat'};

    nShot_list = {1000,233,1000,233};
    nSeg_list = {22,88,22,88};
else
     meas_name_list = {'meas_MID00337_FID321288_JB_LIBRE2p2_a8_woPERewinder.dat', ...
                                        'meas_MID00338_FID321289_EP_GRE_LIBRE2p2_triggered_pole_18x547.dat', ...
                                        'meas_MID00339_FID321290_yj_seq2.dat', ...
                                        'meas_MID00340_FID321291_yj_seq8.dat'};

    nShot_list = {1000,233,1000,233};
    nSeg_list = {22,88,22,88};

end

meas_name = meas_name_list{datatype};

nShot = nShot_list{datatype};
nSeg = nSeg_list{datatype};

datasetDir = [datasetDir{:}];
reconDir = [reconDir{:}];
seqFolder = [seqFolder{:}];
measureFile = [datasetDir, meas_name];


%

otherDir = [reconDir, '/T1_LIBRE_woBinning/other/'];

% Check if the directory exists
if ~isfolder(otherDir)
    % If it doesn't exist, create it
    mkdir(otherDir);
    disp(['Directory created: ', otherDir]);
else
    disp(['Directory already exists: ', otherDir]);
end





% Load and Configure Data
reader = createRawDataReader(measureFile, true);
% Acquisition from Bern need to manually define the following part!!
reader.acquisitionParams.nSeg = nSeg;
reader.acquisitionParams.nShot = nShot; % in case no validation UI
reader.acquisitionParams.nShot_off = 20;
%
if subject_num == 0 %no idea sequence in this dataset
    reader.acquisitionParams.traj_type = 'full_radial3_phylotaxis';
else
     reader.acquisitionParams.traj_type = 'pulseq';
     reader.acquisitionParams.pulseqTrajFile_name = strcat(seqFolder, seqName);
     % check if the hash from pulseq sequence and from twix match each other
     if datatype > 2
        isMatch = check_hash(measureFile,reader.acquisitionParams.pulseqTrajFile_name);
     end
end

% Ensure consistency in number o1f shot-off points
nShotOff = reader.acquisitionParams.nShot_off;
%
% Load the raw data and compute trajectory and volume elements
y_tot = reader.readRawData(true, true);  % Filter nshotoff and SI
t_tot = bmTraj(reader.acquisitionParams);                       % Compute trajectory
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements

% Step 2: Load Coil Sensitivity Maps
% Load the coil sensitivity previously measured

saveCDir     = [reconDir,'/T1_LIBRE_woBinning/C/', c_note];
CfileName = 'C.mat';
CfilePath = fullfile(saveCDir, CfileName);
load(CfilePath, 'C');  % Load sensitivity maps
disp(['C is loaded from:', CfilePath]);
% Adjust grid size for coil sensitivity maps
% Warning: due to the memory limit, make sure the matrix size <=240
matrix_size = 240;  % Max nominal spatial resolution
N_u = [matrix_size, matrix_size, matrix_size];
dK_u = [1, 1, 1]./240;

%
C = bmImResize(C, [48, 48, 48], N_u);

% Step 3: Normalize the Raw Data
if N_u >240
    normalization = false;
else 
    normalization = true;
end
if normalization
    x_tot = bmMathilda(y_tot, t_tot, ve_tot, C, N_u, N_u, dK_u); 
    x0=x_tot;
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


%% Prepare eye mask
eMask = ones(1, nShot*nSeg);
eMask = (eMask>0);
eMask(1:nShotOff*nSeg) = 0;
% Saving data and Convert to Monalisa format
%--------------------------------------------------------------------------    
eMaskFilePath = [otherDir,'eMask_woBin.mat'];

% Save the CMask to the .mat file
save(eMaskFilePath, 'eMask');
disp('eMask has been saved here:')
disp(eMaskFilePath)


% Load eye mask
eMaskFilePath = [otherDir,'eMask_woBin'];

eyeMask = load(eMaskFilePath); 
fields = fieldnames(eyeMask);  % Get the field names
firstField = fields{1};  % Get the first field name
eyeMask = eyeMask.(firstField);  % Access the first field's value
disp(eMaskFilePath)
disp('is loaded!')
% Eleminate the first segment of all the spokes for accuracies

%
size_Mask = size(eyeMask);
nbins = size_Mask(1);
eyeMask = reshape(eyeMask, [nbins, nSeg, nShot]); 
eyeMask(:, 1, :) = []; 

eyeMask(:, :, 1:nShotOff) = []; 
eyeMask = bmPointReshape(eyeMask); 

% Set the folder for mitosius saving

mDir = [reconDir, '/T1_LIBRE_woBinning/mitosius/mask_', mask_note, '/'];

% Run the mitosis function and compute volume elements

[y, t] = bmMitosis(y_tot, t_tot, eyeMask); 
y = bmPermuteToCol(y); 
ve  = bmVolumeElement(t, 'voronoi_full_radial3' ); 

% Save all the resulting datastructures on the disk. You are now ready
% to run your reconstruction

bmMitosius_create(mDir, y, t, ve); 
disp('Mitosius files are saved!')
disp(mDir)

end
end


















