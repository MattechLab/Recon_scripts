clear;clc; 
%first finish the codes here, then adapt to chacha_recon

%%

reconDir = '/Users/cag/Documents/Dataset/recon_results/251120_card/';

lowcut_card =  0.9;
highcut_card = 1.1; 
nrCardThreshold = 10;
mask_note = sprintf('card_th%d_low%.1f_high%.1f', nrCardThreshold, lowcut_card, highcut_card);

mDir = [reconDir, '/mitosius/', mask_note, '/'];


saveCDirList = {'/C/'};


CfileName = 'C.mat';
saveCDir = [reconDir, saveCDirList{1}];
CfilePath = fullfile(saveCDir, CfileName);

%
y   = bmMitosius_load(mDir, 'y'); 
t   = bmMitosius_load(mDir, 't'); 
ve  = bmMitosius_load(mDir, 've'); 

disp('Mitosius has been loaded!')
disp(mDir)
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

%
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

x0Dir = [reconDir,'/output/', mask_note,'/'];

if ~isfolder(x0Dir)
    % If it doesn't exist, create it
    mkdir(x0Dir);
    disp(['Directory created: ', x0Dir]);
else
    disp(['Directory already exists: ', x0Dir]);
end
x0Path = fullfile(x0Dir, 'x0.mat');
% Save the x0 to the .mat file
save(x0Path, 'x0', '-v7.3');
disp('x0 has been saved here:')
disp(x0Path)

%%

[Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);
%% bmSteva

% nIter = 30; % iterations before stopping
nIter = 15; %20, 30
witness_ind = [15,18,19];

delta     = 0.1; %0.01, 0.1, 1
rho       = 10*delta;
nCGD      = 4;
ve_max    = 10*prod(dK_u(:));
if nFr<= 1
    witness_info = bmWitnessInfo('stevaMorphosia_d0p1_r1_nCGD4', witness_ind);
    witness_info.save_witnessIm_flag = true;
    x = bmSteva(  x0{1}, [], [], y{1}, ve{1}, C, Gu{1}, Gut{1}, n_u, ...
                                        delta, rho, nCGD, ve_max, ...
                                        nIter, ...
                                        witness_info);
else
    witness_info = bmWitnessInfo('tevaMorphosia_d0p1_r1_nCGD4', witness_ind);
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
%%
xDir = [reconDir, '/output/',mask_note,'/'];
if ~isfolder(xDir)
    % If it doesn't exist, create it
    mkdir(xDir);
    disp(['Directory created: ', xDir]);
else
    disp(['Directory already exists: ', xDir]);
end

xPath = fullfile(xDir, sprintf('x_nIter%d_delta_%.3f.mat', nIter, delta));

% Save the x0 to the .mat file
save(xPath, 'x');
disp('x has been saved here:')
disp(xPath)



