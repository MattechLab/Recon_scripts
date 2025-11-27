function [DensityCompen3D_bin, Traj3D_bin, kdata_raw_bin] = mt_applyRespiratoryBinning(DensityCompen3D, Traj3D,kdata_raw,breathing_binning,nrRespThreshold)
%
% Syntax:       [DensityCompen3D_bin, Traj3D_bin, kdata_raw_bin] = mt_applyRespiratoryBinning(DensityCompen3D, Traj3D, kdata_raw, heart_binning, nrCardThreshold)
%
% Inputs:       DensityCompen3D:   3D density compensation function [1, nx].
%               Traj3D:            3D k-space trajectory [nx, ntviews, 3].
%               kdata_raw:         Raw k-space data [nx, ntviews, nc].
%               breathing_binning: Vector indicating respiratory bin assignment for each data point.
%               nrRespThreshold:   Number of respiratory bins to be used.
%
% Outputs:      DensityCompen3D_bin: Binned 3D density compensation data [1, nx, nrCardThreshold].
%               Traj3D_bin:          Binned 3D k-space trajectory [nx, ntviews,3, nrCardThreshold].
%               kdata_raw_bin:       Binned raw k-space data [nx, ntviews, nc, nrCardThreshold].
%
% Description: Applies respiratory binning to the input k-space data, 
%              trajectory, and density compensation function based on 
%              the 'breathing_binning' vector:
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch  
%
% Date:         Last Updated: 19.08.2024
%

%% BINNING

% count #spokes in each bins
counts = accumarray(breathing_binning', 1);

% cextract smaller bins
min_c=min(counts);

% extract binns
for i=1:nrRespThreshold

    %find all indices
    bin_indices = find(breathing_binning == i);
    %cut all of same length
    bin_indices=bin_indices(1:min_c);

    % add binn dimension
    DensityCompen3D_bin(:,:,i)= DensityCompen3D(:,bin_indices);
    Traj3D_bin(:,:,:,i)= Traj3D(:,bin_indices,:,:);
    kdata_raw_bin(:,:,:,i)= kdata_raw(:,bin_indices,:);

end