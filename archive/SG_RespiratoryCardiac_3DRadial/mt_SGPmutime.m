function [newPmutime] = mt_SGPmutime(kdata_raw,time,locsHILB)
%
% Syntax:       [newPmutime] = mt_SGPmutime(kdata_raw, time, locsHILB)
%
% Inputs:       kdata_raw:     Raw k-space data [mx, ntviews, nc].
%               time:          Time vector in seconds.
%               locsHILB:      Locations of the R-peaks detected via Hilbert transform.
%
% Outputs:      newPmutime:    Reconstructed PMU time vector based on self-gating.
%
% Description: Constructs a new PMU time vector by:
%              1. Generating the new Pmutime based on locsHILB.
%              2. Plotting the new PMU time vector.
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch  
%
% Date:         Last Updated: 19.08.2024
%


%% NEW PMUTIME
previus=0;
newPmutime = zeros([1,size(kdata_raw,2)]);
for i =1:size(locsHILB,1)
    RRSize = locsHILB(i);
    if i > 1
        RRSize = (locsHILB(i) - locsHILB(i-1));
    end
    linspaceArray = linspace(0, RRSize - 1, RRSize);
    newPmutime(previus + 1:previus + linspaceArray(end)+1) = linspaceArray;

    previus =previus+ linspaceArray(end)+1;
end

%% PLOT 
f = figure;
f.Position = [100 100 1500 400];
plot(time,newPmutime,'LineWidth',2)
hold on
[valuesPMU , locsPMU] = findpeaks(newPmutime);
plot(time(locsPMU),valuesPMU,'v','Color','k','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','k')
xlabel ('Time [s]')
ylabel ('Time [s]')
title ('New PMUTIME Based on Self-Gating')
xlim([0 inf])
legend('PMUTIME','R Peak')

end