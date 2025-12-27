function [PCA_respV2] = mt_respiratory_info_extraction_BandPass(kdata,Segment, time,lowcut_resp,highcut_resp)
%
% Syntax:       [PCA_resp] = mt_respiratory_info_extraction_BandPass(kdata_SI, time,lowcut_resp,highcut_resp)
%
% Inputs:       kdata:         k-space [mx ,ntviews, nc] .
%               Segment        Segment in a shot
%               time:          Time vector in seconds.
%               lowcut_card:   Low frequency threshold for bandpass filter.
%               highcut_card:  High frequency threshold for bandpass filter.
%
% Outputs:      PCA_resp:      Respiratory motion extracted
%
% Description: Extracts respiratory information from the SI projection of radial k-space data by:
%              1. Bandpass Filtering: Uses a Butterworth bandpass filter to isolate respiratory frequencies.
%              2. PCA: Applies Principal Component Analysis to extract the primary respiratory component.
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch
%
% Date:         Last Updated: 16.07.2024

%% PARAM
[nx, ~, nc] = size (kdata);
kdata_SI = abs(squeeze(kdata(nx/2,1:Segment:end,:)));
timeSI = time(:,1:Segment:end,:);
%% BANDPASS

D = diff(timeSI);
fs = 1/D(1);
order = 3;

[b_resp, a_resp] = butter(order, [lowcut_resp highcut_resp]/(fs/2), 'bandpass');

clear respiratory_signal
for i =1:nc
    respiratory_signal(:,i) = filtfilt(b_resp, a_resp, abs(kdata_SI(:,i)));
end


%% PCA

[~, PCA_resp]= pca(respiratory_signal,'NumComponents',1);

PCA_resp =PCA_resp';
%% NORM (comment to use hilbert)
PCA_resp=(PCA_resp - min(PCA_resp) )/ (max(PCA_resp) - min(PCA_resp));
%% INTERP
PCA_resp_inter = spline(timeSI, PCA_resp, time);
%% REMOVE NON STEADY SEGMENT BECAUSE OF FILTERING

[PCA_respV2, timeV2] = mt_removeUnsteadySegments(PCA_resp_inter, time,Segment);
PCA_respV2 = PCA_respV2(1:Segment:end);
timeV2 = timeV2(1:Segment:end);
%% PLOT
f=figure;
f.Position = [100 100 1800 600];
plot(timeV2,PCA_respV2,'-o', 'MarkerSize', 5,'MarkerFaceColor', 'b','MarkerEdgeColor','b','LineWidth',2.5,'Color','R')
text = sprintf('Respiratory Signal, Bandpass [%.1f %.1f ] Hz',lowcut_resp,highcut_resp);
title(text)
xlabel('Time [s]')
ylabel('Magnitude [a.u.]')
xlim([-inf inf])

