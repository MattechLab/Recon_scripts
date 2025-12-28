baseFolder = '/mnt/filer01/MatTechLab/yiwei.jia/';
[C1, reconDir, prescan_seqParam] = coilsense_script(baseFolder);
[xrms,x0] = check_orient_xrms(baseFolder);
bmImage(C1); bmImage(x0);
%%
C = C1;
for iCh = 1:size(C1,4)
    C(:,:,:,iCh) = flip(permute(C1(:,:,:,iCh), [2 1 3]),1);
    % C(:,:,:,iCh) = flip(permute(C(:,:,:,iCh), [2 1 3]),2);
end
bmImage(C)
%% Save C into the folder
saveC(C, reconDir);
%%
plotPMU=0; generateReport=0;
TimeDiff_ms = resolve_twix_ext(baseFolder, plotPMU, generateReport);
%%
% mitosius woBin and reconstruction on HPC

[matwoBinName, matwoBinFolder] = uigetfile('*.mat', 'Select eMask_woBin.mat file', baseFolder);
if matwoBinName == 0
    error('Binning mask without binning file selection was cancelled');
end
matwoBinFolder
import_eMask = 1;
CalR_script(import_eMask, matwoBinFolder, seqParams)
%% T1_Binning
% ET mask from edf on mac jupyter notebook
%%
info = create_folders_from_et_masks();
%%
th_ratio = 0.9;
nShotOff = 14; 
nSeg = 44; 
winLen = 3;
% keep the mask suffix as 'test', fix it if no need to change.
eyeMask_from_info(info, [], th_ratio, nShotOff, nSeg, winLen, 'test');
%% calculate the coverage for each eyeMask
[seqName, seqFolder] = uigetfile('*.seq', 'Select main sequence file', baseFolder);
if seqName == 0
    error('Sequence file selection was cancelled');
end
seqFile = fullfile(seqFolder, seqName);
seqParams = extract_seq_params(seqFile);
seqParams.seqFile = seqFile;
%%
import_eMask = 1;
eMask_folder = info.maskFolders;
CalR_script(import_eMask, eMask_folder, seqParams)
%% mitosius Binning and reconstruction on HPC
% bash submit_all.sh

