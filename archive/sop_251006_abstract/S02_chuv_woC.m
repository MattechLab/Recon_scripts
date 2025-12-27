clc;
addpath(genpath('/Users/cag/Documents/forclone/Recon_scripts'));
addpath(genpath('/Users/cag/Documents/forclone/pulseq_v15'));
addpath(genpath('/Users/cag/Documents/forclone/monalisa'));

saveflag = 1;
%% Initialize the directories and acquire the Coil
subject_num = 3;
datatype = 2;

subject_suffix = {'_ml', '_jb', '_yj',  '_phantom'};
mask_note_list{1}= 'pq_ori'; mask_note_list{2}= 'pq_ptp';
mask_note = mask_note_list{datatype};
if datatype == 1 || datatype == 3
    c_note = 'mask_pq_ori';
else
    c_note = 'mask_pq_ptp';
end
datasetDir = ['/Users/cag/Documents/Dataset/datasets/251007_chuv_abs/', 'sub',num2str(subject_num), subject_suffix(subject_num), '/'];
seqFolder = ['/Users/cag/Documents/Dataset/datasets/251007_chuv_abs/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];
reconDir = ['/Users/cag/Documents/Dataset/recon_results/251007_chuv_abs/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];

seqName_list = { 'yj_seq2_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_traj0Orig_PhNeg.seq', ...
    'yj_seq8_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_trajPTP_PhNeg.seq', ...
    'yj0_seq2_t1w_libre_pre_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_traj0Orig_PhNeg.seq', ...
    'yj0_seq8_t1w_libre_pre_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_trajPTP_PhNeg.seq'};

seqName = seqName_list{datatype};

if subject_num == 1
meas_name_list = {' .dat', ...
                                ' .dat'};
hc_name_list = {' .dat', ...
                                    ' .dat'};
bc_name_list = {' .dat', ...
                                    ' .dat'}; 
nShot_list = {1000,233,1000,233};
nSeg_list = {22,88,22,88};

elseif subject_num == 2
    meas_name_list = {'meas_MID00520_FID64748_yiwei_seq2.dat', ...
                                    'meas_MID00521_FID64749_yiwei_seq8.dat'};

    hc_name_list = {'meas_MID00525_FID64753_HC_seq2.dat', ...
                               'meas_MID00525_FID64753_HC_seq2.dat'};
    bc_name_list = {'meas_MID00532_FID64760_BC_seq2.dat' , ...
                               'meas_MID00532_FID64760_BC_seq2.dat'  };
    nShot_list = {1000,233};
    nSeg_list = {22,88};

elseif subject_num == 3
    meas_name_list = {    'meas_MID00570_FID64798_yiwei_seq2.dat', ...
                                        'meas_MID00571_FID64799_yiwei_seq8.dat'};
    hc_name_list = {'meas_MID00573_FID64801_HC_seq2.dat', ...
                               'meas_MID00573_FID64801_HC_seq2.dat'};
    bc_name_list = {'meas_MID00574_FID64802_BC_seq2.dat', ...
                               'meas_MID00574_FID64802_BC_seq2.dat'};
    nShot_list = {1000,233};
    nSeg_list = {22,88};
else
    % phantom
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
reader = createRawDataReader(measureFile, false);
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
    isMatch = check_hash(measureFile,reader.acquisitionParams.pulseqTrajFile_name);
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
x0Dir = [reconDir, '/Sub00',num2str(subject_num),'/T1_LIBRE_woBinning/output/mask_',mask_note,'/'];
 
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


