function nii2mat_batch(rootDir, recurse, outSuffix)
%NII2MAT_BATCH  Convert every .nii / .nii.gz in a folder tree to .mat.
%
%   nii2mat_batch(rootDir)
%   nii2mat_batch(rootDir, recurse)
%   nii2mat_batch(rootDir, recurse, outSuffix)
%
%   INPUTS
%   rootDir   – folder that contains NIfTI files
%   recurse   – true / false  (default false): follow sub-folders
%   outSuffix – text appended to .mat file name (default '')
%
%   Example
%       nii2mat_batch('/data/project', true, '_v1')
%
%   Result: for each   foo.nii  →  foo_v1.mat   in the same folder.
%
%   Each .mat contains:
%       img  – the image array (single)
%       info – metadata returned by niftiinfo

% -------------------------------------------------------------------------
if nargin < 2 || isempty(recurse),   recurse = false; end
if nargin < 3,                        outSuffix = ''; end

% Build file list ---------------------------------------------------------
if recurse
    files = dir(fullfile(rootDir, '**', '*.nii*'));  % includes .nii.gz
else
    files = dir(fullfile(rootDir, '*.nii*'));
end

if isempty(files)
    warning('No NIfTI files found in %s', rootDir); return
end

fprintf('Found %d NIfTI files\n', numel(files));

% Loop over each file -----------------------------------------------------
for k = 1:numel(files)
    inPath = fullfile(files(k).folder, files(k).name);
    [~, base, ~] = fileparts(files(k).name);   % strip extension(s)

    outPath = fullfile(files(k).folder, [base outSuffix '.mat']);

    try
        info = niftiinfo(inPath);
        img  = single(niftiread(info));       % convert to single

        save(outPath, 'img', 'info', '-v7.3');  % v7.3 handles >2 GB
        fprintf('✓ %s  →  %s\n', files(k).name, [base outSuffix '.mat']);

    catch ME
        warning('✗ Failed on %s\n  %s', inPath, ME.message);
    end
end
end