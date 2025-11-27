%% Yiwei Jia Feb 03 2025
% The script is specifically used for analyzing Twix and save some
% information as "report" for Dataset "MREyeTrack" acquired on Jan. 27 2024
% ===========update information================================
% Instead of extracting EXT channel from PMUdata.raw.EXT, I fixed the try catch
% code block in mapVBVD_JB so that we can extract EXT directly from
% PMUdata.EXT, which shares the same timestamps as the raw measurements
%%
clc; clear all;
subject_num = 1;
meas_name = ['meas', '_MID00332_FID214628_BEAT_LIBREon_eye_(23_09_24)_sc_trigger'];
raw_data = ['/Users/cag/Documents/Dataset/datasets/250127_acquisition/', meas_name,'.dat'];
% raw_data = ['/Users/cag/Documents/tmp/Matteo/', ...
     % 'meas_MID00100_FID303840_Rad_TR5p46_SP2850_nPC12_BW906_pole_150x89_AU.dat'];
twix = mapVBVD_JB(raw_data);
%%
twix_img = twix{end};
PMU = twix_img.PMUdata;
%%
sum(sum(PMU.EXT))
sum(sum(PMU.raw.EXT.data))
twix_name = ['twix', '_MID00332_FID214628_BEAT_LIBREon_eye_(23_09_24)_sc_trigger'];
twix_path =  ['/Users/cag/Documents/Dataset/250127_acquisition/', twix_name,'.mat'];
disp(['Saving twix into', twix_path]);
save(twix_path, 'twix');

%%
if subject_num == 1
    rawdata_name = meas_name;
    twix = load(['/Users/cag/Documents/Dataset/250127_acquisition/' ...
        'twix_MID00332_FID214628_BEAT_LIBREon_eye_(23_09_24)_sc_trigger.mat']);
    datadir = ['/Users/cag/Documents/Dataset/250127_acquisition'];  
elseif subject_num == 2

else
    rawdata_name = 'meas_MID00554_FID182808_BEAT_LIBREon_eye_(23_09_24)';
    twix = load(['/Users/cag/Documents/Dataset/MREyeTrack/' ...
        'Twix/twix_subj3_meas_MID00554_FID182808_BEAT_LIBREon_eye_(23_09_24).mat']);
    datadir = ['/home/debi/jaime/acquisitions/MREyeTrack/' ...
    'MREyeTrack_subj3/RawData_MREyeTrack_Subj3/'];  
end

twix_image2 = twix.twix{1,end};
pmuEXT = twix_image2.PMUdata.EXT;
pmuTimestamp = twix_image2.image.timestamp;

%%
stop_time_ms = (pmuTimestamp(end)-pmuTimestamp(1)) * 2.5;
time_ms = linspace(0, stop_time_ms, length(pmuTimestamp));
ext1 = double(pmuEXT(1,:));
ext2 = double(pmuEXT(2,:));%remember to convert the data type, otherwise something wrong with rawTimestamp.
%
pmu_ext_table = array2table([pmuTimestamp(:)'; time_ms(:)' ; ext1(:)'; ext2(:)']', 'VariableNames', ...
    {'PMU_timestamp', 'PMU_time_ms', 'EXT1', 'EXT2'});

%%

pmu_mark_table = pmu_ext_table;
pmu_mark_table((pmu_ext_table.EXT1 == 0) & (pmu_ext_table.EXT2 == 0),:)=[];
%%
figure;
plot(time_ms(1:10*1000), pmu_ext_table.EXT1(1:10*1000), time_ms(1:10*1000), pmu_ext_table.EXT2(1:10*1000))
xlabel('time (ms)')
ylabel('pulse amplitude')
% figure;
% plot(time_ms(4000:8000), pmu_ext_table.EXT1(4000:8000), time_ms(4000:8000), pmu_ext_table.EXT2(4000:8000))
