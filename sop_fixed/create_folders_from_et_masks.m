function [info] = create_folders_from_et_masks(baseFolder)
% create_mask_folders_current_subject
% Select et_masks -> process ONLY that MID subject:
% For each *.mat in et_masks, create a folder under:
%   <subjectDir>/T1_LIBRE_Binning/<mask_base_name>/
% Output (struct "info"):
%   info.mid
%   info.etMasksDir
%   info.subjectDir
%   info.outBase            (T1_LIBRE_Binning)
%   info.otherDir           (Option B)
%   info.maskFiles          (full paths)
%   info.maskFolders        (full paths)

    if nargin<1 || isempty(baseFolder)
    baseFolder = '/mnt/filer01/MatTechLab/yiwei.jia/recon_results/';
    end
    info = struct();

    % --- Select et_masks folder ---
    [maskFileName, maskFileDir] = uigetfile(pwd, 'Select the et_masks folder (current MID)', baseFolder);
    if isequal(maskFileName, 0)
        error('File selection cancelled.');
    end
    maskFilePath = fullfile(maskFileDir, maskFileName);
    etMasksDir   = maskFileDir;  % folder containing the selected .mat
    info.etMasksDir = etMasksDir;
    % --- Extract MIDxxxxx from selected path ---
    mid = extractMID(etMasksDir);
    info.mid = mid;
    if isempty(mid)
        mid = extractMID(fileparts(etMasksDir));
    end
    if isempty(mid)
        error('Could not find a pattern like "MID00359" in the selected path.');
    end
    fprintf('Detected subject ID: %s\n', mid);

    % --- Infer subjectDir: walk upwards until folder name equals MIDxxxxx ---
    subjectDir = findSubjectDir(etMasksDir, mid);
    info.subjectDir = subjectDir;
    if isempty(subjectDir)
        error('Could not infer subject folder "%s" from:\n%s', mid, etMasksDir);
    end
    fprintf('Subject folder: %s\n', subjectDir);
    % --- (Optional) sanity check that we are in et_masks ---
    
    etMasksDir_ = regexprep(etMasksDir, [regexptranslate('escape', filesep) '+$'], '');
    % now this works:
    [~, lastName] = fileparts(etMasksDir_);
    if ~strcmpi(lastName, 'et_masks')
        warning('Selected file is not inside a folder named "et_masks" (got "%s"). Continuing anyway...', lastName);
    end
   

    % --- List mask .mat files ---
    mats = dir(fullfile(etMasksDir, '*.mat'));
    info.maskFiles   = cell(numel(mats), 1);
    info.maskFolders = cell(numel(mats), 1);

    if isempty(mats)
        warning('No *.mat files found in:\n%s', etDir);
        return;
    end

    % --- Create output base ---
    outBase = fullfile(subjectDir, 'T1_LIBRE_Binning');
    info.outBase = outBase;
    if ~isfolder(outBase)
        mkdir(outBase);
    end

    % --- Create folder per mask ---
    created = 0;
    for k = 1:numel(mats)
        info.maskFiles{k} = fullfile(mats(k).folder, mats(k).name);
        [~, maskBaseName] = fileparts(mats(k).name); % without .mat
        outFolder = fullfile(outBase, maskBaseName);
        info.maskFolders{k} = outFolder;
        if ~isfolder(outFolder)
            mkdir(outFolder);
            created = created + 1;
        end
    end

    fprintf('Done. Masks found: %d | New folders created: %d\n', numel(mats), created);
end

function mid = extractMID(p)
% Extract substring like MID00359 from a string
    tok = regexp(p, '(MID\d+)', 'tokens', 'once');
    if isempty(tok), mid = ''; else, mid = tok{1}; end
end

function subjectDir = findSubjectDir(startPath, mid)
% Walk up parent folders until the folder name equals MIDxxxxx
    subjectDir = '';
    p = startPath;
    for i = 1:10
        [parent, name] = fileparts(p);
        if startsWith(name, mid)
            subjectDir = p;
            return;
        end
        if isempty(parent) || strcmp(parent, p)
            return;
        end
        p = parent;
    end
end