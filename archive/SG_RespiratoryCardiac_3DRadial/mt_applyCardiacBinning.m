function [DensityCompen3D_bin, Traj3D_bin, kdata_raw_bin] = mt_applyCardiacBinning(DensityCompen3D, Traj3D,kdata_raw,heart_binning,nrCardThreshold)
%
% Syntax:       [DensityCompen3D_bin, Traj3D_bin, kdata_raw_bin] = applyCardiacBinning(DensityCompen3D, Traj3D, kdata_raw, heart_binning, nrCardThreshold)
%
% Inputs:       DensityCompen3D:   3D density compensation function [1, nx].
%               Traj3D:            3D k-space trajectory [nx, ntviews, 3].
%               kdata_raw:         Raw k-space data [nx, ntviews, nc].
%               heart_binning:     Vector indicating cardiac bin assignment for each data point.
%               nrCardThreshold:   Number of cardiac bins to be used.
%
% Outputs:      DensityCompen3D_bin: Binned 3D density compensation data [1, nx, nrCardThreshold].
%               Traj3D_bin:          Binned 3D k-space trajectory [nx, ntviews,3, nrCardThreshold].
%               kdata_raw_bin:       Binned raw k-space data [nx, ntviews, nc, nrCardThreshold].
%
% Description: Applies cardiac binning to the input k-space data, trajectory, 
%              and density compensation function based on the `heart_binning` vector:
%
% Author:       Matteo Tagliabue
%               matteo.tagliabue@students.unibe.ch  
%
% Date:         Last Updated: 19.08.2024
%

%% BINNING
for i=1:nrCardThreshold

    %find all indices
    bin_indices = find(heart_binning == i);

    % add bin dimension
    DensityCompen3D_bin(:,:,i)= DensityCompen3D(:,bin_indices);
    Traj3D_bin(:,:,:,i)= Traj3D(:,bin_indices,:,:);
    kdata_raw_bin(:,:,:,i)= kdata_raw(:,bin_indices,:);

end

end