% =====================================================
% Author: Yiwei Jia
% Date: June 05
% ------------------------------------------------
% [Coil sensitivity] -> binning mask eMask -> Mitosius
% Update: this script is derived from Demo script
% by Mauro in Monalisa version Feb.5
% The old script has issue when running mask generation
% With readers, the param setting is more organized
% =====================================================

clc;
addpath(genpath('/Users/cag/Documents/forclone/Recon_scripts'));
addpath(genpath('/Users/cag/Documents/forclone/pulseq'));


%% Initialize the directories and acquire the Coil

saveflag = 1;
%
datasetDir = '/Users/cag/Documents/Dataset/datasets/251109/';
reconDir = '/Users/cag/Documents/Dataset/recon_results/251109/';
seqFolder = '/Users/cag/Documents/Dataset/datasets/251109/';
% meas_MID00035_FID09200_wurst_40_short.dat
% meas_MID00036_FID09201_wurst_40.dat
% meas_MID00052_FID09217_AdjCoilSens.dat
% meas_MID00053_FID09218_hemo_stable.dat
% meas_MID00057_FID09222_yiwei_hc.dat
% meas_MID00064_FID09229_yiwei_real_bc.dat
% meas_MID00065_FID09230_hemo_motion.dat
% yj_seq10_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_40.seq
% yj_seq11_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_80.seq
% yj_seq13_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_60.seq
% yj_seq14_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_40_short.seq
% yj_seq20_t1w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_traj_ptp_7T_500.seq
% yj_seq30_t1w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_hemo_fid_trajPTP_44_2202.seq
% yj_seq31_t1w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_hemo_fid_trajPTP_44_1000.seq



mask_note_list={'JB_321p18_40','JB_646p92_40', ...
                            'pq_wurst_40', 'JB_646p92_80', ...
                            'pq_wurst_80', 'pq_wurst_40_321p18', ...
                            'JB_646p92_60', 'pq_wurst_60'};

mask_note = mask_note_list{subject_num};

if subject_num == 1
    meas_name = 'meas_MID00164_FID326833_JB_321p18_40';
    hc_name = ' ';
    bc_name = ' ';
    nShot = 500;
    nSeg = 44;
    seqName = "yj_seq14_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_40_short.seq";

elseif subject_num == 2
    meas_name = 'meas_MID00165_FID326834_JB_646p92_40';
    hc_name = ' ';
    bc_name = ' ';
    nShot = 500;
    nSeg = 44;
    seqName = "yj_seq10_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_40.seq";

elseif subject_num == 3
    meas_name = 'meas_MID00166_FID326835_pq_wurst_40';
    hc_name = ' ';
    bc_name = ' ';
    nShot = 500;
    nSeg = 44;
    seqName = "yj_seq10_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_40.seq";

elseif subject_num == 4
    meas_name = 'meas_MID00167_FID326836_JB_646p92_80';
    hc_name = ' ';
    bc_name = ' ';
    nShot = 500;
    nSeg = 44;
    seqName = "yj_seq11_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_80.seq";

elseif subject_num == 5
    meas_name = 'meas_MID00168_FID326837_pq_wurst_80';
    hc_name = ' ';
    bc_name = ' ';
    nShot = 500;
    nSeg = 44;
    seqName = "yj_seq11_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_80.seq";

elseif subject_num == 6
    meas_name = 'meas_MID00169_FID326838_pq_wurst_40_321p18';
    hc_name = ' ';
    bc_name = ' ';
    nShot = 500;
    nSeg = 44;
    seqName = "yj_seq14_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_40_short.seq";

elseif subject_num == 7
    meas_name = 'meas_MID00170_FID326839_JB_646p92_60';
    hc_name = ' ';
    bc_name = ' ';
    nShot = 500;
    nSeg = 44;
    seqName = "yj_seq13_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_60.seq";

elseif subject_num == 8
    meas_name = 'meas_MID00171_FID326840_pq_wurst_60';
    hc_name = ' ';
    bc_name = ' ';
    nShot = 500;
    nSeg = 44;
    seqName = "yj_seq13_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_60.seq";

end

measureFile = [datasetDir, meas_name,'.dat'];
bodyCoilFile = [datasetDir, bc_name,'.dat'];
arrayCoilFile = [datasetDir, hc_name,'.dat'];


%% Load and Configure Data

reader = createRawDataReader(measureFile, true);
% Acquisition from Bern need to manually define the following part!!
reader.acquisitionParams.nSeg = nSeg;
reader.acquisitionParams.nShot = nShot; % in case no validation UI
reader.acquisitionParams.nShot_off = 14;
%%
if ismember(subject_num, [1 2 4 7]) %no idea sequence in this dataset
    reader.acquisitionParams.traj_type = 'pulseq';
    reader.acquisitionParams.pulseqTrajFile_name = seqFolder + ...
    seqName;
else
     reader.acquisitionParams.traj_type = 'pulseq';
     reader.acquisitionParams.pulseqTrajFile_name = seqFolder + ...
    seqName;
     % check if the hash from pulseq sequence and from twix match each other
    isMatch = check_hash(measureFile,reader.acquisitionParams.pulseqTrajFile_name);
end


% Ensure consistency in number of shot-off points
nShotOff = reader.acquisitionParams.nShot_off;
%

%% Load the raw data and compute trajectory and volume elements
y_tot = reader.readRawData(true, true);  % Filter nshotoff and SI
t_tot = bmTraj(reader.acquisitionParams);                       % Compute trajectory
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements

%% ==============================================
% Warning: due to the memory limit, make sure the matrix size <=240
matrix_size = 240;  % Max nominal spatial resolution
N_u = [matrix_size, matrix_size, matrix_size];
dK_u = [1, 1, 1]./240;

% ------
nCh = size(y_tot, 1);
nCh
nFr = 1;
x0 = cell(nCh, 1);
for i = 1:nFr
    for iCh = 1:nCh
    x0{iCh} = bmMathilda(y_tot(iCh,:), t_tot, ve_tot, [], N_u, N_u, dK_u, [], [], [], []);
    disp(['Processing channel: ', num2str(iCh),'/', num2str(nCh)])
   
    end
end

%
bmImage(x0);

%
x0Dir = [reconDir, '/Sub00',num2str(subject_num),'/T1_LIBRE_woBinning/output/mask_',mask_note,'/'];
 
if ~isfolder(x0Dir)
    % If it doesn't exist, create it
    mkdir(x0Dir);
    disp(['Directory created: ', x0Dir]);
else
    disp(['Directory already exists: ', x0Dir]);
end
x0Path = fullfile(x0Dir, 'x0.mat');
if saveflag
    % Save the x0 to the .mat file
    save(x0Path, 'x0', '-v7.3');
    disp('x0 has been saved here:')
    disp(x0Path);
end
%

%% Root mean square across the channels
% Initialize an array to store sum of squared images
[nx, ny, nz] = size(x0{1});  % Get the dimensions (240,240,240)
numCoils = numel(x0);  % Number of coils (20)

sum_of_squares = zeros(nx, ny, nz, 'single');  % Preallocate in single precision

% Compute sum of squared images

for coil = 1:numCoils
    % straightforward
    % sum_of_squares = sum_of_squares + abs(x0{coil}).^2;
    % eliminate extra square-root step
    sum_of_squares = sum_of_squares + real(x0{coil}.*conj(x0{coil}));
end

% Compute the root mean square (RMS)
xrms = sqrt(sum_of_squares / numCoils);  % Normalize by the number of coils

xrmsPath = fullfile(x0Dir, 'xrms.mat');

if saveflag
    % Save the xrms to the .mat file
    save(xrmsPath, 'xrms', '-v7.3');
    disp('xrmsPath has been saved here:')
    disp(xrmsPath)
end
bmImage(xrms)


