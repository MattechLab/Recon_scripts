clc;
addpath(genpath('/Users/cag/Documents/forclone/Recon_scripts'));
addpath(genpath('/Users/cag/Documents/forclone/pulseq_v15'));
addpath(genpath('/Users/cag/Documents/forclone/monalisa'));

saveflag = 1;

%% === User Input Section ===
% Open file dialogs for sequence and raw data files

% Select sequence file
[seqName, seqFolder] = uigetfile('*.seq', 'Select sequence file');
if seqName == 0
    error('Sequence file selection was cancelled');
end

% Select raw data file
[measureFilename, rawDir] = uigetfile('*.dat', 'Select raw data file');

if measureFilename == 0
    error('Raw data file selection was cancelled');
end

% Create cell array with the selected sequence file
seqName_list = {seqName};

% Load the coil sensitivity previously measured
[CName, CFolder] = uigetfile('*.mat', 'Select Coil Sensitivity C file');
if CName == 0
    error('Coil sensitivity file selection was cancelled');
end
%% Initialize the directories and acquire the Coil

% Parameters
saveflag = 1;

% Full path to the measurement file
measureFile = fullfile(rawDir, measureFilename);

% Recon directory (same level as rawDir)
[parentDir, ~] = fileparts(rawDir);
parts = strsplit(parentDir, filesep);
parts(strcmp(parts,'datasets')) = {'recon_results'}; %replace the folder name as yiwei's convention
parentDir = fullfile(filesep, parts{:});
%
token = regexp(measureFilename, 'MID\d+', 'match');
MID = token{1}; %extract MID
reconDir = fullfile(parentDir, [MID '_recon']);
otherDir = [reconDir, '/T1_LIBRE_woBinning/other/'];
% Check if the directory exists
if ~isfolder(otherDir)
    % If it doesn't exist, create it
    mkdir(otherDir);
    disp(['Directory created: ', otherDir]);
else
    disp(['Directory already exists: ', otherDir]);
end


%% Step 1: Load the Raw Data

% Sequence file (already selected by user)
seqFile = fullfile(seqFolder, seqName);
seqParams = extract_seq_params(seqFile);

% Reader
autoFlag = true;  % Disable validation UI
reader = createRawDataReader(measureFile, autoFlag);
reader.acquisitionParams.nShot_off = 14;
reader.acquisitionParams.traj_type = 'pulseq';
reader.acquisitionParams.pulseqTrajFile_name = strcat(seqFile);
reader.acquisitionParams.traj_type = 'pulseq';

 % check if the hash from pulseq sequence and from twix match each other
isMatch = check_hash(measureFile,reader.acquisitionParams.pulseqTrajFile_name);

if isfield(seqParams, 'nshot')
    reader.acquisitionParams.nShot = seqParams.nshot;
end
if isfield(seqParams, 'nseg')
    reader.acquisitionParams.nSeg = seqParams.nseg;
end
%
% Load the raw data and compute trajectory and volume elements
y_tot = reader.readRawData(true, true);  % Filter nShotOff and SI

%%
t_tot = bmTraj(reader.acquisitionParams);                       % Compute trajectory
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements

%% Step 2: Load Coil Sensitivity Maps
CfilePath = fullfile(CFolder, CName);
load(CfilePath, 'C');  % Load sensitivity maps
disp(['C is loaded from:', CfilePath]);
%% Adjust grid size for coil sensitivity maps
% Warning: due to the memory limit, make sure the matrix size <=240
matrix_size = 480;  % Max nominal spatial resolution
N_u = [matrix_size, matrix_size, matrix_size];
dK_u = 1./(seqParams.fov*2e3);

%% Step 3: Normalize the Raw Data

N_norm = [60,60,60];
C_for_norm =  bmImResize(C, [48, 48, 48], N_norm);

x_tot = bmMathilda(y_tot, t_tot, ve_tot, C_for_norm, N_norm, N_norm, dK_u); 

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

%% only once !!!!
if real(y_tot)<1
  
        y_tot = y_tot/normalize_val; 
        y_tot(1,1,123)
   
end


%%Prepare eye mask
eMask = ones(1, seqParams.nshot*seqParams.nseg);
eMask = (eMask>0);
eMask(1:reader.acquisitionParams.nShot_off*seqParams.nseg) = 0;
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
eyeMask = reshape(eyeMask, [nbins, seqParams.nseg, seqParams.nshot]); 
eyeMask(:, 1, :) = []; 

eyeMask(:, :, 1:reader.acquisitionParams.nShot_off ) = []; 
eyeMask = bmPointReshape(eyeMask); 

% Set the folder for mitosius saving

mDir = [reconDir, '/T1_LIBRE_woBinning/mitosius/'];

% Run the mitosis function and compute volume elements

[y, t] = bmMitosis(y_tot, t_tot, eyeMask); 
y = bmPermuteToCol(y); 
ve  = bmVolumeElement(t, 'voronoi_full_radial3' ); 

% Save all the resulting datastructures on the disk. You are now ready
% to run your reconstruction

bmMitosius_create(mDir, y, t, ve); 
disp('Mitosius files are saved!')
disp(mDir)
























