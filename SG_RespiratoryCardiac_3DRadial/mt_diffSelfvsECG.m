function mt_diffSelfvsECG(time,locsPMU, locsHILB)
%
% Syntax:       mt_diffSelfvsECG(time,locsPMU, locsHILB)
%
% Inputs:       time:          Time vector
%               locsPMU:       R peak of ECG signal
%               locsHILB:      R peak of SG signal    
%
% Description: Plot peak difference from ECG sginal and SG signal
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch  
%
% Date:         Last Updated: 19.08.2024
%



D =abs(time(locsPMU) -time(locsHILB))*1000;
D(1) =[];
D(end) =[];
f=figure;
f.Position = [100 100 1500 400];
plot(D,'.-','LineWidth',2,'Color','m','MarkerSize',20)
hold on
yline(mean(D),'--','Color','g','LineWidth',2)
yline(mean(D)+std(D),'--','Color','b','LineWidth',2)
yline(mean(D)-std(D),'--','Color','b','LineWidth',2)
text1 = sprintf('Mean = %.1f ms',mean(D));
text2 = sprintf('STD = %.1f ms',std(D));
legend('Time Difference ECG and Selfgating signal',text1,text2)
xlim([1 inf])
xlabel('R-R Peak nr.')
ylabel('Time Difference [ms]')
title('Time Difference Analysis Between ECG and Self-Gating Signals')
ylim([0 inf])
% set(gca, 'FontSize', 15);
% set(gca, 'LineWidth', 2);


end