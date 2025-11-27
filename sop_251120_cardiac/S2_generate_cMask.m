subject_num = 1;
%
meas_name_suffix = '_MID00332_FID214628_BEAT_LIBREon_eye_(23_09_24)_sc_trigger';
% meas_name_suffix = '_MID00346_FID214642_BEAT_LIBREon_eye_HC_BC';
meas_name = ['meas', meas_name_suffix];
twix_name = ['twix', meas_name_suffix];
twix_path =  ['/Users/cag/Documents/Dataset/datasets/250127_acquisition/', twix_name,'.mat'];
datasetDir = '/Users/cag/Documents/Dataset/datasets/250127_acquisition/';
raw_data = [datasetDir, meas_name,'.dat'];
save_trigger = false;
%%
% myTwix = mapVBVD_JH_for_hemo(raw_data, 'fidnav', 0);
myTwix = mapVBVD_JB(raw_data);
kdata_rawFR_save  = myTwix{1,2}.image.unsorted();   
%%
param = extract_pmu(myTwix{2}, 1, 1);
%%

SegmentFR = 22; %Free running, same setting with Mathieu
% SegmentCT = 23; %Cardiac triggered, no need in Yiwei's check
nrCardThreshold = 8;
nrRespThreshold  =10;

%%

% Bandpass Frequency, adjust as needed
lowcut_card =  1.0;
highcut_card = 1.6; 

% Cardiac	Matteo default setting: 0.9 1.1
% 1.0–1.6 (sometimes 0.5–3)	60–96 (up to 180)
% Respiratory	0.018–0.3 (sometimes 0.1–0.6)	1–18 (up to 36)
% Yiwei: permute the kdata_rawFR to the dimension needed here
kdata_rawFR = permute(kdata_rawFR_save, [1, 3, 2]);

%% Self-Gating signal extraction
kdata_raw_originalFR = kdata_rawFR;
timeFR = param.TimeStamp_s;
pmutimeFR = param.PMUTimeStamp_s;

[valuesHILB , locsHILB] = mt_extractCardiacBinningInfoBandPass(double(kdata_raw_originalFR), timeFR,pmutimeFR,lowcut_card,highcut_card);

% Peak and location of ECG signal, deleted by Yiwei, no ECG is needed here
% [valuesPMU , locsPMU] = findpeaks(pmutimeFR);

% Create a new PMUTIME based on the Self-Gating Signal
pmutimeFR = mt_SGPmutime(kdata_rawFR,timeFR,locsHILB);

% Difference plot peak of Self-Gating vs peak ECG
% (you may remove manually the wrong peak)
% mt_diffSelfvsECG(timeFR,locsPMU(2:end), locsHILB(2:end-1))
% not used in Yiwei's check

%% REMOVE SI: to be replaced by monalisa

% === move the part below to the monalisa part ===
% kdata_rawFR= mt_removeSI(kdata_rawFR,SegmentFR);
% % I guess here it is volume element
% DensityCompen3DFR= mt_removeSI(DensityCompen3DFR,SegmentFR);
% Traj3DFR= mt_removeSI(Traj3DFR,SegmentFR);
% pmutimeFR= mt_removeSI(pmutimeFR,SegmentFR);
% timeFR= mt_removeSI(timeFR,SegmentFR);
% =======================================

% BINNING
[NewPmutime, heart_binning, PercSegLoss,RemoveIndices] = mt_extractCardiacBinningInfo(pmutimeFR, nrCardThreshold);
%%
% heart_binning: 1 x N or N x 1
nLine = numel(heart_binning);

binStatuses = unique(heart_binning(heart_binning > -1));  % existing non-zero bins
nStatus  = numel(binStatuses);

heart_binning_frames = cell(1, nStatus);  % frames{1} -> status 0, frames{2} -> status 1, ...

for s = 0:nStatus-1
    heart_binning_frames{s+1} = (heart_binning == s);  % logical mask for status s
end
%%
f=figure;
f.Position = [100 100 1500 800]; set(f, 'Color', 'w'); 
tiledlayout(nStatus, 1, 'Padding', 'compact', 'TileSpacing', 'compact');
idxInter = 2;
for k = 1:nStatus
    s = binStatuses(k);
    % mask = (heart_binning == s);
    mask = heart_binning_frames{k};

    nexttile;
    stem(param.TimeStamp_ms, mask, 'Marker', 'none');  % binary mask as 0/1
    xlim([(idxInter-1)*10000 idxInter*10000]);
    ylim([-0.1 1.1]);
    ylabel(sprintf('Bin %d', s));
    if k == 1
        title('Binary masks per cardiac bin');
    end
    if k < nStatus
        set(gca, 'XTickLabel', []);   % hide x-labels for intermediate plots
    else
        xlabel('time [ms]');
    end
end


%%
% %Remove unuesd indices
% DensityCompen3DFR(:,RemoveIndices)=[];
% Traj3DFR(:,RemoveIndices,:,:)=[];
% kdata_rawFR(:,RemoveIndices,:)=[];
% 
% % Binned data ready for recon
% [DensityCompen3D_binCARD, Traj3D_binCARD, kdata_raw_binCARD] = mt_applyCardiacBinning(DensityCompen3DFR, Traj3DFR,kdata_rawFR,heart_binning,nrCardThreshold);

cMask = cat(1, heart_binning_frames{:});
%%
reconDir = '/Users/cag/Documents/Dataset/recon_results/251120_card/';
otherDir = [reconDir, '/other/'];
if ~isfolder(otherDir)
    mkdir(otherDir);
end

mask_note = sprintf('card_th%d_low%.1f_high%.1f', nrCardThreshold, lowcut_card, highcut_card);
% save cMask

MaskFilePath = [otherDir, mask_note, '.mat'];
% Save the CMask to the .mat file
save(MaskFilePath, 'cMask');
disp('cMask has been saved here:')
disp(MaskFilePath)

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
fprintf(fid,['lowCut: ', num2str(lowcut_card), '.\n']);
fprintf(fid,['highCut: ', num2str(highcut_card), '.\n']);
fprintf(fid,['nrCardThreshold: ', nrCardThreshold, '.\n']);
for idx = 1:size(cMask, 1)
    fprintf(fid, ['with Binning, preserved #line: ',num2str(sum(cMask(idx, :))), ' out of ', num2str(length(cMask(idx, :))), '.\n' ]);
end

% Close the file
fclose(fid);

disp('File saved successfully：');
disp(filename)


