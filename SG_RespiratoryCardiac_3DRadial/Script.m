clear all clc
%% Self-Gating Extraction of Respiratory and Cardiac Motion from 3D Radial GRE and bSSFP Scans (Free Running and Cardiac Triggered)
% Author: Matteo Tagliabue
% Update 19.08.2024
% V1.0
% Based on gpuNUFFT (https://github.com/andyschwarzl/gpuNUFFT)
%
%% PRE-REQUISITES
%
% kdata_raw             : Dim [nx ntviews nc] (kdata after coil compression or coil selecion and density compensation)
% kdata_original        : Dim [nx ntviews nc] (kdata with all coil and density compensation)
% DensityCompensation   : Dim [nx ntviews]
% Traj3D                : Dim [nx ntviews 3]
% pmutime               : Dim [1 ntviews]
% time                  : Dim [1 ntviews]
%
% - Non steady-state shots have already been removed (the entire Shot, not just individual segments).
% - SI projection is still in data
%
% - THE SCRIPT CANNOT BE RUN ALL AT ONCE. YOU MUST CHOOSE BETWEEN EITHER CARDIAC
%   SIGNAL EXTRACTION OR BREATHING SIGNAL EXTRACTION, NOT BOTH SIMULTANEOUSLY!

%% LOAD DATA

% DOWNLOAD THE DATA https://www.dropbox.com/scl/fi/ol9mdl7hj5bx5ogbn995o/Data.zip?rlkey=t8nz1s5j7wrgl4sgu45gogxf3&st=tzvho4sg&dl=0

% FREE RUNNING DATA
kdata_rawFR = load("FreeRunning/kdata_raw.mat");
kdata_raw_originalFR = load("FreeRunning/kdata_raw_original.mat");
DensityCompen3DFR =load('FreeRunning/DensityCompen3D.mat');
Traj3DFR = load('FreeRunning/Traj3D.mat');
pmutimeFR = load('FreeRunning/pmutime.mat');
timeFR = load('FreeRunning/time.mat');

kdata_rawFR = kdata_rawFR.kdata_raw;
kdata_raw_originalFR = kdata_raw_originalFR.kdata_raw_original;
DensityCompen3DFR = DensityCompen3DFR.DensityCompen3D;
Traj3DFR = Traj3DFR.Traj3D;
pmutimeFR = pmutimeFR.pmutime;
timeFR = timeFR.time;

% CARDIAC TRIGGERED DATA

kdata_rawCT = load("CardiacTriggered/kdata_raw.mat");
kdata_raw_originalCT = load("CardiacTriggered/kdata_raw_original.mat");
DensityCompen3DCT =load('CardiacTriggered/DensityCompen3D.mat');
Traj3DCT = load('CardiacTriggered/Traj3D.mat');
timeCT = load('CardiacTriggered/time.mat');

kdata_rawCT = kdata_rawCT.kdata_raw;
kdata_raw_originalCT = kdata_raw_originalCT.kdata_raw_original;
DensityCompen3DCT = DensityCompen3DCT.DensityCompen3D;
Traj3DCT = Traj3DCT.Traj3D;
timeCT = timeCT.time;

%% PARAM
SegmentFR = 24;
SegmentCT = 23;
nrCardThreshold = 10;
nrRespThreshold  =10;
%% CARDIAC SIGNAL

bin_method = 1; % 1 for Self-Gating , 0 for ECG

% MOTION EXTRACTION
if bin_method ==1

    % Bandpass Frequency, adjust as needed
    lowcut_card =  0.9;
    highcut_card = 1.1;

    % Self-Gating signal extraction
    [valuesHILB , locsHILB] = mt_extractCardiacBinningInfoBandPass(double(kdata_raw_originalFR), timeFR,pmutimeFR,lowcut_card,highcut_card);

    % Peak and location of ECG signal
    [valuesPMU , locsPMU] = findpeaks(pmutimeFR);

    % Create a new PMUTIME based on the Self-Gating Signal
    pmutimeFR = mt_SGPmutime(kdata_rawFR,timeFR,locsHILB);

    % Difference plot peak of Self-Gating vs peak ECG
    % (you may remove manually the wrong peak)
    mt_diffSelfvsECG(timeFR,locsPMU(2:end), locsHILB(2:end-1))

end

% REMOVE SI
kdata_rawFR= mt_removeSI(kdata_rawFR,SegmentFR);
DensityCompen3DFR= mt_removeSI(DensityCompen3DFR,SegmentFR);
Traj3DFR= mt_removeSI(Traj3DFR,SegmentFR);
pmutimeFR= mt_removeSI(pmutimeFR,SegmentFR);
%timeFR= mt_removeSI(timeFR,SegmentFR);

% BINNING
[NewPmutime, heart_binning, PercSegLoss,RemoveIndices] = mt_extractCardiacBinningInfo(pmutimeFR, nrCardThreshold);

%Remove unuesd indices
DensityCompen3DFR(:,RemoveIndices)=[];
Traj3DFR(:,RemoveIndices,:,:)=[];
kdata_rawFR(:,RemoveIndices,:)=[];

% Binned data ready for recon
[DensityCompen3D_binCARD, Traj3D_binCARD, kdata_raw_binCARD] = mt_applyCardiacBinning(DensityCompen3DFR, Traj3DFR,kdata_rawFR,heart_binning,nrCardThreshold);

%% BREATHING SIGNAL

acquisitionMode =0; % 0 for Cardiac Triggered, 1 for FreeRunning
hilbertFlag =0 ;    % 0 for no, 1 for yes. The Hilbert transform removes amplitude modulation from the respiratory signal.
% Although this modulation is believed to be a physiological phenomenon, removing it can sometimes improve results.

% MOTION EXTRACTION
if acquisitionMode ==0

    % Self-Gating signal extraction
    br_cylce = mt_extractionBreathingSignalCT(kdata_raw_originalCT,SegmentCT,timeCT);

else
    % Bandpass Frequency, adjust as needed
    lowcut_resp =  0.1;
    highcut_resp = 0.6;

    % Self-Gating signal extraction (Consider add Hilbert!)
    br_cylce= mt_respiratory_info_extraction_BandPass(double(kdata_raw_originalFR),SegmentFR,timeFR,lowcut_resp,highcut_resp);

    % HILBER OPTIONAL (to use it in mt_respiratory_info_extraction_BandPass comment the NORM section)
    if hilbertFlag ==1

        envelope = abs(hilbert(br_cylce));
        br_cylce = (br_cylce ./ envelope);
        br_cylce=(br_cylce+1)*0.5;

    end

    % Remove non steady segment according to breathing signal
    [Traj3DFR, ~] = mt_removeUnsteadySegments(Traj3DFR, timeFR, SegmentFR);
    [DensityCompen3DFR, ~] = mt_removeUnsteadySegments(DensityCompen3DFR, timeFR, SegmentFR);
    [kdata_rawFR, timeFR] = mt_removeUnsteadySegments(kdata_rawFR, timeFR, SegmentFR);

end

% EXTRACT BINNING INFO
if acquisitionMode ==0
    breathing_binning = mt_extractRespiratoryBinningInfo(br_cylce,SegmentCT,timeCT,nrRespThreshold);
else
    breathing_binning = mt_extractRespiratoryBinningInfo(br_cylce,SegmentFR,timeFR,nrRespThreshold);
end

% REMOVE SI
if acquisitionMode ==0
    kdata_rawCT= mt_removeSI(kdata_rawCT,SegmentCT);
    DensityCompen3DCT= mt_removeSI(DensityCompen3DCT,SegmentCT);
    Traj3DCT= mt_removeSI(Traj3DCT,SegmentCT);
    breathing_binning = mt_removeSI(breathing_binning,SegmentFR);
else
    kdata_rawFR= mt_removeSI(kdata_rawFR,SegmentFR);
    DensityCompen3DFR= mt_removeSI(DensityCompen3DFR,SegmentFR);
    Traj3DFR= mt_removeSI(Traj3DFR,SegmentFR);
    breathing_binning = mt_removeSI(breathing_binning,SegmentFR);
end

% BINNING
if acquisitionMode ==0
    [DensityCompen3D_binRESP, Traj3D_binRESP, kdata_raw_binRESP] = mt_applyRespiratoryBinning(DensityCompen3DCT, Traj3DCT,kdata_rawCT,breathing_binning,nrRespThreshold);
else
    [DensityCompen3D_binRESP, Traj3D_binRESP, kdata_raw_binRESP] = mt_applyRespiratoryBinning(DensityCompen3DFR, Traj3DFR,kdata_rawFR,breathing_binning,nrRespThreshold);
end
