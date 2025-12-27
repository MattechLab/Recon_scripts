load('/Users/cag/Documents/Dataset/recon_results/241120_JB/Sub001/T1_LIBRE_Binning/C/C.mat')
%%
bmImage(C)

%%
% Root mean square across the channels
% Initialize an array to store sum of squared images
[nx, ny, nz, ~] = size(C);  % Get the dimensions (240,240,240)
numCoils = size(C,4);  % Number of coils (20)

sum_of_squares = zeros(nx, ny, nz, 'single');  % Preallocate in single precision

% Compute sum of squared images

for coil = 1:numCoils
    % straightforward
    % sum_of_squares = sum_of_squares + abs(x0{coil}).^2;
    % eliminate extra square-root step
    sum_of_squares = sum_of_squares + real(C(:,:,:,coil)).*conj(C(:,:,:,coil));
end

% Compute the root mean square (RMS)
crms = sqrt(sum_of_squares / numCoils);  % Normalize by the number of coils
%%
% now I need to figure out the channels which affect the eye the most
% bmImage(C)
%
for coil = 1:numCoils
    bmImage(C(:,:,12,coil))
end

%% define a mask around eye region
figure; imagesc(abs(crms(:,:,12))); axis image
title('Draw mask around the eyes');
eyeMask = roipoly;   % binary mask
eyeMaskPath = '/Users/cag/Documents/forclone/Recon_scripts/sop_check_mrtrack_local_movement/eyeMask_sl12.mat';
save(eyeMaskPath, "eyeMask");
%%
zRange = 12:36;
numCoils = size(C, 4);
eyeMask3D = repmat(eyeMask, [1 1 length(zRange)]);

rawWeights = zeros(numCoils,1);

for coil = 1:numCoils
    coilAbs = abs(C(:,:,zRange,coil));
    rawWeights(coil) = sum(coilAbs(eyeMask3D==1), 'all');
end

% normalize across coils
weights_norm = rawWeights / sum(rawWeights);

%%
[sortedW, idx] = sort(weights_norm, 'descend');

figure;
bar(weights_norm, 'LineWidth', 1.2);
xlabel('Sorted coil index');
ylabel('Weight in eye region');
title('Sorted Coil Contributions to Eye Region');
grid on;

% Print coil order
disp('Coils sorted by weight (highest to lowest):');
disp(idx(:)');
%%
numTop = 24;   % change if needed
[sortedW, idx] = sort(weights_norm, 'descend');

figure;
bar(weights_norm, 'FaceColor', [0.6 0.6 0.6]); hold on;
bar(idx(1:numTop), weights_norm(idx(1:numTop)), 'FaceColor', [0.9 0.3 0.3]);
xlabel('Coil index');
ylabel('Weight in eye region');
title('Coil Contributions (highlighting top coils)');
legend('All coils', 'Top contributors');
grid on;

%%
for select_coil = idx(1:numTop)
    bmImage(C(:,:,:,select_coil));
end

