function saveC(C, reconDir)
saveCDir = [reconDir, '/C/'];

CfileName = 'C.mat';

% Create the folder if it doesn't exist
if ~exist(saveCDir, 'dir')
    mkdir(saveCDir);
end

% Full path to  C file
CfilePath = fullfile(saveCDir, CfileName);

% Save the matrix C to the .mat file
save(CfilePath, 'C');
disp('Coil sensitivity C has been saved here:')
disp(CfilePath)
end