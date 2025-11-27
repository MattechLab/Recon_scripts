function [breathing_binning] = mt_extractRespiratoryBinningInfo (br_cylce,Segment,time,nrRespThreshold)

% Syntax:       [th_line] = mt_extractRespiratoryBinningInfo (br_cylce,Segment,time,nr_threshold)
%
% Inputs:       br_cycle:      breathing cycle extracted from SI projection
%               Segment        Segment in a shot.
%               time:          Time vector in seconds.
%               nr_threshold   number of threshold (bins)
%
% Outputs:      Threshold line Respiratory motion extracted
%
% Description: Create automatic Threshold for Breathing binning.
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch
%
% Date:         Last Updated: 19.08.2024

%% PARAM
br_cylce =br_cylce';
ntviews = Segment*size(br_cylce,1);
timeSI=time(:,1:Segment:end,:);

%% AUTOMATIC THRESHOLD

lCurrentRadialViews = ntviews/nrRespThreshold; %% automatic number of SI spoke in each threshold

SI_segment =floor(lCurrentRadialViews/Segment);
th_line = ones(1,nrRespThreshold);
th_line(1)=0;

for i=2:size(th_line,2)
    while true
        nr_ind =size(find(br_cylce <= th_line(i)& br_cylce >= th_line(i-1)),1);
        if nr_ind >= SI_segment-1 && nr_ind <=SI_segment+1
            break;
        else
            th_line(i)=th_line(i)-0.0001;
            if th_line(i) < th_line(i-1)
                fprintf('Error at i = %d\n',i)
                break;

            end

        end
    end
end
% first threshold was set to 0 but is not needed
th_line(1)=[];

%% PLOT BREATHING CYLCE + THRESHOLD

f=figure;
f.Position = [100 100 1800 800];
subplot(2,1,1)
plot(timeSI,br_cylce,'-o', 'MarkerSize', 5,'MarkerFaceColor', 'b','MarkerEdgeColor','b','LineWidth',2.5,'Color','R')
hold on
for jj=1:size(th_line,2)
    yline(th_line(jj),'--','LineWidth',3,'Color','g')
end
hold off
title('Breathing Cycle With Binning Threshold');
xlabel('time [sec]')
ylabel('Magnitude [a.u.]')
xlim([-inf inf])
ylim([-inf inf])
%% BINNING SIGNAL

breathing_binning = ones(1,size(br_cylce,1));

for i=1:size(br_cylce,1)
    for j=1:size(th_line,2)
        if br_cylce(i) > th_line(j)
            breathing_binning(i) = j+1;
        end
    end
end
breathing_binning = repelem(breathing_binning,Segment);
%% PLOT BREATHING CYCLE + BINNING

subplot(2,1,2)
plot(timeSI,br_cylce,'-o', 'MarkerSize', 5,'MarkerFaceColor', 'b','MarkerEdgeColor','b','LineWidth',2.5,'Color','R')
ylabel('Magnitude [a.u.]')
ylim([-inf inf])
yyaxis right
plot(time,breathing_binning,'LineWidth',2)
ylabel('Bin Nr.')
xlabel('time [s]')
xlim([-inf inf])
title('Breathing Cycle With Binning Number');