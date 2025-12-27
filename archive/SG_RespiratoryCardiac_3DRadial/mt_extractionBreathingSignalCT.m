function [br_cylce] = mt_extractionBreathingSignalCT(kdata_raw,Segment,time,STD_mult,nr_ind_comp,max_iter)
%
% Syntax:       [br_cycle] = mt_extractionBreathingSignalCT(kdata_raw, Segment, time, STD_mult, nr_ind_comp, max_iter)
%
% Inputs:       kdata_raw:     Raw k-space data [nx, ntviews, nc].
%               Segment        Segment in a shot.
%               time:          Time vector in seconds.
%               STD_mult:      Multiplier for standard deviation thresholding (default: 2.5).
%               nr_ind_comp:   Number of independent components for PCA (default: 6).
%               max_iter:      Maximum number of iterations for ICA (default: 500).
%
% Outputs:      br_cycle:      Extracted breathing cycle signal.
%
% Description: Extracts the breathing signal from raw k-space data by:
%              1. Collecting the superior-inferior (SI) signal from the k-space center.
%              2. Removing outliers using high-pass filtering and thresholding.
%              3. Applying Principal Component Analysis (PCA) to reduce dimensionality.
%              4. Performing Independent Component Analysis (ICA) with a convergence criterion.
%              5. Plotting the interpolated breathing cycle signal.
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch  
%
% Date:         Last Updated: 19.08.2024
%



%% DEFAULT PARAM

% Set default values if parameters are not provided
if ~exist('STD_mult','var') || isempty(STD_mult)
    STD_mult = 2.5;
end

if ~exist('nr_ind_comp','var') || isempty(nr_ind_comp)
    nr_ind_comp = 6;
end

if ~exist('max_iter','var') || isempty(max_iter)
    max_iter = 500;
end

%% COLLECT SI + EXTRACT K-SPACE CENTER

[nx, ~, ~] = size(kdata_raw);

timeSI = time(1:Segment:end);
kdata_SI = abs(squeeze(kdata_raw(nx/2,1:Segment:end,:))); %% CONSIDER +1

%% REMOVE OUTLIERS

[b, a] = butter(5, 0.1, 'high');
data_filt =zeros(size(kdata_SI));

for i=1:size(kdata_SI,2)

    data_filt(:,i) =filtfilt(b, a,kdata_SI(:,i));
    STD = std(data_filt(:,i),0,1);

    up_th= mean(data_filt(:,i)) + STD_mult*STD;
    low_th=mean(data_filt(:,i)) - STD_mult*STD;

    indices_higher = data_filt(:,i) > up_th;
    indices_lower = data_filt(:,i) < low_th;

    data_filt(indices_higher,i) = up_th;
    data_filt(indices_lower,i) = low_th;

end

%% PCA ON COIL DIMENSION

[~, Data_PCA,~,~,~,~]= pca(data_filt,'NumComponents',nr_ind_comp);

%% ICA WITH CONVERGENCE CRITERIA

iter =0;
tot_iter=0;
max_STD = 0.2;

Data_ICA_norm = zeros(size(kdata_SI,1),nr_ind_comp);

while true
    tot_iter=tot_iter+1;

    Mdl=rica(Data_PCA,nr_ind_comp,'NonGaussianityIndicator',ones(nr_ind_comp,1));
    Data_ICA = transform(Mdl,Data_PCA);

    for i=1:nr_ind_comp

        Data_ICA_norm(:,i) = Data_ICA(:,i)+  min(Data_ICA(:,i));
      Data_ICA_norm(:,i) = (Data_ICA_norm(:,i) - min(Data_ICA_norm(:,i))) / (max(Data_ICA_norm(:,i)) - min(Data_ICA_norm(:,i)));

    end

    STD = std(Data_ICA_norm,0,1);
    [M, I] = max(STD);

    if M >(max_STD)
        br_cylce = Data_ICA_norm(:,I);
        iter =0;
        max_STD = max_STD+0.01;
    end

    if iter >max_iter
        break;
    end
    iter = iter+1;
end
%% PLOT

fakeTime =linspace(time(1),time(end),size(time,2));
br_cylce_inter = spline(timeSI, br_cylce, fakeTime);
br_cylce=br_cylce';
f=figure;
f.Position = [100 100 1500 400];
plot(fakeTime, br_cylce_inter,'LineWidth',2,'Color','r');
hold on;
plot(timeSI, br_cylce, 'o', 'MarkerFaceColor', 'b','MarkerEdgeColor','b');
title('Breathing Cylce interpolated');
xlabel('Time [s]');
ylabel('Magnitude [a.u.]');
text = sprintf('Breathing Signal Interpolated\nTot Iter %d, MAX STD = %.2f',tot_iter,max_STD);
title(text)
legend('Interpolated signal','Original SI')
ylim([-inf inf])

end
