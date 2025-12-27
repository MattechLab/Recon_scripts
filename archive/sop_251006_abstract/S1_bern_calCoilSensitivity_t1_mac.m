% =====================================================
% Author: Yiwei Jia
% Date: Oct 13
% ------------------------------------------------
% [Coil sensitivity] -> binning mask eMask -> Mitosius
% Update: this script is derived from Demo script
% by Mauro in Monalisa version Feb.5
% The old script has issue when running mask generation
% With readers, the param setting is more organized
% =====================================================

clc;
addpath(genpath('/Users/cag/Documents/forclone/Recon_scripts'));
addpath(genpath('/Users/cag/Documents/forclone/pulseq_v15'));
addpath(genpath('/Users/cag/Documents/forclone/monalisa'));

saveflag = 1;

%% Initialize the directories and acquire the Coil
subject_num = 1;
datatype = 1;

subject_suffix = {'_ml', '_jb', '_yj',  '_phantom'};
mask_note_list{1}= 'ori'; mask_note_list{2}= 'ptp';
mask_note = mask_note_list{datatype};

datasetDir = ['/Users/cag/Documents/Dataset/datasets/251006_bern_abs/', 'sub',num2str(subject_num), subject_suffix(subject_num), '/'];
seqFolder = ['/Users/cag/Documents/Dataset/datasets/251006_bern_abs/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];
reconDir = ['/Users/cag/Documents/Dataset/recon_results/251006_bern_abs/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];

seqName_list = {
    'yj0_seq2_t1w_libre_pre_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_traj0Orig_PhNeg.seq', ...
    'yj0_seq8_t1w_libre_pre_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_trajPTP_PhNeg.seq'};

seqName = seqName_list{datatype};

if subject_num == 1

hc_name_list = {'meas_MID00238_FID321189_HC_seq2.dat', ...
                                    'meas_MID00244_FID321195_HC_seq8.dat', ...
                                    'meas_MID00238_FID321189_HC_seq2.dat', ...
                                    'meas_MID00244_FID321195_HC_seq8.dat'};
bc_name_list = {'meas_MID00243_FID321194_BC_seq2.dat', ...
                                    'meas_MID00245_FID321196_BC_seq8.dat', ...
                                    'meas_MID00243_FID321194_BC_seq2.dat', ...
                                    'meas_MID00245_FID321196_BC_seq8.dat'};
nShot_list = {419,89};
 nSeg_list = {22,88};

elseif subject_num == 2

    hc_name_list = {'meas_MID00269_FID321220_HC_seq2.dat', ...
                                'meas_MID00275_FID321226_HC_seq8.dat'};
    bc_name_list = {'meas_MID00274_FID321225_BC_seq2.dat', ...
                                'meas_MID00276_FID321227_BC_seq8.dat'};
    nShot_list = {419,89};
    nSeg_list = {22,88};

elseif subject_num == 3

    hc_name_list = {'meas_MID00296_FID321247_HC_seq2.dat', ...
                                        'meas_MID00302_FID321253_HC_seq8.dat'};
    bc_name_list = {'meas_MID00301_FID321252_BC_seq2.dat', ...
                                        'meas_MID00303_FID321254_BC_seq8.dat'};
    nShot_list = {419,89};
    nSeg_list = {22,88};
else

    hc_name_list = {'meas_MID00345_FID321296_HC_seq2.dat', ...
                                        'meas_MID00351_FID321302_HC_seq8.dat'};
    bc_name_list = {'meas_MID00350_FID321301_BC_seq2.dat', ...
                                        'meas_MID00352_FID321303_BC_seq8.dat'};
    nShot_list = {419,89};
    nSeg_list = {22,88};
end


hc_name = hc_name_list{datatype};
bc_name = bc_name_list{datatype};
nShot = nShot_list{datatype};
nSeg = nSeg_list{datatype};

datasetDir = [datasetDir{:}];
reconDir = [reconDir{:}];
seqFolder = [seqFolder{:}];

bodyCoilFile = [datasetDir, bc_name];
arrayCoilFile = [datasetDir, hc_name];


%% Load and Configure Data
% Read data using the library's `createRawDataReader` function
% This readers makes the usage of Siemens and ISMRMRD files equivalent for
% the library
bodyCoilreader = createRawDataReader(bodyCoilFile, true);
bodyCoilreader.acquisitionParams.nSeg = nSeg;
bodyCoilreader.acquisitionParams.nShot = nShot;
bodyCoilreader.acquisitionParams.nShot_off = 14;
bodyCoilreader.acquisitionParams.traj_type = 'pulseq';
bodyCoilreader.acquisitionParams.pulseqTrajFile_name = strcat(seqFolder, seqName);

arrayCoilReader = createRawDataReader(arrayCoilFile, true);
arrayCoilReader.acquisitionParams.nSeg = nSeg;
arrayCoilReader.acquisitionParams.nShot = nShot;
arrayCoilReader.acquisitionParams.nShot_off = 14;
arrayCoilReader.acquisitionParams.traj_type = 'pulseq';
arrayCoilReader.acquisitionParams.pulseqTrajFile_name = strcat(seqFolder, seqName);

% Ensure consistency in number o1f shot-off points
nShotOff = arrayCoilReader.acquisitionParams.nShot_off;


%% Parameters
dK_u = [1, 1, 1] ./ arrayCoilReader.acquisitionParams.FoV;   % Cartesian grid spacing
N_u = [48, 48, 48];             % Adjust this value as needed
% Compute Trajectory and Volume Elements
[y_body, t, ve] = bmCoilSense_nonCart_data(bodyCoilreader, N_u);
y_surface = bmCoilSense_nonCart_data(arrayCoilReader, N_u);

% Compute the gridding matrices (subscript is a reminder of the result)
% Gn is from uniform to Non-uniform
% Gu is from non-uniform to Uniform
% Gut is Gu transposed
[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);
%% Create Mask
% This line below just does not work on mac
mask = bmCoilSense_nonCart_mask_automatic(y_body, Gn, false);

% % Box excluding coordinates
% x_min = 1;  x_max = 40;
% y_min = 9;  y_max = 41;
% z_min = 4;  z_max = 48;
% 
% % Two thresholds
% th_RMS = 14;  th_MIP = 10; 
% close_size = [];  open_size  = []; 
% m = bmCoilSense_nonCart_mask( y_body, Gn, ...
%                                 x_min, x_max, ...
%                                 y_min, y_max, ...
%                                 z_min, z_max, ...
%                                 th_RMS, th_MIP, ...
%                                 close_size, ...
%                                 open_size, ...
%                                 true);

%% Estimate Coil Sensitivity
% Reference coil sensitivity using the body coils. This is used as 
% a reference to estiamte the sensitivity of each head coil
[y_ref, C_ref] = bmCoilSense_nonCart_ref(y_body, Gn, mask, []);

% Head coil sensitivity estimate using body coil reference
C_array_prime = bmCoilSense_nonCart_primary(y_surface, y_ref, C_ref, Gn, ve, mask);
% Refine the sensitivity estimate with optimization
nIter = 5;
[C1, x] = bmCoilSense_nonCart_secondary(y_surface, C_array_prime, y_ref, ...
                                       C_ref, Gn, Gu, Gut, ve, nIter, false);

% Display Results
bmImage(C1);
%% 
C = C1;
% for iCh = 1:size(C1,4)
%     C(:,:,:,iCh) = flip(permute(C1(:,:,:,iCh), [2 1 3]),2);
%     C(:,:,:,iCh) = flip(permute(C(:,:,:,iCh), [2 1 3]),2);
% end
bmImage(C)
%% Save C into the folder

saveCDir = [reconDir, '/T1_LIBRE_woBinning/C/mask_',mask_note,'/'];


for idx = 2

    CfileName = 'C.mat';
    
    % Create the folder if it doesn't exist
    if ~exist(saveCDir, 'dir')
        mkdir(saveCDir);
    end
    
    % Full path to  C file
    CfilePath = fullfile(saveCDir, CfileName);
    
    % Save the matrix C to the .mat file
    save(CfilePath, 'C');
    disp('Coil sensitivity C has been saved here:')
    disp(CfilePath)
end



