function [BestPmutime, BestHeartBinning, BestPercSegLoss,BestRemovedIndices] = mt_extractCardiacBinningInfo(pmutime, nrCardThreshold)
%
% Syntax:       [BestPmutime, BestHeartBinning, BestPercSegLoss,BestRemovedIndices] = mt_extractCardiacBinningInfo(pmutime, nrCardThreshold)
%
% Inputs:       pmutime:            A vector representing the pmu time signal.
%               nrCardThreshold:    Scalar value representing the threshold for binning.
%
% Outputs:      BestPmutime - Modified pmutime vector after removing specific RR intervals.
%               BestHeartBinning - Optimized heart binning array.
%               BestPercSegLoss - The percentage of segments lost with the optimized binning.
%               RemovedIndices - Indices of the removed elements from the original pmutime vector.
%
% Description:  This function takes in a pmutime signal and a threshold value, and
%               computes the optimized heart binning to minimize segment loss. It iteratively
%               removes RR intervals with values below a certain threshold, recalculates
%               the binning, and tracks the configuration that results in the lowest
%               segment loss.
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch
%
% Date:         Update: 19.08.2024


[value, locs] = findpeaks(pmutime);

NewPercSegLoss = ones(1,(round(max(value)) - 1))*100;
RemovedIndices = cell(1, (round(max(value)) - 1));

% Iteratively remove R-R peak under the threshold
for w = (round(max(value)/2) - 1):2:(round(max(value)) - 1)

    % Find indices to remove under the threshold
    removeIdx = find(value <= w);
    RRToRemove = locs(removeIdx);
    RRToRemovePrev = zeros(1, length(removeIdx));
    if ~isempty(RRToRemove)

        if removeIdx(1)==1
            RRToRemovePrev(1)=0;
            RRToRemovePrev(2:end) = locs(removeIdx(2:end)-1)+1;
        else
            RRToRemovePrev(1:end) = locs(removeIdx(1:end)-1)+1;
        end
    end
    % Store indices to remove and remove it from pmutime
    pmutimeV2{w} = pmutime;
    pmutimeV3{w} = pmutime;
    for i = size(RRToRemove, 2):-1:1
        if find(locs == RRToRemove(i)) == size(locs, 2)
            pmutimeV2{w}(RRToRemovePrev(i):end) = [];
             pmutimeV3{w}(RRToRemovePrev(i):end) = 0;
            RemovedIndices{w} = [RemovedIndices{w},RRToRemovePrev(i):numel(pmutime)];
        elseif find(locs == RRToRemove(i)) ~= 1
            pmutimeV2{w}(RRToRemovePrev(i):RRToRemove(i)) = [];
            pmutimeV3{w}(RRToRemovePrev(i):RRToRemove(i)) = 0;
            RemovedIndices{w} = [RemovedIndices{w}, RRToRemovePrev(i):RRToRemove(i)];
        elseif find(locs == RRToRemove(i)) == 1
            pmutimeV2{w}(1:RRToRemove(i)) = [];
             pmutimeV3{w}(1:RRToRemove(i)) = 0;
            RemovedIndices{w} = [RemovedIndices{w}, 1:RRToRemove(i)];
        else
        end
        
    end
%w
    % Equal size of bin, with maxiaml expansion
    [~, locsV2] = findpeaks(pmutimeV2{w});
    lim = nrCardThreshold * fix(min(diff(locsV2)) / nrCardThreshold);
    segment_in_each_bin = fix(min(diff(locsV2)) / nrCardThreshold);

    % Binning
    heart_binning{w} = zeros(1, size(pmutimeV2{w}, 2));
    for k = 1:size(locsV2, 2) - 1
        for i = 1:lim
            heart_binning{w}(1, i + locsV2(k)) = ceil(i / segment_in_each_bin);
        end
    end

    % Total loss of segment
    NewPercSegLoss(w) = (sum(heart_binning{w} == 0) + (numel(pmutime) - numel(pmutimeV2{w}))) / numel(pmutime) * 100;

    % Exit condition
    if(NewPercSegLoss(w))>50
        break;
    end
end

% Best parameter extracted
[BestPercSegLoss, BestLocs]= min(NewPercSegLoss);
BestPmutime =pmutimeV2{BestLocs};
BestHeartBinning =  heart_binning{BestLocs};
BestRemovedIndices = RemovedIndices{BestLocs};

% Plot removed R-R 
f=figure;
f.Position = [100 100 1500 400];
plot(pmutime,'LineWidth',3)
hold on
plot(pmutimeV3{BestLocs},'--','LineWidth',3)
plot(sort(BestRemovedIndices),pmutime(sort(BestRemovedIndices)),'.-','MarkerSize',10,'LineWidth',2)
title('Removed R-R Segment vs Oroginal Pmutime');
xlabel('Time [s]')
ylabel('Time [s]')
legend('Original Pmutime','New Pmutime','Removed R-R')

% PLOT BINNING

f=figure;
f.Position = [100 100 1500 400];
findpeaks(BestPmutime)
ylabel('Time [s]')
ylim([0 inf])
yyaxis right
plot(BestHeartBinning)
title(sprintf('PMU Signal and Binning Signal After Smart Binning\n Current Segment Loss %.2f%%',BestPercSegLoss));
xlabel('Time [s]')
ylabel('Bin Nr.')
legend('Pmutime','R peak','Bin number')


end