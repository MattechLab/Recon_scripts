function nDeleted = delete_files(rootDir, filePattern, varargin)
%DELETE_NII  Delete .nii (and optionally .nii.gz) files in a folder tree.
%
%   nDeleted = delete_nii(rootDir)
%   nDeleted = delete_nii(rootDir, 'recursive', true, 'includeGz', true, ...
%                         'force', false, 'quiet', false)
%
%   INPUTS
%   rootDir      Folder where .nii files live (absolute or relative path)
%
%   NAME–VALUE PAIRS (all optional)
%   'recursive'  true/false  : descend into sub-folders           (default false)
%   'includeGz'  true/false  : also delete .nii.gz files          (default false)
%   'force'      true/false  : delete without prompt              (default false)
%   'quiet'      true/false  : suppress console messages          (default false)
%
%   OUTPUT
%   nDeleted     Number of files actually deleted
%
%   Example
%      % dry-run: list .nii & .nii.gz in all sub-folders
%      delete_nii('/data/project','recursive',true,'includeGz',true);
%
%      % force deletion (no prompt) of .nii files in one folder
%      delete_nii('/tmp/test','force',true);
%
%   ---------------------------------------------------------------------

% ── 0.  Parse & validate ------------------------------------------------
p = inputParser;
addRequired(p,'rootDir',@(s)ischar(s)||isstring(s));
addRequired(p,'filePattern',@(s)ischar(s)||isstring(s));
addParameter(p,'recursive',false,@islogical);
addParameter(p,'includeGz',false,@islogical);
addParameter(p,'force',false,@islogical);
addParameter(p,'quiet',false,@islogical);
parse(p,rootDir,filePattern,varargin{:});
opt = p.Results;

if ~isfolder(opt.rootDir)
    error('delete_files:FolderNotFound','Folder "%s" does not exist.',opt.rootDir);
end

% ── 1.  Build search pattern(s) ----------------------------------------
pattern = fullfile(opt.rootDir, '**', filePattern);   % covers .nii and .nii.gz
if ~opt.recursive
    pattern = fullfile(opt.rootDir, filePattern);
end

allFiles = dir(pattern);

% filter .nii.gz if not requested
if ~opt.includeGz
    allFiles = allFiles(~endsWith({allFiles.name}, '.gz'));
end

if isempty(allFiles)
    if ~opt.quiet
        fprintf('No matching NIfTI files found in %s\n', opt.rootDir);
    end
    nDeleted = 0;
    return
end

% ── 2.  List (dry-run) --------------------------------------------------
if ~opt.quiet
    fprintf('The following %d file(s) will be deleted:\n', numel(allFiles));
    disp({allFiles.name}.')
end

% ── 3.  Prompt unless "force" -------------------------------------------
doDelete = opt.force;
if ~doDelete
    reply = input('Delete these files? y/n [n]: ','s');
    doDelete = strcmpi(reply,'y');
end
if ~doDelete
    if ~opt.quiet, fprintf('Aborted – no files deleted.\n'); end
    nDeleted = 0;
    return
end

% ── 4.  Delete ----------------------------------------------------------
fullPaths = fullfile({allFiles.folder},{allFiles.name});
delete(fullPaths{:});

nDeleted = numel(fullPaths);
if ~opt.quiet
    fprintf('✓ Deleted %d file(s).\n', nDeleted);
end
end