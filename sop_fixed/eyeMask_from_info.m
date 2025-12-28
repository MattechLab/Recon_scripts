

%%
function eyeMask_from_info(info, datasetDir, th_ratio, nShotOff, nSeg, winLen, cri)


user_input = 0;
input_info = struct();

baseFolder = '/mnt/filer01/MatTechLab/yiwei.jia/datasets/';
if nargin<2 || isempty(datasetDir)
    datasetDir = baseFolder;
end

for k = 1:size(info.maskFolders,1)
    reconDir = info.maskFolders{k};
    ETDir = info.maskFiles{k};
    
    otherDir = [reconDir, '/other/'];


    % Check if the directory exists
    if ~isfolder(otherDir)
        % If it doesn't exist, create it
        mkdir(otherDir);
        disp(['Directory created: ', otherDir]);
    else
        disp(['Directory already exists: ', otherDir]);
    end

%

    mask_note = [sprintf('eMask_win%d_th%.2f_',winLen, th_ratio), cri];
    % prepare input_info
    eMaskFilePath = [otherDir, mask_note, '.mat'];
    if isfile(eMaskFilePath)
        fprintf('[SKIP] eMask already exist: %s \n', eMaskFilePath);
        continue;
    end
    pattern = ['*' info.mid '*.dat'];
    cands = dir(fullfile(datasetDir, '**', pattern));
    % Fallback (if ** isn't supported or returns empty but files exist)
    if isempty(cands)
        allDat = dir(fullfile(datasetDir, '**', '*.dat'));
        if ~isempty(allDat)
            keep = contains({allDat.name}, info.mid);
            cands = allDat(keep);
        end
    end

    if isempty(cands)
        error('No .dat file found under "%s" with "%s" in the filename.', datasetDir, info.mid);
    end

    % If multiple matches, pick the most recently modified
    [~, idx] = max([cands.datenum]);
    rawDataName = cands(idx).name;
    rawDataDir  = cands(idx).folder;
    rawDataFullPath = fullfile(rawDataDir, rawDataName);
    
    fprintf('Using raw data: %s\n', rawDataFullPath);


    input_info.nbins = 1;
    input_info.rawDataName = rawDataName;
    input_info.rawDataDir = rawDataDir;
    input_info.filepathMaskData = cell(input_info.nbins,1);
    % remember to adjust the filepathMaskData according to your binning need
    % if nbins = 4, change the input_info.filepathMaskData{idx_bin} to the
    % binning masks according to the frames.
    for idx_bin=input_info.nbins
        input_info.filepathMaskData{idx_bin} = info.maskFiles{k};
    end


    eMask = eyeGenerateBinningWin(datasetDir, nShotOff, nSeg,th_ratio, ETDir, ...
        winLen, true, user_input, input_info);
    disp(['Preserved readout number: ',num2str(nnz(eMask))])
    % Saving data and Convert to Monalisa format
    %--------------------------------------------------------------------------    
    
    %save(fullfile(param.savedir,'cMask.mat'),'param');
    %disp(['param is saved here:', param.savedir, '\cMask.mat'])
    
    
    
    % Save the CMask to the .mat file
    save(eMaskFilePath, 'eMask');
    disp('eMask has been saved here:')
    disp(eMaskFilePath)

    % save the log txt
    % Define the filename
    filename = [otherDir, mask_note, '.txt'];

    % Open the file for writing ('w' mode overwrites, 'a' appends)
    fid = fopen(filename, 'w');
    
    % Check if the file opened successfully
    if fid == -1
        error('Cannot open file for writing.');
    end

    % Write some text to the file
    fprintf(fid, '.\n');
    fprintf(fid,['winLen: ', num2str(winLen), '.\n']);
    fprintf(fid,['threshold: ', num2str(th_ratio), '.\n']);
    fprintf(fid,['criteria: ', cri, '.\n']);
    fprintf(fid, ['with Binning, preserved #line: ',num2str(sum(eMask)), ' out of ', num2str(length(eMask)), '.\n' ]);
    
    % Close the file
    fclose(fid);
    
    disp('File saved successfully:');
    disp(filename)
end

end