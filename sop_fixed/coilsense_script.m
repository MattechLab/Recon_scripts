%% Init
function [C1, reconDir, prescan_seqParams] = coilsense_script(baseFolder)
clc; clearvars;


%% === User Input Section ===
% Open file dialogs for sequence and raw data files

% Select sequence file
[seqName, seqFolder] = uigetfile('*.seq', 'Select prescan sequence file', baseFolder);
if seqName == 0
    error('Sequence file selection was cancelled');
end

% Select raw data file
[bodyCoilFilename, rawDir] = uigetfile('*.dat', 'Select bc data file', baseFolder);
if bodyCoilFilename == 0
    error('bodyCoil data file selection was cancelled');
end
% Select raw data file
[arrayCoilFilename, rawDir] = uigetfile('*.dat', 'Select hc data file', baseFolder);

if arrayCoilFilename == 0
    error('arrayCoil data file selection was cancelled');
end

% Create cell array with the selected sequence file
seqName_list = {seqName};
%% === Add paths ===
addpath(genpath('/home/debi/jaime/repos/MR-EyeTrack/recon'));
addpath(genpath('/home/debi/MatTechLab/monalisa'));
addpath(genpath('/home/debi/yiwei/forclone/pulseq'));
addpath(genpath('/home/debi/yiwei/forclone/mapVBVD'))
%% Initialize the directories and acquire the Coil

% Parameters
saveflag = 1;

% Full path to the measurement file
bodyCoilFile = fullfile(rawDir, bodyCoilFilename);
arrayCoilFile = fullfile(rawDir, arrayCoilFilename);
% Recon directory (same level as rawDir)
[parentDir, ~] = fileparts(rawDir);
parts = strsplit(parentDir, filesep);
parts(strcmp(parts,'mreye_dataset')) = {'recon_results'}; %replace the folder name as yiwei's convention
parentDir = fullfile(filesep, parts{:});
%
token = regexp(arrayCoilFile, 'MID\d+', 'match');
MID = token{1}; %extract MID
reconDir = fullfile(parentDir, [MID '_recon_C']);


%% Load and Configure Data
% Read data using the library's `createRawDataReader` function
% This readers makes the usage of Siemens and ISMRMRD files equivalent for
% the library
% Sequence file (already selected by user)
seqFile = fullfile(seqFolder, seqName);
seqParams = extract_seq_params(seqFile);
prescan_seqParams = seqParams;

bodyCoilreader = createRawDataReader(bodyCoilFile, true);
if isfield(seqParams, 'nshot')
    bodyCoilreader.acquisitionParams.nShot = seqParams.nshot;
end
if isfield(seqParams, 'nseg')
    bodyCoilreader.acquisitionParams.nSeg = seqParams.nseg;
end

bodyCoilreader.acquisitionParams.nShot_off = 14;
bodyCoilreader.acquisitionParams.traj_type = 'pulseq';
bodyCoilreader.acquisitionParams.pulseqTrajFile_name = strcat(seqFolder, seqName);
 % check if the hash from pulseq sequence and from twix match each other
isMatch = check_hash(bodyCoilFile,bodyCoilreader.acquisitionParams.pulseqTrajFile_name);


arrayCoilReader = createRawDataReader(arrayCoilFile, true);
if isfield(seqParams, 'nshot')
    arrayCoilReader.acquisitionParams.nShot = seqParams.nshot;
end
if isfield(seqParams, 'nseg')
    arrayCoilReader.acquisitionParams.nSeg = seqParams.nseg;
end
arrayCoilReader.acquisitionParams.nShot_off = 14;
arrayCoilReader.acquisitionParams.traj_type = 'pulseq';
arrayCoilReader.acquisitionParams.pulseqTrajFile_name = strcat(seqFolder, seqName);
 % check if the hash from pulseq sequence and from twix match each other
isMatch = check_hash(arrayCoilFile,arrayCoilReader.acquisitionParams.pulseqTrajFile_name);

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
close all;
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
end



