% Example data
data = {
    'Site 1 IDEA vs Site 1 Pulseq', 0.9608, 0.9229, 0.9139, 0.8273;
    'Site 1 Pulseq vs Site 2 Pulseq', '-', 0.6911, 0.6046, 0.6993
};

colnames = {'Comparison','Phantom','Subject 1','Subject 2','Subject 3'};

% Create uitable
t = uitable('Data', data, 'ColumnName', colnames, ...
    'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.4]);

% Auto-adjust column widths based on content
t.ColumnWidth = 'auto';

% Adjust the figure size to fit table content automatically
drawnow;  % updates Extent property
t.Position(3:4) = t.Extent(3:4);