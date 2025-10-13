clc;
addpath(genpath('/Users/cag/Documents/forclone/Recon_scripts'));
addpath(genpath('/Users/cag/Documents/forclone/pulseq_v15'));
addpath(genpath('/Users/cag/Documents/forclone/monalisa'));

saveflag = 1;
%% Initialize the directories and acquire the Coil
subject_num = 1;
datatype = 3;

subject_suffix = {'_ml', '_jb', '_yj',  '_phantom'};
mask_note_list{1}= 'idea_ori'; mask_note_list{2}= 'idea_ptp';
mask_note_list{3}= 'pq_ori'; mask_note_list{4}= 'pq_ptp';
mask_note = mask_note_list{datatype};

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
hc_name_list = {'meas_MID00238_FID321189_HC_seq2.dat', ...
                                    'meas_MID00244_FID321195_HC_seq8.dat', ...
                                    'meas_MID00238_FID321189_HC_seq2.dat', ...
                                    'meas_MID00244_FID321195_HC_seq8.dat'};
bc_name_list = {'meas_MID00243_FID321194_BC_seq2.dat', ...
                                    'meas_MID00245_FID321196_BC_seq8.dat', ...
                                    'meas_MID00243_FID321194_BC_seq2.dat', ...
                                    'meas_MID00245_FID321196_BC_seq8.dat'};
nShot_list = {1000,233,1000,233};
nSeg_list = {22,88,22,88};

elseif subject_num == 2
    meas_name_list = {'meas_MID00262_FID321213_JB_LIBRE2p2_a8_woPERewinder.dat', ...
                                    'meas_MID00263_FID321214_EP_GRE_LIBRE2p2_triggered_pole_18x547.dat', ...
                                    'meas_MID00264_FID321215_yj_seq2.dat', ...
                                    'meas_MID00265_FID321216_yj_seq8.dat'};
    hc_name_list = {'meas_MID00269_FID321220_HC_seq2.dat', ...
                                'meas_MID00275_FID321226_HC_seq8.dat'};
    bc_name_list = {'meas_MID00274_FID321225_BC_seq2.dat', ...
                                'meas_MID00276_FID321227_BC_seq8.dat'};
    nShot_list = {1000,233,1000,233};
    nSeg_list = {22,88,22,88};

elseif subject_num == 3
    meas_name_list = {'meas_MID00289_FID321240_JB_LIBRE2p2_a8_woPERewinder.dat', ...
                                        'meas_MID00290_FID321241_EP_GRE_LIBRE2p2_triggered_pole_18x547.dat', ...
                                        'meas_MID00291_FID321242_yj_seq2.dat', ...
                                        'meas_MID00292_FID321243_yj_seq8.dat'};
    hc_name_list = {'meas_MID00296_FID321247_HC_seq2.dat', ...
                                        'meas_MID00302_FID321253_HC_seq8.dat'};
    bc_name_list = {'meas_MID00301_FID321252_BC_seq2.dat', ...
                                        'meas_MID00303_FID321254_BC_seq8.dat'};
    nShot_list = {1000,233,1000,233};
    nSeg_list = {22,88,22,88};
else
     meas_name_list = {'meas_MID00337_FID321288_JB_LIBRE2p2_a8_woPERewinder.dat', ...
                                        'meas_MID00338_FID321289_EP_GRE_LIBRE2p2_triggered_pole_18x547.dat', ...
                                        'meas_MID00339_FID321290_yj_seq2.dat', ...
                                        'meas_MID00340_FID321291_yj_seq8.dat'};
    hc_name_list = {'meas_MID00345_FID321296_HC_seq2.dat', ...
                                        'meas_MID00351_FID321302_HC_seq8.dat'};
    bc_name_list = {'meas_MID00350_FID321301_BC_seq2.dat', ...
                                        'meas_MID00352_FID321303_BC_seq8.dat'};
    nShot_list = {1000,233,1000,233};
    nSeg_list = {22,88,22,88};

end

meas_name = meas_name_list{datatype};
hc_name = hc_name_list{datatype};
bc_name = bc_name_list{datatype};
nShot = nShot_list{datatype};
nSeg = nSeg_list{datatype};

datasetDir = [datasetDir{:}];
reconDir = [reconDir{:}];
seqFolder = [seqFolder{:}];
measureFile = [datasetDir, meas_name];
bodyCoilFile = [datasetDir, bc_name];
arrayCoilFile = [datasetDir, hc_name];
%% Load and Configure Data
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
     if subject_num > 2
        isMatch = check_hash(measureFile,reader.acquisitionParams.pulseqTrajFile_name);
     end
end

% Ensure consistency in number o1f shot-off points
nShotOff = reader.acquisitionParams.nShot_off;

% Load the raw data and compute trajectory and volume elements
y_tot = reader.readRawData(true, true);  % Filter nshotoff and SI
t_tot = bmTraj(reader.acquisitionParams);                       % Compute trajectory
%
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
x0Dir = [reconDir, '/T1_LIBRE_woBinning/output/mask_',mask_note,'/'];
 
if ~isfolder(x0Dir)
    % If it doesn't exist, create it
    mkdir(x0Dir);
    disp(['Directory created: ', x0Dir]);
else
    disp(['Directory already exists: ', x0Dir]);
end
x0Path = fullfile(x0Dir, 'x0_noC.mat');
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


