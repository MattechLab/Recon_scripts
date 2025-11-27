function [valuesHILB,locsHILB] = mt_extractCardiacBinningInfoBandPass(kdata, time,PMU,lowcut_card,highcut_card)
%
% Syntax:       [valuesHILB,locsHILB] = mt_extractCardiacBinningInfoBandPass(kdata, time,PMU,lowcut_card,highcut_card)
%
% Inputs:       kdata:         k-space [mx ,ntviews, nc] .
%               time:          Time vector in seconds.
%               PMU:           Pulse Oximeter (PPU) or ECG data.
%               lowcut_card:   Low frequency threshold for bandpass filter.
%               highcut_card:  High frequency threshold for bandpass filter.
%
% Outputs:      values: Value of the peak.
%               locs: Position of the peak.    
%
% Description: Extracts cardiac information from the SI projection of radial k-space data by:
%              1. Bandpass Filtering: Isolates heartbeat frequencies using a Butterworth bandpass filter.
%              2. PCA: Extracts primary cardiac component via Principal Component Analysis.
%              3. Hilbert Transform: Demodulates the signal to remove modulation effects.
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch  
%
% Date:         Last Updated: 19.08.2024

%% PARAM

[nx, ~, nc] = size (kdata);
kdata =squeeze(kdata(nx/2,:,:));

%% RAW DATA PLOT

f=figure;
f.Position = [100 100 1500 600];
idx=1;
% plot coil to coil
for i=1:nc
    cols = ceil(sqrt(nc));        % number of columns
    rows = ceil(nc/cols);         % number of rows (just enough to fit N)
    subplot(rows,cols,idx)
    plot(time,abs(kdata(:,i)),'LineWidth',2);
    xlim([50 70])
    title(sprintf('Coil %d',i))
    xlabel('Time [s]')
    ylabel('Magnitude [a.u.]')
    hold on;
    % set(gca, 'FontSize', 15);
    % set(gca, 'LineWidth', 2);
    idx=idx+1;
    sgtitle('K-space Center of all Readout - Raw Signal', 'FontWeight', 'bold', 'FontSize', 20)
end
% overlap the channels
f=figure;
f.Position = [100 100 1500 600];
for i=1:10
    plot(time,abs(kdata(:,i)),'LineWidth',2);
    xlim([50 70])
    % title(sprintf('Coil %d',i))
    xlabel('Time [s]')
    ylabel('Magnitude [a.u.]')
    hold on;

    sgtitle('K-space Center of all Readout - Raw Signal', 'FontWeight', 'bold', 'FontSize', 20)
end
%% BANDPASS

fs = 1/diff(time(1:2));
order = 1;

[b_card, a_card] = butter(order, [lowcut_card highcut_card]/(fs/2), 'bandpass');

clear cardiac_signal 
for i=1:nc
    cardiac_signal(:,i) = filtfilt(b_card, a_card, abs(kdata(:,i)));

end

f=figure;
f.Position = [100 100 1500 600];
idx=1;
for i=1:nc
    cols = ceil(sqrt(nc));        % number of columns
    rows = ceil(nc/cols);         % number of rows (just enough to fit N)
    subplot(rows,cols,idx)
    plot(time,cardiac_signal(:,i),'LineWidth',2,'Color','r');
    xlim([50 70])
    title(sprintf('Coil %d',i))
    xlabel('Time [s]')
    ylabel('Magnitude [a.u.]')
    % set(gca, 'FontSize', 15);
    % set(gca, 'LineWidth', 2);
    idx=idx+1;
    sgtitle('K-space Center of SI Readout - Cardiac Bandpass', 'FontWeight', 'bold', 'FontSize', 20)
end

% overlap the channels
f=figure;
f.Position = [100 100 1500 600];
for i=1:10
    plot(time,abs(cardiac_signal(:,i)),'LineWidth',2);
    xlim([50 70])
    % title(sprintf('Coil %d',i))
    xlabel('Time [s]')
    ylabel('Magnitude [a.u.]')
    hold on;

    sgtitle('K-space Center of all Readout - Raw Signal', 'FontWeight', 'bold', 'FontSize', 20)
end
%% PCA

[~, PCA_card]= pca(cardiac_signal,'NumComponents',1);

%% HILBER TRANSFORM

envelope = abs(hilbert(PCA_card));
PCA_card_norm = (PCA_card ./ envelope);
[valuesHILB,locsHILB] =findpeaks(PCA_card_norm,'MinPeakDistance',60);
	% The k-space center magnitude can vary slowly over time (coil drifts, breathing, contrast changes).
	% Those slow amplitude changes can distort the peaks.
	% By dividing out the envelope, the cardiac oscillation becomes more stationary and clean, 
    % making peak detection more robust and less sensitive to those slow drifts.
%% PLOT

f=figure;
f.Position = [100 100 1500 400];

XLIM = [time(1) time(1)+60];

for i=1:2
    subplot(2,1,i)
    plot(time,PCA_card_norm,'LineWidth',3,'Color','r');
    hold on
    xline(time(locsHILB),'--','Color','g','LineWidth',2)
    ylabel('Magnitude [a.u.]')
    yyaxis right
    plot(time,PMU,'LineWidth',1,'Color','b')
    xlim([XLIM(i) XLIM(i)+60])
    text = sprintf('Cardiac Signal, Bandpass [%.1f  %.1f ] Hz',lowcut_card,highcut_card);
    xlabel('Time [s]')
    ylabel('PMU [ms]')
    title(text)
    ax = gca;
    ax.YAxis(2).Color = 'b';

end