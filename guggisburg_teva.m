% https://github.com/MattechLab/monalisa/blob/main/demo/script_demo/script_recon_calls/chain_recon_calls_script.m
% nice example of the DuoMotion thing
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
resultsDir = fullfile(reconDir, 'temp_masks');  % Results folder


temporalWindowSec = 15;
maskName = sprintf('sequentialBinning_win%.1fs.mat', temporalWindowSec);
[~, maskNameNoExt] = fileparts(maskName);


if subject_num == 1
    mDir = [reconDir, '/Sub001/T1_LIBRE_Binning/mitosius/', maskNameNoExt, '/'];
end

y   = bmMitosius_load(mDir, 'y'); 
t   = bmMitosius_load(mDir, 't'); 
ve  = bmMitosius_load(mDir, 've'); 

%%
if subject_num == 1
    saveCDirList = {'/T1_LIBRE_Binning/C/','/T1_LIBRE_woBinning/C/mask_noBin/'};
end
%%
Matrix_size = 60;
ReconFov = 240; %mm
N_u     = [Matrix_size, Matrix_size, Matrix_size]; % Matrix size: Size of the Virtual cartesian grid in the fourier space (regridding)
n_u     = [Matrix_size, Matrix_size, Matrix_size]; % Image size (output)
dK_u    = [1, 1, 1]./ReconFov; % Spacing of the virtual cartesian grid
nFr     = size(y,1); 
%%
CfileName = 'C.mat';
saveCDir = [reconDir, saveCDirList{2}];
CfilePath = fullfile(saveCDir, CfileName);

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
    bmImage(x0);
end

outputFolder = strcat(maskNameNoExt,  '_N', num2str(Matrix_size), '_noField');
x0Dir = [reconDir, '/Sub001/T1_LIBRE_Binning/output/', outputFolder, '/'];
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


%% Gridding Matrices

% The sparse matrices computed here are the gridding matrices for
% non-cartesain reconstructions. They depend on the trajectory, 
% reconstruction FoV (dK_u) and grid-size N_u. 
%
% Gu is the forward-gridding matrix and Gut is its transposed matrix. 
% Gn is the inverse gridding matrix. 

[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);

%% TevaMorphosia_chain without deformation matrices

% TevaMorphosia_chain can be called with or without deformation matrices.
% We call it here without. 
%
% Without defomation matrices, it is a least-square regularized 
% reconstruction for non-cartesian data, where the regularization
% is the l1-norm temporal derivative of the image.  
% It is a multiple-frame reconstruction that consists in minimizing 
% the objective function with the ADMM algorithm. 
%
% Delta is the regularization weight and Rho is the convergence parameter 
% of ADMM. 

nIter               = 20;
witness_ind         = 1:5:nIter; 
witness_label       = 'tevaMorphosia_chain_d0p1_r1_nCGD4';
save_witnessIm_flag = true;
witnessInfo         = bmWitnessInfo(witness_label, witness_ind, save_witnessIm_flag);

delta               = 0.1;
rho                 = 10*delta;
nCGD                = 4;
ve_max              = 10*prod(dK_u(:));

x = bmTevaMorphosia_chain(  x0, ...
                            [], [], ...
                            y, ve, C, ...
                            Gu, Gut, nFr, ...
                            [], [], ...
                            delta, rho, 'normal', ...
                            nCGD, ve_max, ...
                            nIter, ...
                            witnessInfo);

bmImage(x)
x1 = x; 


outputFolder = strcat(maskNameNoExt,  '_N', num2str(Matrix_size), '_noField');
xDir = [reconDir, '/Sub001/T1_LIBRE_Binning/output/', outputFolder, '/'];
if ~isfolder(xDir)
    mkdir(xDir); disp(['Directory created: ', xDir]);
else
    disp(['Directory already exists: ', xDir]);
end
xPath = fullfile(xDir, 'x.mat');
if saveflag
    % Save the x0 to the .mat file
    save(xPath, 'x', '-v7.3'); disp('x has been saved here:'); disp(xPath);
end
