function stop_time_ms = resolve_twix_ext(baseFolder, plotPMU, generateReport)
%% resolve_twix_ext
% Yiwei Jia  - organized version
%
% Purpose:
%   - Load a Siemens raw .dat file (Twix), extract PMU EXT channels
%   - Save the Twix object as a .mat file
%   - Optionally plot EXT signals
%   - Optionally generate and save a report (.mat) with tables and timing info
%
% Notes:
%   - Assumes mapVBVD_JB outputs PMUdata.EXT aligned to measurement timestamps.
%   - The factor 2.5 is preserved from your original code to convert timestamp
%     ticks to milliseconds. Adjust if needed.

%% -------------------- Defaults / nargin handling -------------------------
DEFAULT_BASEFOLDER = '/mnt/filer01/MatTechLab/yiwei.jia/';

if nargin < 1 || isempty(baseFolder)
    baseFolder = DEFAULT_BASEFOLDER;
end
if nargin < 2 || isempty(plotPMU)
    plotPMU = false;
end
if nargin < 3 || isempty(generateReport)
    generateReport = false;
end

stop_time_ms = NaN; % default output in case we exit early

%% -------------------- Select raw .dat file -------------------------------
[measFilename, rawDir] = uigetfile('*.dat', 'Select main raw data file', baseFolder);
if isequal(measFilename, 0)
    error('Measurement data file selection was cancelled.');
end

measureFile = fullfile(rawDir, measFilename);

% Use filename stem for naming saved outputs
measSplit = split(measFilename, '.');
measStem  = measSplit{1};

%% -------------------- Load Twix from .dat and save to .mat ---------------
twix = mapVBVD_JB(measureFile);

% Pick last element as image twix (your original logic)
twix_img = twix{end};

% Basic PMU access (kept; but remove/disable debug prints if you want)
PMU = twix_img.PMUdata;
% disp(sum(sum(PMU.EXT)));              % optional debug
% disp(sum(sum(PMU.raw.EXT.data)));     % optional debug

% Save twix
twixFolder = fullfile(rawDir, 'twix');
if ~isfolder(twixFolder)
    mkdir(twixFolder);
end

twix_name = ['twix_', measStem];
twix_path = fullfile(twixFolder, [twix_name, '.mat']);

disp(['Saving twix into: ', twix_path]);
save(twix_path, 'twix');

%% -------------------- Select twix .mat file (or fallback) ----------------
% Your original script asks again for a twix .mat. We keep that behavior,
% but if the user cancels, we fall back to the twix we just saved.
[twixFilename, twixDir] = uigetfile('*.mat', 'Select twix data file', twixFolder);

if isequal(twixFilename, 0)
    % fallback to freshly saved one
    twixFilename = [twix_name, '.mat'];
    twixDir = twixFolder;
    disp(['Twix selection cancelled. Using: ', fullfile(twixDir, twixFilename)]);
end

S = load(fullfile(twixDir, twixFilename));
if ~isfield(S, 'twix')
    error('Selected .mat does not contain variable "twix".');
end

% Again pick last element (safer than hard-coded {1,end})
twix_image2 = S.twix{end};

%% -------------------- Extract EXT + timestamps ---------------------------
% EXT is usually 2 x N (or more). We'll use first two channels.
pmuEXT = twix_image2.PMUdata.EXT;

% These timestamps are from twix_image2.image.timestamp in your original code.
% Rename for clarity: these are the measurement/image timestamps.
mriTimestamp = twix_image2.image.timestamp;

% Defensive checks
if isempty(mriTimestamp)
    error('mriTimestamp is empty. twix_image2.image.timestamp not found/empty.');
end
if isempty(pmuEXT)
    error('pmuEXT is empty. twix_image2.PMUdata.EXT not found/empty.');
end
if size(pmuEXT, 1) < 2
    error('pmuEXT has < 2 rows. Expected at least 2 EXT channels.');
end

% Convert timestamps to relative time in ms (preserving your 2.5 factor)
time_ms = (mriTimestamp - mriTimestamp(1)) * 2.5;
stop_time_ms = time_ms(end);

disp(['Duration based on timestamps (ms): ', num2str(stop_time_ms)]);

ext1 = double(pmuEXT(1, :));
ext2 = double(pmuEXT(2, :));

% Ensure consistent column vector lengths
N = min([numel(mriTimestamp), numel(ext1), numel(ext2)]);
mriTimestamp = mriTimestamp(1:N);
time_ms      = time_ms(1:N);
ext1         = ext1(1:N);
ext2         = ext2(1:N);

%% -------------------- Build tables ---------------------------------------
pmu_ext_table = table( ...
    mriTimestamp(:), ...
    time_ms(:), ...
    ext1(:), ...
    ext2(:), ...
    'VariableNames', {'MRI_timestamp', 'MRI_time_ms', 'EXT1', 'EXT2'} );

% "Mark" table: keep only rows where at least one EXT channel is non-zero
pmu_mark_table = pmu_ext_table;
pmu_mark_table((pmu_mark_table.EXT1 == 0) & (pmu_mark_table.EXT2 == 0), :) = [];

%% -------------------- Optional plot --------------------------------------
if plotPMU
    figure;
    plot(pmu_ext_table.MRI_time_ms, pmu_ext_table.EXT1, ...
         pmu_ext_table.MRI_time_ms, pmu_ext_table.EXT2);
    xlabel('time (ms)');
    ylabel('pulse amplitude');
    legend({'EXT1', 'EXT2'});
    title('PMU EXT channels');
end

%% -------------------- Optional report ------------------------------------
if generateReport
    if isempty(pmu_mark_table)
        warning('pmu_mark_table is empty (no non-zero EXT marks). Report will still be saved.');
    end

    % Helpful timing summaries (all in ms relative to MRI start)
    first_mri_ms = pmu_ext_table.MRI_time_ms(1);

    if ~isempty(pmu_mark_table)
        first_mark_ms = pmu_mark_table.MRI_time_ms(1);
        last_mark_ms  = pmu_mark_table.MRI_time_ms(end);
    else
        first_mark_ms = NaN;
        last_mark_ms  = NaN;
    end

    disp('Timing summary (ms, relative to first MRI timestamp):');
    disp(['  First MRI sample:       ', num2str(first_mri_ms)]);
    disp(['  First EXT mark (nonzero): ', num2str(first_mark_ms)]);
    disp(['  Last  EXT mark (nonzero): ', num2str(last_mark_ms)]);

    % Cell report (kept similar to your original style)
    report = {};
    report{1,1} = 'mri_timestp_start';  report{1,2} = pmu_ext_table.MRI_timestamp(1);
    report{2,1} = 'mri_timestp_end';    report{2,2} = pmu_ext_table.MRI_timestamp(end);

    report{3,1} = 'mri_time_ms_end';    report{3,2} = stop_time_ms;

    report{4,1} = 'first_mark_ms';      report{4,2} = first_mark_ms;
    report{5,1} = 'last_mark_ms';       report{5,2} = last_mark_ms;

    report{6,1} = 'pmu_ext_table';      report{6,2} = pmu_ext_table;
    report{7,1} = 'pmu_mark_table';     report{7,2} = pmu_mark_table;

    disp('Report cell generated.');

    % Save report next to selected twix .mat (twixDir)
    reportPath = fullfile(twixDir, ['report_', measStem, '.mat']);
    save(reportPath, 'report');
    disp('Report saved here:');
    disp(reportPath);
end

end