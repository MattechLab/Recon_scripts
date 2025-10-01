clc;
addpath(genpath('/Users/cag/Documents/forclone/Recon_scripts'));
addpath(genpath('/Users/cag/Documents/forclone/pulseq_v15'));
addpath(genpath('/Users/cag/Documents/forclone/monalisa'));


saveflag = 0;
%% Initialize the directories and acquire the Coil
subject_num = 2;
datasetDir = '/Users/cag/Documents/Dataset/datasets/250919/';
reconDir = '/Users/cag/Documents/Dataset/recon_results/250919/';
seqFolder = "/Users/cag/Documents/Dataset/datasets/250919/";
mask_note_list{2}= 'swap1_FA4_RF2_rfmod2_traj0Orig_PhNeg';
mask_note_list{10}= 'swap1_FA6_RF2_rfmod2_trajOrig_PhNeg';

mask_note = mask_note_list{subject_num};

if subject_num == 2
    meas_name_suffix = '_MID00292_FID59708_yiweiseq2';
    hc_name_suffix = ' ';
    bc_name_suffix = ' ';
    coilsens_name_suffix = '_MID00290_FID59706_AdjCoilSens';
    nShot = 1000;
    nSeg = 22;
    seqName = "yj_seq2_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_traj0Orig_PhNeg.seq";

elseif subject_num == 10
    meas_name_suffix = '_MID00293_FID59709_yiweiseq10';
    hc_name_suffix = ' ';
    bc_name_suffix = ' ';
    coilsens_name_suffix = '_MID00290_FID59706_AdjCoilSens';
    nShot = 1000;
    nSeg = 22;
    seqName = "yj_seq10_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA6_RF2_rfmod2_trajOrig_PhNeg.seq";

end

meas_name = ['meas', meas_name_suffix];
hc_name = ['meas', hc_name_suffix];
bc_name = ['meas', bc_name_suffix];
coilsense_name =  ['meas', coilsens_name_suffix];

measureFile = [datasetDir, meas_name,'.dat'];
bodyCoilFile = [datasetDir, bc_name,'.dat'];
arrayCoilFile = [datasetDir, hc_name,'.dat'];
coilSenseFile = [datasetDir, coilsense_name,'.dat'];
%% Load and Configure Data
reader = createRawDataReader(measureFile, true); %true: automatic--disable UI false: check UI
% Acquisition from Bern need to manually define the following part!!
reader.acquisitionParams.nSeg = nSeg;
reader.acquisitionParams.nShot = nShot; % in case no validation UI
reader.acquisitionParams.nShot_off = 20;
%%
if subject_num == 0 %no idea sequence in this dataset
    reader.acquisitionParams.traj_type = 'full_radial3_phylotaxis';
else
     reader.acquisitionParams.traj_type = 'pulseq';
     reader.acquisitionParams.pulseqTrajFile_name = seqFolder + ...
    seqName;
     % check if the hash from pulseq sequence and from twix match each other
    isMatch = check_hash(measureFile,reader.acquisitionParams.pulseqTrajFile_name);
end

% Ensure consistency in number o1f shot-off points
nShotOff = reader.acquisitionParams.nShot_off;

%% Parameters
dK_u = [1, 1, 1] ./ reader.acquisitionParams.FoV;   % Cartesian grid spacing
N_u = [48, 48, 48];             % Adjust this value as needed
nCh_array =  reader.acquisitionParams.nCh;
nCh_body     = 2;
%%
flipCalibData_flag = 1;
inverse_shift_flag = 0;
C = estimateCoilSens_Calib_adjCoilSens( reader.acquisitionParams, flipCalibData_flag, coilSenseFile, measureFile, inverse_shift_flag);

%%


%% Load the raw data and compute trajectory and volume elements
y_tot = reader.readRawData(true, true);  % Filter nshotoff and SI
t_tot = bmTraj(reader.acquisitionParams);                       % Compute trajectory
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements
%%



