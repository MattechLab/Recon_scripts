clc;
addpath(genpath('/Users/cag/Documents/forclone/Recon_scripts'));
addpath(genpath('/Users/cag/Documents/forclone/pulseq_v15'));
addpath(genpath('/Users/cag/Documents/forclone/monalisa'));

saveflag = 1;

%% Initialize the directories and acquire the Coil

for subject_num = 4:8
datatype = 1;

subject_suffix = {'', ''};
mask_note_list{1}= '40_old_120'; mask_note_list{2}= '40_crusher_120'; mask_note_list{3}= '50_crusher_120';
mask_note_list{4}= '40_2nd_240'; mask_note_list{5}= '40_crusher_240';  mask_note_list{6}= '50_crusher_240';  
mask_note_list{7}= '40_long_old_240'; mask_note_list{8}= '60_old_240';
mask_note = mask_note_list{subject_num};

if datatype == 1
    c_note = 'mask_nobin';
else
    c_note = '';
end

datasetDir = ['/Users/cag/Documents/Dataset/datasets/251205/'];
seqFolder = ['/Users/cag/Documents/Dataset/datasets/251205/'];
reconDir = ['/Users/cag/Documents/Dataset/recon_results/251205/'];

% yj0_seq8_t1w_libre_pre_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_trajPTP_nSeg88_nShot89.seq

seqName_list = {
'yj_seq14_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_40_short.seq', ...
'yj_seq601_t2w_libre_main_TR8.0ms_TE3.6ms_swap1_FA6_RF2_t2w_libre_tao_40.seq', ...
'yj_seq602_t2w_libre_main_TR8.0ms_TE3.6ms_swap1_FA6_RF2_t2w_libre_tao_50.seq', ...
'yj_seq14_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_40_short.seq', ...
'yj_seq601_t2w_libre_main_TR8.0ms_TE3.6ms_swap1_FA6_RF2_t2w_libre_tao_40.seq', ...
'yj_seq602_t2w_libre_main_TR8.0ms_TE3.6ms_swap1_FA6_RF2_t2w_libre_tao_50.seq', ...
'yj_seq10_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_40.seq', ...
'yj_seq13_t2w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_t2w_wurst_60.seq'};


seqName = seqName_list{subject_num};


if subject_num == 1
meas_name_list = {'meas_MID00315_FID19919_seq14.dat'};
hc_name_list = {' ', ''};
bc_name_list = {' ', ''}; 
nShot_list = {500};
nSeg_list = {44};

elseif subject_num == 2
meas_name_list = {'meas_MID00316_FID19920_seq601.dat'};
hc_name_list = {' ', ''};
bc_name_list = {' ', ''}; 
nShot_list = {500};
nSeg_list = {44};

elseif subject_num == 3
meas_name_list = {'meas_MID00317_FID19921_seq602.dat'};
hc_name_list = {' ', ''};
bc_name_list = {' ', ''}; 
nShot_list = {500};
nSeg_list = {44};

elseif subject_num == 4
meas_name_list = {'meas_MID00370_FID19974_seq14.dat'};
hc_name_list = {' ', ''};
bc_name_list = {' ', ''}; 
nShot_list = {500};
nSeg_list = {44};

elseif subject_num == 5
meas_name_list = {'meas_MID00371_FID19975_seq601.dat'};
hc_name_list = {' ', ''};
bc_name_list = {' ', ''}; 
nShot_list = {500};
nSeg_list = {44};

elseif subject_num == 6
meas_name_list = {'meas_MID00372_FID19976_seq602.dat'};
hc_name_list = {' ', ''};
bc_name_list = {' ', ''}; 
nShot_list = {500};
nSeg_list = {44};

elseif subject_num == 7
meas_name_list = {'meas_MID00373_FID19977_seq10.dat'};
hc_name_list = {' ', ''};
bc_name_list = {' ', ''}; 
nShot_list = {500};
nSeg_list = {44};

elseif subject_num == 8
meas_name_list = {'meas_MID00374_FID19978_seq13.dat'};
hc_name_list = {' ', ''};
bc_name_list = {' ', ''}; 
nShot_list = {500};
nSeg_list = {44};

end


meas_name = meas_name_list{datatype};
hc_name = hc_name_list{datatype};
bc_name = bc_name_list{datatype};


measureFile = [datasetDir, meas_name];
bodyCoilFile = [datasetDir, bc_name];
arrayCoilFile = [datasetDir, hc_name];


%% Load and Configure Data


flagSS = 1; % filter non SS off
flagExcludeSI = 1; % filter SI off
reader = createRawDataReader(measureFile, 1);
% Acquisition from Bern need to manually define the following part!!
nSeg = nSeg_list{datatype};
reader.acquisitionParams.nSeg = nSeg;
nShot = nShot_list{datatype};
reader.acquisitionParams.nShot = nShot; % in case no validation UI
reader.acquisitionParams.nShot_off = 14;
% reader.acquisitionParams.traj_type = 'full_radial3_phylotaxis';
reader.acquisitionParams.traj_type = 'pulseq';
reader.acquisitionParams.pulseqTrajFile_name = [seqFolder, seqName];

% Ensure consistency in number o1f shot-off points
nShotOff = reader.acquisitionParams.nShot_off;



%% Acquisition from Bern need to manually define the following part!!

if subject_num == 999 %no idea sequence in this dataset
     reader.acquisitionParams.traj_type = 'full_radial3_phylotaxis';
else
     reader.acquisitionParams.traj_type = 'pulseq';
     reader.acquisitionParams.pulseqTrajFile_name = strcat(seqFolder, seqName);
     % check if the hash from pulseq sequence and from twix match each other
    isMatch = check_hash(measureFile,reader.acquisitionParams.pulseqTrajFile_name);
   
end
%%
% Load the raw data and compute trajectory and volume elements
y_tot = reader.readRawData(true, true);  % Filter nshotoff and SI
t_tot = bmTraj(reader.acquisitionParams);                       % Compute trajectory
%
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements
% Some issue will happen if SI is not excluded, so keep acquisitionParams.selfNav_flag, flagExcludeSI
% they are true
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
x0Dir = [reconDir, '/Sub00',num2str(subject_num),'/output/mask_',mask_note,'/'];
 
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

% Root mean square across the channels
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
end


%% with C
matrix_size = 240;
N_u = [matrix_size, matrix_size, matrix_size];
dK_u = [1, 1, 1]./240;
n_u     = N_u; % Image size (output)
load('/Users/cag/Documents/Dataset/recon_results/251109/sub1_hemo/T1_LIBRE_woBinning/C/mask_noBin/C.mat')
C = bmImResize(C, [48, 48, 48], N_u);
x0 = bmMathilda(y_tot, t_tot, ve_tot, C, N_u, n_u, dK_u, [], [], [], []);
%%
bmImage(x0);
x0Dir = [reconDir, '/Sub00',num2str(subject_num),'/T1_LIBRE_woBinning/output/mask_',mask_note,'/'];
 
if ~isfolder(x0Dir)
    % If it doesn't exist, create it
    mkdir(x0Dir);
    disp(['Directory created: ', x0Dir]);
else
    disp(['Directory already exists: ', x0Dir]);
end
x0Path = fullfile(x0Dir, 'x0_C.mat');
if saveflag
    % Save the x0 to the .mat file
    save(x0Path, 'x0', '-v7.3');
    disp('x0 has been saved here:')
    disp(x0Path);
end

%% Concatenate them together
load('/Users/cag/Documents/Dataset/recon_results/251114/exploreGradSp/Sub001/T1_LIBRE_woBinning/output/mask_grad0/xrms.mat')
x1 = xrms;
load('/Users/cag/Documents/Dataset/recon_results/251114/exploreGradSp/Sub002/T1_LIBRE_woBinning/output/mask_grad1/xrms.mat')
x2 = xrms;
load('/Users/cag/Documents/Dataset/recon_results/251114/exploreGradSp/Sub003/T1_LIBRE_woBinning/output/mask_grad4/xrms.mat')
x3 = xrms;

%%
x_cat = cat(2, [norm_image(x1) norm_image(x2) norm_image(x3)]);
bmImage(x_cat)