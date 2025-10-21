function [outFile, tformFile] = spm_register_volumes(fixedFile, movingFile, spmFolder)
%SPM_REGISTER_VOLUMES  Coregister one NIfTI volume to another via SPM.
%
%   [outFile, tformFile] = spm_register_volumes(fixedFile, movingFile, spmFolder)
%
%   INPUTS
%   fixedFile   – reference NIfTI (.nii or .nii.gz)
%   movingFile  – source NIfTI to be aligned
%   spmFolder   – absolute path to SPM12 (e.g. 'C:\toolboxes\spm12')
%
%   OUTPUTS
%   outFile     – full path to resliced NIfTI (prefixed with 'r_')
%   tformFile   – full path to the affine .mat transform (same name as movingFile)
%
%   Example:
%       out = spm_register_volumes('sub01_T1.nii','sub01_EPI.nii','/opt/spm12');
%
%   Notes:
%   • Uses SPM’s Coregister: Estimate & Reslice in batch mode.
%   • Rigid body (6 DOF) with NMI cost function.
%   • Interpolation = 4th-order B-spline.
%   • Requires the Image Processing Toolbox for niftiinfo/niftiread if you
%     later want to load the output; not required for registration itself.

% -------------------------------------------------- 1.  Add SPM to path
if nargin<3
    spmFolder = '/Users/cag/Documents/forclone/spm';
end
if ~contains(path, spmFolder)
    addpath(spmFolder);
end

% -------------------------------------------------- 2.  Init SPM (headless)
spm('defaults','fmri');
spm_jobman('initcfg');

% -------------------------------------------------- 3.  Build batch
matlabbatch = {};

% (a) Estimate transform
matlabbatch{1}.spm.spatial.coreg.estimate.ref    = {fixedFile};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {movingFile};
matlabbatch{1}.spm.spatial.coreg.estimate.other  = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = ...
 [0.02 0.02 0.02  0.001 0.001 0.001  0.01 0.01 0.01  0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

% (b) Reslice
matlabbatch{2}.spm.spatial.coreg.write.ref    = {fixedFile};
matlabbatch{2}.spm.spatial.coreg.write.source = {movingFile};
matlabbatch{2}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{2}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
matlabbatch{2}.spm.spatial.coreg.write.roptions.mask   = 0;
matlabbatch{2}.spm.spatial.coreg.write.roptions.prefix = 'r_';

% -------------------------------------------------- 4.  Run
spm_jobman('run', matlabbatch);

% -------------------------------------------------- 5.  Output paths
[outDir, movingName, ext] = fileparts(movingFile);
outFile   = fullfile(outDir, ['r_' movingName ext]);  % resliced vol
tformFile = [movingFile '.mat'];                      % affine matrix

fprintf('✓ Coregistration done.\n → Resliced: %s\n → Transform: %s\n',...
        outFile, tformFile);
end