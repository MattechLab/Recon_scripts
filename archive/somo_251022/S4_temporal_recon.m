clear;clc; 
% =====================================================
% Author: Yiwei Jia
% Date: Feb 5
% ------------------------------------------------
% Recon on debi
% Update: just for test before running on HPC
% =====================================================


%%
saveflag = 1;
subject_num = 1;
datatype = 1;
subject_suffix = {'_hemo'};

datasetDir = ['/Users/cag/Documents/Dataset/datasets/251022/', 'sub',num2str(subject_num), subject_suffix(subject_num), '/'];
seqFolder = ['/Users/cag/Documents/Dataset/datasets/251022/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];
reconDir = ['/Users/cag/Documents/Dataset/recon_results/251022/', 'sub', num2str(subject_num), subject_suffix(subject_num), '/'];
datasetDir = [datasetDir{:}];
reconDir = [reconDir{:}];
seqFolder = [seqFolder{:}];
resultsDir = fullfile(reconDir, 'temp_masks');  % Results folder
seqName =  'yj_seq3_t1w_libre_main_TR6.2ms_TE3.6ms_swap1_FA6_RF2_mreye_track_trajPTP.seq';


brainScanFile = [datasetDir, 'meas_MID00408_FID04433_YJ_head.dat'];
if subject_num == 1
    otherDir = [reconDir, '/temp_masks/'];
end


% Check if the directory exists
if ~isfolder(otherDir)
    % If it doesn't exist, create it
    mkdir(otherDir);
    disp(['Directory created: ', otherDir]);
else
    disp(['Directory already exists: ', otherDir]);
end


if subject_num == 1
    saveCDirList = {'/T1_LIBRE_Binning/C/','/T1_LIBRE_woBinning/C/mask_noBin/'};
end


CfileName = 'C.mat';
saveCDir = [reconDir, saveCDirList{2}];
CfilePath = fullfile(saveCDir, CfileName);


%
temporalWindowSec = 15;
maskName = sprintf('sequentialBinning_win%.1fs.mat', temporalWindowSec);
[~, maskNameNoExt] = fileparts(maskName);
saveName = fullfile(resultsDir, maskName);

if subject_num == 1
    mDir = [reconDir, '/Sub001/T1_LIBRE_Binning/mitosius/', maskNameNoExt, '/'];
end

y   = bmMitosius_load(mDir, 'y'); 
t   = bmMitosius_load(mDir, 't'); 
ve  = bmMitosius_load(mDir, 've'); 

disp('Mitosius has been loaded!')
%% compileScript()
Matrix_size = 120;
ReconFov = 240; %mm
N_u     = [Matrix_size, Matrix_size, Matrix_size]; % Matrix size: Size of the Virtual cartesian grid in the fourier space (regridding)
n_u     = [Matrix_size, Matrix_size, Matrix_size]; % Image size (output)
dK_u    = [1, 1, 1]./ReconFov; % Spacing of the virtual cartesian grid
nFr     = size(y,1); 
% best achivable resolution is 1/ N_u*dK_u If you have enough coverage
%%

load(CfilePath); 
C = bmImResize(C, [48, 48, 48], N_u);

%%
serial = false;
if serial
    nCh = 44; 
    x0 = bmZero([N_u,nCh], 'complex_single'); 
    for i = 1:nCh
        x0(:, :, :, i) = bmMathilda(y{1}(:, i), t{1}, ve{1}, [], N_u, n_u, dK_u, [], [], [], []);
    
    end
    x0 = bmCoilSense_pinv(C, x0, N_u); 
    bmImage(x0);

else
    x0 = cell(nFr, 1);
    for i = 1:nFr
        x0{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, n_u, dK_u, [], [], [], []);
    end
    % isequal(x0_p, x0)
    %
    bmImage(x0);
end

%%

x0Dir = [reconDir, '/Sub001/T1_LIBRE_Binning/output/', maskNameNoExt, '/'];
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

%%
[Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);
% bmSteva/Teva
deltaArray = 0.1;

% nIter = 30; % iterations before stopping
nIter = 20; %20, 30
witness_ind = [15,18,19];
delta = deltaArray(1);
% delta     = 0.1; %0.01, 0.1, 1
rho       = 10*delta;
nCGD      = 4;
ve_max    = 10*prod(dK_u(:));
%%
if nFr<= 1
    reconReg = 'Steva';
    witness_info = sprintf('stevaMorphosia_d%.2f_r%.1f_nCGD4', delta, rho);
    witness_info = bmWitnessInfo(witness_info, witness_ind);
    witness_info.save_witnessIm_flag = true;
    x = bmSteva(  x0{1}, [], [], y{1}, ve{1}, C, Gu{1}, Gut{1}, n_u, ...
                                        delta, rho, nCGD, ve_max, ...
                                        nIter, ...
                                        witness_info);
else
    reconReg = 'Teva';
    witness_info = sprintf('tevaMorphosia_d%.2f_r%.1f_nCGD4', delta, rho);
    witness_info = bmWitnessInfo(witness_info, witness_ind);
    witness_info.save_witnessIm_flag = true;
    x = bmTevaMorphosia_chain(  x0, ...
                                [], [], ...
                                y, ve, C, ...
                                Gu, Gut, n_u, ...
                                [], [], ...
                                delta, rho, 'normal', ...
                                nCGD, ve_max, ...
                                nIter, ...
                                witness_info);
end

bmImage(x)

xDir = [reconDir, '/Sub001/T1_LIBRE_Binning/output/', maskNameNoExt, '/'];
if ~isfolder(xDir)
    % If it doesn't exist, create it
    mkdir(xDir);
    disp(['Directory created: ', xDir]);
else
    disp(['Directory already exists: ', xDir]);
end

xPath = fullfile(xDir, sprintf('x_nIter%d_delta_%.3f_%s.mat', nIter, delta, reconReg));

% Save the x0 to the .mat file
save(xPath, 'x');
disp('x has been saved here:')
disp(xPath)


