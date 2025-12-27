%% Yiwei Jia Feb 03 2025
% The script is specifically used for analyzing Twix and save some
% information as "report" for Dataset "MREyeTrack" acquired on Jan. 27 2024
% ===========update information================================
% Instead of extracting EXT channel from PMUdata.raw.EXT, I fixed the try catch
% code block in mapVBVD_JB so that we can extract EXT directly from
% PMUdata.EXT, which shares the same timestamps as the raw measurements
%%
function [stop_time_ms] = resolve_twix_ext(baseFolder, plotPMU,  generateReport)

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
if plotPMU
time_ms = linspace(0, stop_time_ms, length(pmuTimestamp));
ext1 = double(pmuEXT(1,:));
ext2 = double(pmuEXT(2,:));%remember to convert the data type, otherwise something wrong with rawTimestamp.
%
pmu_ext_table = array2table([pmuTimestamp(:)'; time_ms(:)' ; ext1(:)'; ext2(:)']', 'VariableNames', ...
    {'PMU_timestamp', 'PMU_time_ms', 'EXT1', 'EXT2'});

pmu_mark_table = pmu_ext_table;
pmu_mark_table((pmu_ext_table.EXT1 == 0) & (pmu_ext_table.EXT2 == 0),:)=[];
%%
figure;
plot(time_ms, pmu_ext_table.EXT1, time_ms, pmu_ext_table.EXT2)
xlabel('time (ms)')
ylabel('pulse amplitude')

end
%%
if generateReport
diff_ms = diff(pmu_mark_table.PMU_time_ms);
diff_stamp = diff(pmu_mark_table.PMU_timestamp);
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
%

reportPath = [twixDir ...
        'report_', measSplit{1},'.mat'];
save(reportPath, 'report');
disp('report has been saved here:')
disp(reportPath)
end
    % - Subject 001:  1309.5466 - 653.1547 
    % - Subject 002:  914.2604 - 257.8359 
    % - Subject 003:  775.1672 - 118.7039 
end