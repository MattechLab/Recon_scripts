%% Evaluate K-space fullness
function CalR_script(import_eMask, eMask_folder, seqParams)



% Extracting sequence
seq = mr.Sequence();
seq.read(seqParams.seqFile);
kspace_traj = seq.calculateKspacePP();
% 6) Reshape to [3, N, nSeg, nShot]
nSeg            = seqParams.nseg; 
nShot           = seqParams.nshot; 
N               = seqParams.nsam;




k_trj = reshape(kspace_traj, size(kspace_traj,1), [], nSeg, nShot);
if size(k_trj,2)>N
    k_fid= k_trj(:, 1:size(k_trj,2)-N, :, :);        
    k_trj = k_trj(:, size(k_trj,2)-N+1:end, :, :);   
end

% compute distances from the k space center for each sampled point
distances = vecnorm(k_trj, 2,1);
% R: the maximum distance of the point from the trajectory in k-space to
% the center
R = max(distances(:));
k_trj = k_trj/R/2;

% if flagSelfNav
%    k_trj(:, :, 1, :) = [];  
% end
% if nShot_off > 0
%    k_trj(:, :, :, 1:nShot_off) = [];  
% end

mySize = size(k_trj); 
mySize = mySize(:)'; 
t = reshape(k_trj, [mySize(1, 1), mySize(1, 2), mySize(1, 3)*mySize(1, 4)]); 

Traj3D = permute(t, [2,3,1]);

% Plot trajectory (first line of each segment)
figure; plot3(Traj3D(:,1:nSeg,1), Traj3D(:,1:nSeg,2), Traj3D(:,1:nSeg,3), 'LineWidth', 2);
hold on;
plot3(Traj3D(end,1:nSeg,1), Traj3D(end,1:nSeg,2), Traj3D(end,1:nSeg,3), 'LineWidth', 2, 'Color', 'r');
grid minor;
xlabel('x-axis'); ylabel('y-axis'); zlabel('z-axis');
title('Trajectory');
xlim([-0.5 0.5]); ylim([-0.5 0.5]); zlim([-0.5 0.5]);
view(3);

%% GRIDDING (Mapping trajectory to Cartesian grid)
if import_eMask
    [eMask_set, matPaths] = load_eMasks(eMask_folder);
    count = numel(eMask_set);
else
    count = 1;
end

for idx = 1:count
    if import_eMask
        matPath = matPaths{idx};
        disp(['matPath processed:', matPath]);
    end

    [N, ntviews, ~] = size(Traj3D);
    x_cord = linspace(-0.5, 0.5, N);
    dx = x_cord(2) - x_cord(1); % Grid spacing

    matrix = zeros(N, N, N); % Initialize empty 3D grid
    
    % Convert trajectory coordinates to discrete grid indices
    indices = round((Traj3D + 0.5) / dx) + 1;
    % Example data
    % import eMask
    if import_eMask
        eMask = eMask_set{idx}; 
        fields = fieldnames(eMask);  % Get the field names
        firstField = fields{1};  % Get the first field name
        eMask = eMask.(firstField);  % Access the first field's value

  
        % Expand the mask to apply across dimensions
        eMask = reshape(eMask, [1, ntviews, 1]);         % shape [1, ntviews, 1]
        eMask = repmat(eMask, [480, 1, 3]);          % shape [480, ntviews, 3]
        % Apply the mask
        indices(~eMask) = 0;  % sets values to 0 where mask is 0
    end
    
    
    % Remove points that fall outside grid boundaries
    valid = all(indices >= 1 & indices <= N, 3);
    
    % Populate grid with sampled k-space points
    for k = 1:ntviews
        if valid(:, k) % Only consider valid points
            x_index = indices(:, k, 1);
            y_index = indices(:, k, 2);
            z_index = indices(:, k, 3);
            linear_idx = sub2ind([N, N, N], x_index, y_index, z_index);
            matrix(linear_idx) = matrix(linear_idx) + 1;
        end
    end
    matrix(matrix > 1) = 1; % Normalize grid occupancy to binary values
    
    % SPHERICAL MASK (For k-space volume estimation)
    [x, y, z] = ndgrid(x_cord, x_cord, x_cord); % Create 3D grid coordinates
    mask = (x.^2 + y.^2 + z.^2) <= 0.5^2; % Define spherical mask

    % ACCELERATION FACTORS (Various definitions)
    
    R1 = N^3 / numel(find(matrix == 1)); % Cartesian (including empty corners)
    R2 = (N^3 - numel(find(mask == 0))) / numel(find(matrix == 1)); % Cartesian (excluding empty corners)
    R3 = (0.2*size(matrix,1)^3)/numel(find(matrix == 1)); % 20% Nyquist with full matrix incl corners
    R4 = (0.2*numel(find(mask == 1)))/numel(find(matrix == 1)); % 20% Nyquist with full matrix exl corners
    R5 = (N^2 * pi) / (size(Traj3D,2) * 8); % Radial approximation

    % Visualize k-space fullness
    figure
    sliceViewer(matrix);
    fprintf('Cartesian (incl. corners): R=%.2f\n', R1);
    fprintf('Cartesian (excl. corners): R=%.2f\n', R2);
    fprintf('Matteo:  20%% Nyquist with full matrix incl corners: R=%.2f\n', R3);
    fprintf('20%% Nyquist with full matrix excl corners: R=%.2f\n', R4);
    fprintf('Simens:  equation for Radial: R=%.2f\n', R5);

    % Get the folder where the MAT lives (= "other")
    otherDir = fileparts(matPath);
    [~, baseName, ~] = fileparts(matPath);
    % Replace the last "_<suffix>" with "_accR"
    txtBase = regexprep(baseName, '_[^_]+$', '_accR');  % -> "eMask_win7_th0.90_accR"
    txtPath = fullfile(otherDir, [txtBase '.txt']);
    
    
    % Write the file
    fid = fopen(txtPath, 'w');
    if fid == -1
        error('Cannot open file for writing:\n%s', txtPath);
    end
    fprintf(fid, 'Cartesian (incl. corners): R=%.2f\n', R1);
    fprintf(fid, 'Cartesian (excl. corners): R=%.2f\n', R2);
    fprintf(fid, 'Matteo:  20%% Nyquist with full matrix incl corners: R=%.2f\n', R3);
    fprintf(fid, '20%% Nyquist with full matrix excl corners: R=%.2f\n', R4);
    fprintf(fid, 'Simens:  equation for Radial: R=%.2f\n', R5);
    
    fclose(fid);
    fprintf('Saved: %s\n', txtPath);
end
end

function [S, matPaths] = load_eMasks(rootDir)

% --- normalize rootDir to a cell array of char ---
    if ischar(rootDir) || (isstring(rootDir) && isscalar(rootDir))
        rootDirs = {char(rootDir)};
    elseif iscell(rootDir)
        rootDirs = cellfun(@char, rootDir, 'UniformOutput', false);
    elseif isstring(rootDir)
        rootDirs = cellstr(rootDir);
    else
        error('rootDir must be a char, string, cell array, or string array.');
    end
    
    % --- collect files from all root dirs ---
    matsAll = struct('folder', {}, 'name', {}, 'datenum', {}, 'bytes', {}, 'isdir', {}, 'date', {});
    for i = 1:numel(rootDirs)
        rd = rootDirs{i};
        if ~isfolder(rd)
            warning('Skipping non-existent folder: %s', rd);
            continue;
        end
        mats_i = dir(fullfile(rd, '**', 'eMask*.mat'));  % recursive
        mats_i = mats_i(~[mats_i.isdir]);           % safety
        matsAll = [matsAll; mats_i]; %#ok<AGROW>
    end

    if isempty(matsAll)
        error('No .mat files found under the provided rootDir(s).');
    end

    % --- build full paths ---
    matPaths = arrayfun(@(d) fullfile(d.folder, d.name), matsAll, 'UniformOutput', false);

    % --- load ---
    S = cell(numel(matPaths), 1);
    for k = 1:numel(matPaths)
        S{k} = load(matPaths{k});
    end

    fprintf('Loaded %d MAT files from %d root folder(s) into cell array S.\n', numel(S), numel(rootDirs));
end