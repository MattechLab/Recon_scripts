%%

load('/Users/cag/Documents/Dataset/recon_results/251109/sub1_motion/nav_readouts_4samples.mat')
%%
figure;
TR = 6.2e-3;

t = 0:1*TR: 96887*TR;

for i=5:15
    plot(t, squeeze(nav_readouts(i, 2, :)));
    hold on;
    xlim([0, 600])
end
%%
% Pretty overlay for nav_readouts(:,2,:)
TR = 6.2e-3;                                % seconds
nSamp = size(nav_readouts, 3);              % derive length from data (robust)
t = (0:nSamp-1) * TR;
idx = 6:15;

figure('Color','w','Position',[100 100 900 420]);  % white bg, wide
tiledlayout(1,1,'Padding','compact','TileSpacing','compact');
ax = nexttile;

% nicer, consistent colors
co = lines(numel(idx));                     % try 'parula' or 'turbo' if you prefer
colororder(ax, co);

hold(ax,'on');
for k = 1:numel(idx)
    y = squeeze(nav_readouts(idx(k), 2, :));
    plot(ax, t, y, 'LineWidth', 1.3);      % thicker lines
end
xlim(ax, [0 273]);
grid(ax, 'on'); ax.XMinorGrid = 'on'; ax.YMinorGrid = 'on';
ax.GridAlpha = 0.18; ax.MinorGridAlpha = 0.10;
box(ax, 'off');                             % cleaner frame

xlabel(ax, 'Time (s)');
ylabel(ax, 'Signal (a.u.)');
title(ax, 'Navigation Readouts');
legend(ax, "i = " + string(idx), 'Location','eastoutside', 'Box','off');

set(ax, 'FontName','Helvetica', 'FontSize',12);

% Vertical guide lines every 30 s from 0 to 600 s
vmarks = 0:30:600;

if ~isempty(which('xline'))                   % modern MATLAB
    xline(ax, vmarks, ':', ...
        'Color', [0.6 0.6 0.6], ...
        'LineWidth', 0.8, ...
        'HandleVisibility','off');            % keep them out of legend
else                                          % fallback for older versions
    yl = ylim(ax);
    for xv = vmarks
        plot(ax, [xv xv], yl, '-', ...
            'Color', [0.6 0.6 0.6], ...
            'LineWidth', 0.8, ...
            'HandleVisibility','off');
    end
end