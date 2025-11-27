
clc;
addpath(genpath('/Users/cag/Documents/forclone/Recon_scripts'));
addpath(genpath('/Users/cag/Documents/forclone/pulseq_v15'));
addpath(genpath('/Users/cag/Documents/forclone/monalisa'));

saveflag = 1;
%% Initialize the directories and acquire the Coil
subject_num = 1;
datatype = 2;

subject_suffix = {'_stable', '_motion'};
mask_note_list{1}= 'nobin'; mask_note_list{2}= '';
mask_note = mask_note_list{datatype};
if datatype == 1
    c_note = 'mask_noBin';
else
    c_note = '';
end
datasetDir = ['/Users/cag/Documents/Dataset/datasets/251109/', 'sub',num2str(subject_num), subject_suffix(datatype), '/'];
seqFolder = ['/Users/cag/Documents/Dataset/datasets/251109/', 'sub', num2str(subject_num), subject_suffix(datatype), '/'];
reconDir = ['/Users/cag/Documents/Dataset/recon_results/251109/', 'sub', num2str(subject_num), subject_suffix(datatype), '/'];

seqName_list = {
    'yj_seq31_t1w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_hemo_fid_trajPTP_44_1000.seq', ...
    'yj_seq30_t1w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_hemo_fid_trajPTP_44_2202.seq', ...
    'yj0_seq8_t1w_libre_pre_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_trajPTP_PhNeg.seq'};

seqName = seqName_list{datatype};

if subject_num == 1
meas_name_list = {'meas_MID00053_FID09218_hemo_stable.dat', ...
                                'meas_MID00065_FID09230_hemo_motion.dat'};
hc_name_list = {' ', ''};
bc_name_list = {' ', ''}; 
nShot_list = {1000, 2202};
nSeg_list = {44, 44};

elseif subject_num == 2

elseif subject_num == 3

else
    % phantom
end

meas_name = meas_name_list{datatype};
hc_name = hc_name_list{datatype};
bc_name = bc_name_list{datatype};




datasetDir = [datasetDir{:}];
reconDir = [reconDir{:}];
seqFolder = [seqFolder{:}];
measureFile = [datasetDir, meas_name];
bodyCoilFile = [datasetDir, bc_name];
arrayCoilFile = [datasetDir, hc_name];


%% Load and Configure Data
% reader = createRawDataReader(measureFile, false);
% not working anymore
flagSS = 1; % filter non SS off
flagExcludeSI = 1; % filter SI off
acquisitionParams = bmMriAcquisitionParam([]);
acquisitionParams.nShot = nShot_list{datatype};
acquisitionParams.nSeg = nSeg_list{datatype};
% Siemens-specific data extraction logic
% 0: 4 samples 1: 480 samples

acquisitionParams.nCh = 42;
acquisitionParams.N = 480;
acquisitionParams.FoV = 240;
acquisitionParams.nEcho = 1;
acquisitionParams.nShot_off = 14;
acquisitionParams.selfNav_flag = flagExcludeSI;
NavReadoutSize= acquisitionParams.nShot * acquisitionParams.nSeg * 2;
%% Unsort the data from myTwix
% ----------------------------------------
% The problem is the Twix extracts the data size of [4,42,140536]
% where: 140536 = 44 (nSeg)*1597(nShot)*[2]
% I suspect the readout within one TR was split into 2 parts, and Twix only
% recognized the first adc component (4 samples)
% ----------------------------------------
% now I'm testing all kinds of flags to make sure something can affect the
% twix output: ignseg--no affect, removeos--make NCol from 4 to 2
% ----------------------------------------
% NCol is important
% set a breakpoint at L253 twix_map_obj_JH_for_hemo
% L385 twix_map_obj_JH_for_hemo, touch the assumption
% strategy: make another flag to control the readout reading: 
% something like k = k+2, once catch this.NCol = this.NCol(1), another one
% catch this.NCol = this.NCol(2);
% ok, now we can read the y with  size of [480, 42, 140536]

% if memory is exceeded from myTwix.image.unsorted(), we can have the
% readout in the truncated way
% readouts   = myTwix.image.unsorted(1:2:nLine)
myTwix = mapVBVD_JH_for_hemo(measureFile, 'fidnav', 0);
nav_readouts  = myTwix.image.unsorted(1:2:NavReadoutSize);   % all odd-indexed frames
%%

navFile = fullfile(reconDir, 'nav_readouts_4samples_2.mat');

if isfile(reconDir) == 0
    mkdir(reconDir);
end
save(navFile, 'nav_readouts', '-v7.3');
disp('nav_readouts has been saved here:')
disp(navFile);

%% save the original readout
myTwix = mapVBVD_JH_for_hemo(measureFile, 'fidnav', 1);
main_readouts   = myTwix.image.unsorted(2:2:NavReadoutSize); % all even-indexed frames
main_readout_ori = main_readouts;
main_readoutFile = fullfile(reconDir, 'main_readouts.mat');
save(main_readoutFile, 'main_readouts', '-v7.3');
disp('main readouts has been saved here:')
disp(main_readoutFile);
%%
load('/Users/cag/Documents/Dataset/recon_results/251109/sub1_hemo/main_readouts.mat')

main_readouts   = permute(main_readouts, [2, 1, 3]);
%%
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


%% Acquisition from Bern need to manually define the following part!!

if subject_num == 999 %no idea sequence in this dataset
     acquisitionParams.traj_type = 'full_radial3_phylotaxis';
else
     acquisitionParams.traj_type = 'pulseq';
     acquisitionParams.pulseqTrajFile_name = strcat(seqFolder, seqName);
     % check if the hash from pulseq sequence and from twix match each other
    isMatch = check_hash(measureFile,acquisitionParams.pulseqTrajFile_name);
   
end
%%
% Load the raw data and compute trajectory and volume elements
t_tot = bmTraj(acquisitionParams);                       % Compute trajectory
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


%% with C
matrix_size = 120;
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