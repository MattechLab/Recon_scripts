%% Yiwei Jia Nov 24 2024
% The script is specifically used for analyzing Twix and save some
% information as "report" for Dataset "MREyeTrack" acquired on Oct. 14 2024
%%
clc; clear all;
<<<<<<< Updated upstream:func/twix_pulseq_process_yj/archive/S1_resolve_twix_ext_archive.m
subject_num = 1;
meas_name = ['meas', '_MID00332_FID214628_BEAT_LIBREon_eye_(23_09_24)_sc_trigger'];
raw_data = ['/Users/cag/Documents/Dataset/datasets/250127_acquisition/', meas_name,'.dat'];

twix = mapVBVD_JB(raw_data);
%%
twix_img = twix{end};
PMU = twix_img.PMUdata;
sum(sum(PMU.EXT))
sum(sum(PMU.raw.EXT.data))
twix_name = ['twix', '_MID00332_FID214628_BEAT_LIBREon_eye_(23_09_24)_sc_trigger'];
twix_path =  ['/Users/cag/Documents/Dataset/250127_acquisition/',twix_name,'.mat'];
disp(['Saving twix into', twix_path]);
save(twix_path, 'twix');
%%
if subject_num == 1
    rawdata_name = meas_name;
    twix = load(['/Users/cag/Documents/Dataset/250127_acquisition/' ...
        'twix_MID00332_FID214628_BEAT_LIBREon_eye_(23_09_24)_sc_trigger.mat']);
    datadir = ['/Users/cag/Documents/Dataset/datasets/250127_acquisition'];  
elseif subject_num == 2
    rawdata_name = 'meas_MID00580_FID182834_BEAT_LIBREon_eye_(23_09_24)';
    twix = load(['/Users/cag/Documents/Dataset/MREyeTrack/' ...
        'Twix/twix_subj2_meas_MID00580_FID182834_BEAT_LIBREon_eye_(23_09_24).mat']);
    datadir = ['/home/debi/jaime/acquisitions/MREyeTrack/' ...
    'MREyeTrack_subj2/RawData_MREyeTrack_Subj2/'];  
else
    rawdata_name = 'meas_MID00554_FID182808_BEAT_LIBREon_eye_(23_09_24)';
    twix = load(['/Users/cag/Documents/Dataset/MREyeTrack/' ...
        'Twix/twix_subj3_meas_MID00554_FID182808_BEAT_LIBREon_eye_(23_09_24).mat']);
    datadir = ['/home/debi/jaime/acquisitions/MREyeTrack/' ...
    'MREyeTrack_subj3/RawData_MREyeTrack_Subj3/'];  
end

twix_image2 = twix.twix{1,end};
rawEXT = twix_image2.PMUdata.raw.EXT;
rawTimestamp = twix_image2.PMUdata.raw.EXT.TimeStamp;
rawEXTData = twix_image2.PMUdata.raw.EXT.data;

%%
stop_time_ms = (rawTimestamp(end)-rawTimestamp(1)) * 2.5;
rawTime_ms = linspace(0, stop_time_ms, length(rawTimestamp));
ext1 = double(rawEXTData(:,1));
ext2 = double(rawEXTData(:,2));%remember to convert the data type, otherwise something wrong with rawTimestamp.
=======
% Select raw data file
baseFolder = '/mnt/filer01/MatTechLab/yiwei.jia/';
[measFilename, rawDir] = uigetfile('*.dat', 'Select main raw data file', baseFolder);

if measFilename == 0
    error('measurement data file selection was cancelled');
end

measureFile = fullfile(rawDir, measFilename);
%%
twix = mapVBVD_JB(measureFile);

twix_img = twix{end};
PMU = twix_img.PMUdata;

sum(sum(PMU.EXT))
sum(sum(PMU.raw.EXT.data))
measSplit = split(measFilename, '.');
twix_name = ['twix_', measSplit{1}];
twixFolder = [rawDir, '/twix/'];
if ~isfolder(twixFolder)
    mkdir(twixFolder);
end

twix_path =  [twixFolder, twix_name,'.mat'];
disp(['Saving twix into', twix_path]);
save(twix_path, 'twix');

%


[twixFilename, twixDir] = uigetfile('*.mat', 'Select twix data file', baseFolder);

twix = load(fullfile(twixDir, twixFilename));

%
twix_image2 = twix.twix{1,end};
pmuEXT = twix_image2.PMUdata.EXT;
pmuTimestamp = twix_image2.image.timestamp;

%%
stop_time_ms = (pmuTimestamp(end)-pmuTimestamp(1)) * 2.5;
disp(['The duration of pmu timestamps: ',num2str(stop_time_ms)]);
time_ms = linspace(0, stop_time_ms, length(pmuTimestamp));
ext1 = double(pmuEXT(1,:));
ext2 = double(pmuEXT(2,:));%remember to convert the data type, otherwise something wrong with rawTimestamp.
>>>>>>> Stashed changes:func/twix_process_yj/S1_resolve_twix_ext.m
%
raw_pmu_ext = array2table([rawTimestamp'; rawTime_ms(:)' ; ext1(:)'; ext2(:)']', 'VariableNames', ...
    {'PMU_timestamp', 'PMU_time_ms', 'EXT1', 'EXT2'});

<<<<<<< Updated upstream:func/twix_pulseq_process_yj/archive/S1_resolve_twix_ext_archive.m

%%

 
twix_obj = mapVBVD_JH_for_monalisa(raw_data);
twix_obj = twix_obj{end};
% time stamps from the rawdata
mriTimeStamp       = double( twix_obj.image.timestamp );
mriTime_ms    = (mriTimeStamp - min(mriTimeStamp)) * 2.5;
%%
% STEP2: Cut the MultiRaid PMU structure to have the same starting point as the acquisition
% raw_pmu_ext([find(raw_pmu_ext.PMU_timestamp < mriTimeStamp(1)); find(raw_pmu_ext.PMU_timestamp > mriTimeStamp(end))],:)=[];
raw_pmu_ext([find(raw_pmu_ext.PMU_timestamp > mriTimeStamp(end))],:)=[];

raw_pmu_ext.PMU_time_ms = raw_pmu_ext.PMU_time_ms-min(raw_pmu_ext.PMU_time_ms);

%% Check the first event in eye tracker time axis

raw_pmu_mark = raw_pmu_ext;

raw_pmu_mark((raw_pmu_ext.EXT1 == 0) & (raw_pmu_ext.EXT2 == 0),:)=[];

diff_ms = diff(raw_pmu_mark.PMU_time_ms);
diff_stamp = diff(raw_pmu_mark.PMU_timestamp);
=======
pmu_mark_table = pmu_ext_table;
pmu_mark_table((pmu_ext_table.EXT1 == 0) & (pmu_ext_table.EXT2 == 0),:)=[];
%%
figure;
plot(time_ms, pmu_ext_table.EXT1, time_ms, pmu_ext_table.EXT2)
xlabel('time (ms)')
ylabel('pulse amplitude')


%%

diff_ms = diff(pmu_mark_table.PMU_time_ms);
diff_stamp = diff(pmu_mark_table.PMU_timestamp);
>>>>>>> Stashed changes:func/twix_process_yj/S1_resolve_twix_ext.m
disp('The time diff between start of EXT and the first measurement of MRI:')
diff_start_mri = (pmu_ext_table.PMU_timestamp(1) - pmuTimestamp(1))*2.5
disp('The time diff between start of EXT and the first mark of EXT:')
diff_start_mark = (pmu_ext_table.PMU_timestamp(1) - pmu_mark_table.PMU_timestamp(1))*2.5
disp('the first mark of EXT - the first mri measure:')
disp(num2str(diff_start_mri - diff_start_mark))

% Generate a cell report
report={};
report{1,1}='pmu_timestp_start'; report{1,2}=pmu_ext_table.PMU_timestamp(1);
report{2,1}='pmu_timestp_end'; report{2,2}=pmu_ext_table.PMU_timestamp(end);
report{3,1}='pmu_mark_start'; report{3,2}=pmu_mark_table.PMU_timestamp(1);
report{4,1}='pmu_mark_end'; report{4,2}=pmu_mark_table.PMU_timestamp(end);
report{5,1}='pmu_ext_table'; report{5,2}=pmu_ext_table;
report{6,1}='pmu_mark_table'; report{6,2}=pmu_mark_table;

report{7,1}='mri_timestp_start'; report{7,2}=pmuTimestamp(1);
report{8,1}='mri_timestp_end'; report{8,2}=pmuTimestamp(end);
report{9,1}='pmuTimestamp'; report{9,2}=pmuTimestamp;
disp('The report cell is generated!')
%%

reportPath = [twixDir ...
        'report_', measSplit{1},'.mat'];
save(reportPath, 'report');
disp('report has been saved here:')
disp(reportPath)

    % - Subject 001:  1309.5466 - 653.1547 
    % - Subject 002:  914.2604 - 257.8359 
    % - Subject 003:  775.1672 - 118.7039 