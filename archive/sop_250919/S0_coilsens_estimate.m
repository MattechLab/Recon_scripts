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
    nShot = 1000;
    nSeg = 22;
    seqName = "yj_seq2_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA4_RF2_rfmod2_traj0Orig_PhNeg.seq";

elseif subject_num == 10
    meas_name_suffix = '_MID00293_FID59709_yiweiseq10';
    hc_name_suffix = ' ';
    bc_name_suffix = ' ';
    nShot = 1000;
    nSeg = 22;
    seqName = "yj_seq10_t1w_libre_part_TR6.2ms_TE3.6ms_swap1_FA6_RF2_rfmod2_trajOrig_PhNeg.seq";

end

meas_name = ['meas', meas_name_suffix];
hc_name = ['meas', hc_name_suffix];
bc_name = ['meas', bc_name_suffix];

measureFile = [datasetDir, meas_name,'.dat'];
bodyCoilFile = [datasetDir, bc_name,'.dat'];
arrayCoilFile = [datasetDir, hc_name,'.dat'];
%% Load and Configure Data
reader = createRawDataReader(measureFile, false);
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
t               = bmTraj_fullRadial3_phyllotaxis_lineAssym2(N, ...
                                                            nSeg, ...
                                                            nShot, ...
                                                            dK_n, ...
                                                            selfNav_flag, ...
                                                            nShot_off);

ve = bmVolumeElement_voronoi_full_radial3(t);
ve = min(ve, ve_max_factor*prod(calib_dK_u));


%%
% Compute the gridding matrices (subscript is a reminder of the result)
% Gn is from uniform to Non-uniform
% Gu is from non-uniform to Uniform
% Gut is Gu transposed
[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);
%% Create Mask
x_min = 1; 
x_max = 40;

y_min = 9; 
y_max = 41;

z_min = 4; 
z_max = 48;

% Two thresholds
th_RMS = 19; 
th_MIP = 16; 

close_size = []; 
open_size  = []; 

[m] = yjCoilSense_nonCart_mask_fromCalib(imCalib_body, N_u, ...
                                x_min, x_max, ...
                                y_min, y_max, ...
                                z_min, z_max, ...
                                th_RMS, th_MIP, ...
                                close_size, ...
                                open_size, ...
                                true);

%%
close all;
% Select one body coil and compute its sensitivity
[y_ref, C_ref] = bmCoilSense_nonCart_ref(y_body, Gn, m, []); 

% Estimate the coil sensitivity of each surface coil using one body coil
% image as reference image C_c = (X_c./x_ref)
C_array_prime = bmCoilSense_nonCart_primary(y_array, y_ref, C_ref, Gn, ve, m);

% Do a recon, predending the selected body coil is one channel among the
% others, and optimize the coil sensitivity estimate by alternating steps
% Of gradient descent (X,C)
nIter = 5; 
[C, x] = bmCoilSense_nonCart_secondary(y_array, C_array_prime, y_ref, C_ref, Gn, Gu, Gut, ve, nIter, false); 

%% Load the raw data and compute trajectory and volume elements
y_tot = reader.readRawData(true, true);  % Filter nshotoff and SI
t_tot = bmTraj(reader.acquisitionParams);                       % Compute trajectory
ve_tot = bmVolumeElement(t_tot, 'voronoi_full_radial3');  % Volume elements
%%



function [m] = yjCoilSense_nonCart_mask_fromCalib(imCalib_body, N_u, varargin)

colorMax = 100; 
% Extract optional arguments
[   x_min, x_max, ...
    y_min, y_max, ...
    z_min, z_max, ...
    th_RMS, th_MIP, ...
    open_size, ...
    close_size, ...
    display_flag]    = bmVarargin(varargin); 



imDim   = size(N_u(:), 1);

myRMS = bmRMS(imCalib_body, N_u); 

% Perform MIP for each data point
myMIP = bmMIP(imCalib_body, N_u); 

% Normalize and scale RMS and MIP values (maybe devide by max - min)
myRMS = colorMax*(myRMS - min(myRMS(:)))/max(myRMS(:));
myMIP = colorMax*(myMIP - min(myMIP(:)))/max(myMIP(:));
% Get number of points of x
nPix = size(myRMS(:), 1); 

n_RMS = zeros(1, colorMax);
n_MIP = zeros(1, colorMax);
for i = 0:colorMax-1
    n_RMS(1, i+1) = sum(myRMS(:) > i)/nPix;
    n_MIP(1, i+1) = sum(myMIP(:) > i)/nPix;
end

if display_flag
    % Create histogram for threshold decision
    figure
    hold on
    plot(n_RMS, '.-');
    plot(n_MIP, '.-');
    xlabel('X');
    ylabel('Fraction above X');
    legend('RMS', 'MIP');
    title('Fraction of points having a value above X');

    % Create interactive figures to display RMS and MIP values
    bmImage(myRMS)
    title('RMS')
    bmImage(myMIP)
    title('MIP')
end

%% Create mask for valid RMS and MIP values
m = true(size(myRMS));

% Use threshold to decide lowest valid value
% Use RMS threshold for both if MIP th is not given
if not(isempty(th_RMS)) & isempty(th_MIP) 
    m = (myRMS > th_RMS) & (myMIP > th_RMS);

% Use MIP threshold for both if RMS th is not given
elseif isempty(th_RMS) & not(isempty(th_MIP)) 
    m = (myRMS > th_MIP) & (myMIP > th_MIP);

elseif not(isempty(th_RMS)) && not(isempty(th_MIP))
    m = (myRMS > th_RMS) & (myMIP > th_MIP);
end


% Modify mask to crop the image in every dimension if max and min values
% are given
if imDim == 1
    % Crop the image in x direction if max and min values are given
    if not(isempty(x_min)) && not(isempty(x_max))
        m(1:x_min, 1)   = false;
        m(x_max:end, 1) = false;
    end
end
if imDim == 2
    % Crop the image in x direction if max and min values are given
    if not(isempty(x_min)) && not(isempty(x_max))
        m(1:x_min, :)   = false;
        m(x_max:end, :) = false;
    end
    % Crop the image in y direction if max and min values are given
    if not(isempty(y_min)) && not(isempty(y_max))
        m(:, 1:y_min)   = false;
        m(:, y_max:end) = false;
    end
end
if imDim == 3
    % Crop the image in x direction if max and min values are given
    if not(isempty(x_min)) && not(isempty(x_max)) 
        if x_min > 1
            m(1:x_min-1,   :, :)  = false;
        end
        if x_max < N_u(1, 1)
            m(x_max+1:end, :, :)  = false;
        end
    end
    % Crop the image in y direction if max and min values are given
    if not(isempty(y_min)) && not(isempty(y_max)) 
        if y_min > 1
            m(:, 1:y_min-1,   :)  = false;
        end
        if y_max < N_u(1, 2)
            m(:, y_max:end, :)  = false;
        end
    end
    % Crop the image in z direction if max and min values are given
    if not(isempty(z_min)) && not(isempty(z_max)) 
        if z_min > 1
            m(:, :, 1:z_min)    = false;
        end
        if z_max < N_u(1, 3)
            m(:, :, z_max:end)  = false;
        end
    end
end


% TO BE COMMENTED
if not(isempty(open_size))
    if open_size > 0
        m = bmImOpen(m, bmImShiftList(['sphere', num2str(imDim)], open_size, 0));
    end
end
if not(isempty(close_size))
    if close_size > 0
        m = bmImClose(m, bmImShiftList(['sphere', num2str(imDim)], close_size, 0));
    end
end


% Show RMS with mask applied next to the mask in an interactive figure
if sum(m(:) == false) > 0
    temp_im = m.*myRMS;

    % Combine normalized applied mask RMS and mask
    temp_im = cat(2, temp_im/max(abs(temp_im(:))), m); 
    if display_flag
        bmImage(temp_im)
    end
end

% Prepare mask for output
m = bmBlockReshape(m, N_u);
end