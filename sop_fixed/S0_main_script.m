baseFolder = '/mnt/filer01/MatTechLab/yiwei.jia/';
[C1, reconDir] = coilsense_script(baseFolder);
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
% ET mask from edf on mac jupyter notebook
%%
info = create_folders_from_et_masks();
th_ratio = 0.9;
nShotOff = 14; 
nSeg = 44; 
winLen = 3;
cri='test';
eyeMask_from_info(info, [], th_ratio, nShotOff, nSeg, winLen, cri);
%%
% mitosius Binning and reconstruction on HPC