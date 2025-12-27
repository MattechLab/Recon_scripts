
function [C] = estimateCoilSens_Calib_adjCoilSens(acquisitionParams, flipCalibData_flag, coilSenseFile, measureFile, inverse_shift_flag)
% Author: Bastien Milani
% reorganized by: Yiwei Jia, Matteo Tagliabue
% estimateCoilSens_Calib_adjCoilSens
%
% Estimate and adjust coil sensitivity maps from calibration/adjCoilsens data.
% 
% This function computes the coil sensitivity maps (C) using the provided
% acquisition parameters and raw measurement data. Optionally, it can flip
% the calibration data, apply inverse FFT shifts, and generate the final
% sensitivity map with low resolution (eg. [48,48,48])
% -------------------------------------------------------------------------
% INPUTS:
%
% acquisitionParams         - bmMriAcquisitionParam struct containing acquisition-specific parameters
%                             (e.g., matrix size, FOV, number of channels).
% ---- Can be self-defined as below----
    % p = bmMriAcquisitionParam([]); 
    % p.name            = [];
    % p.mainFile_name   = measureFile;
    % p.imDim = 3;  p.N = 480; p.nSeg  = 22;  p.nShot = 3723;  
    % p.nLine = 81906; p.nPar  = 1; p.nLine = double([]);
    % p.nPt  = double([]); p.raw_N_u = [Matrix_size, Matrix_size, Matrix_size];
    % p.raw_dK_u  = [1, 1, 1]./reconFov; p.nCh    = 44; p.nEcho = 1; 
    % p.selfNav_flag = true; p.nShot_off = 15; p.roosk_flag = false;
    % p.FoV = [reconFov, reconFov, reconFov]; % This is the full FOV not the half FOV
    % p.traj_type       = 'full_radial3_phylotaxis'; % This sets the trajectory used
    % p.refresh; % Fill in missing parameters that can be deduced from existing ones.
% ----finish define the bmMriAcquisitionParam ----
% 
% flipCalibData_flag        - Boolean flag (true/false).
%                             If true, calibration data is flipped along a
%                             specified axis before sensitivity estimation
%                             (e.g., for alignment correction).
%                              Should retrospectively play with this flag
% coilSenseFile             - (String or empty).
%                             If .dat file path is provided, the function
%                             will attempt to load existing coil sensitivity
%                             maps from this file. 
%
% measureFile               - String path to the main raw measurement
%                             file used for calibration and main data (e.g., from scanner).
%
% inverse_shift_flag        - Boolean flag (true/false).
%                             If true, applies inverse shift 
%                             This flag should be played with flipCalibData_flag
%
% -------------------------------------------------------------------------
% OUTPUTS:
%
% C                         - 3D complex array representing the coil
%                             sensitivity maps. Size typically:
%                             [48,48,48]
%
% -------------------------------------------------------------------------
% Notes:
% - Flipping and inverse shift options are useful for aligning with
%   vendor-specific coordinate conventions.
%
% -------------------------------------------------------------------------
% Dependencies:
% - Requires access to raw k-space data in `measureFile`.
%
% -------------------------------------------------------------------------



%%====READ DATA AND PREPARE PARAMS =========
nSeg            = acquisitionParams.nSeg; 
nShot           = acquisitionParams.nShot; 
N               = acquisitionParams.N; 
FoV             = acquisitionParams.FoV; 

% N                      =  480; 
% nSeg                = 22; 
% nShot               = 1000; 
dK_n                = 1/FoV; 
nCh                  = acquisitionParams.nCh; 
selfNav_flag     = acquisitionParams.selfNav_flag;

nShot_off          = 0; %For some reason it must be 0 here for the following shift check
reg_N_u         = [48, 48, 48];
ve_max_factor   = 5; 



cs_map_size = [1,1,1]*48; % 


tObjCellar                          = mapVBVD_JH_calibScan(coilSenseFile);
[ind_mainScan, ind_calibScan]       = bmCalibScan_find_tObjCell_indices(tObjCellar); 
tObj_calibScan                      = tObjCellar{ind_calibScan}; 

tObjCellar      = mapVBVD_JH_for_monalisa(measureFile);
if iscell(tObjCellar)
    tObj_mainScan   = tObjCellar{end};
else
    tObj_mainScan   = tObjCellar;
end




%%====Start SENSITIVY MAP ESTIMATION=========

data_body   = bmCalibScan_extractCalibData(tObj_calibScan.calibScan_body, flipCalibData_flag);
data_array  = bmCalibScan_extractCalibData(tObj_calibScan.calibScan_array, flipCalibData_flag);

% Calibration FOV and resolution
calib_phase_FoV = tObj_calibScan.hdr.Config.PhaseFoV;
calib_read_FoV  = tObj_calibScan.hdr.Config.ReadFoV;
calib_FoV       = [calib_phase_FoV, calib_phase_FoV, calib_read_FoV];
calib_N_u       = [size(data_body,1), size(data_body,2), size(data_body,3)];
calib_dK_u      = 1 ./ calib_FoV;

% REGISTRATION (ALIGN CALIBRATION TO MAIN SCAN)
y               = tObj_mainScan.image.unsorted();
y               = permute(y, [2, 1, 3]); 
y               = reshape(y, [], N, nSeg, nShot); 
y(:, :, 1, :)   = []; 

t               = bmTraj_fullRadial3_phyllotaxis_lineAssym2(N, ...
                                                            nSeg, ...
                                                            nShot, ...
                                                            dK_n, ...
                                                            selfNav_flag, ...
                                                            nShot_off);

ve = bmVolumeElement_voronoi_full_radial3(t);
ve = min(ve, ve_max_factor*prod(calib_dK_u));

x_reg = bmMathilda(y, t, ve, [], reg_N_u, reg_N_u, calib_dK_u);
x_reg = bmRMS(x_reg, reg_N_u); 
x_reg = x_reg/mean(abs(x_reg(:))); 


a_reg = bmIDF3(data_array, calib_N_u, calib_dK_u);
a_reg = bmImResize(a_reg,  calib_N_u, reg_N_u); 
a_reg = bmRMS(a_reg, reg_N_u); 
a_reg = a_reg/mean(abs(a_reg(:))); 

b_reg = bmIDF3(data_body, calib_N_u, calib_dK_u);
b_reg = bmImResize(b_reg, calib_N_u, reg_N_u); 
b_reg = bmRMS(b_reg, reg_N_u); 
b_reg = b_reg/mean(abs(b_reg(:)));  

temp_im = cat(4, (a_reg+b_reg)/2, x_reg); 
temp_im = min(temp_im, mean(temp_im(:))*6); 
bmImage(temp_im)

myShift = bmCalibScan_find_shift( tObj_calibScan, tObj_mainScan, inverse_shift_flag);
a_test = bmCalibScan_imShift(a_reg, myShift, reg_N_u, calib_dK_u); 
b_test = bmCalibScan_imShift(b_reg, myShift, reg_N_u, calib_dK_u); 

checkImage = cat(4, (a_test+b_test)/2, x_reg); 
bmImage(checkImage)
disp('Test registration shift!')

% FINAL CALIBRATION IMAGES (RESAMPLED TO FINAL GRID)
final_N_u       = [48, 48, 48];
final_dK_u = [1, 1, 1] / FoV;


[imCalib_array, imCalib_body] = bmCalibScan_imCalib_final(  data_array, data_body, ...
                                                        myShift, ...
                                                        calib_N_u, calib_dK_u, ...
                                                        final_N_u, final_dK_u); 

imCalib_array(isnan(imCalib_array)) =0;
imCalib_body(isnan(imCalib_body)) =0;

% ==========MASK CREATION====================
display_flag = true;
% Empty limits (use defaults inside function)
x_min = []; x_max = [];
y_min = []; y_max = [];
z_min = []; z_max = [];
% Thresholds
th_RMS = 8;
th_MIP = 8;
% Morphological operations (disabled if empty)
close_size = [];
open_size  = [];
% Generate mask

m = bmCoilSense_prescan_mask( imCalib_body, cs_map_size, ...
    x_min, x_max, ...
   y_min, y_max, ...
   z_min, z_max, ...
   th_RMS, th_MIP, ...
   close_size, open_size, ...
   display_flag);


% Loop until user is satisfied
while false
    % Generate mask
    m = bmCoilSense_prescan_mask( ...
        imCalib_body, cs_map_size, ...
        x_min, x_max, ...
        y_min, y_max, ...
        z_min, z_max, ...
        th_RMS, th_MIP, ...
        close_size, open_size, ...
        display_flag);

    % Ask user for feedback
    user_input = input('Are you satisfied with the mask? (y/n): ', 's');

    if strcmpi(user_input, 'y')
        disp('Mask accepted.');
        break;
    else
        disp('Please enter new x/y/z limits (leave empty for default):');

        % Ask user for new limits (blank = [])
        x_min = input('x_min = ');
        x_max = input('x_max = ');
        y_min = input('y_min = ');
        y_max = input('y_max = ');
        z_min = input('z_min = ');
        z_max = input('z_max = ');
    end
end
%m = bmCoilSense_manualCleanMask(m);
C = bmCoilSense_prescan_coilSense(imCalib_body, imCalib_array, m, cs_map_size);
% C =bmImResize(C,cs_map_size,N_u);

end



 