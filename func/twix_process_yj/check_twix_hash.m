%% Yiwei Jia July 14 2025
% The script is specifically used for analyzing Twix 

%%
clc; 
addpath(genpath('/Users/cag/Documents/forclone/mapVBVD_Jaime'));
raw_data = ['/Users/cag/Documents/Dataset/datasets/250905/' ...
    'meas_MID00347_FID55401_Yann_seq_vx0p5_fov60.dat'];
%meas_MID00157_FID314156_JB_LIBRE2p2_a8_woPERewinder
% meas_MID00159_FID314158_t1w_swap_1.dat
twix = mapVBVD_JB(raw_data);
%% 
seqHash_twix = twix{1,1}.hdr.Dicom.tSequenceVariant;

if length(seqHash_twix)==32
    fprintf(['raw data contain pulseq-file signature ' seqHash_twix '\n']);
end
%%
seqFile = ['/Users/cag/Documents/Dataset/datasets/250905' ...
    '/gre_rad_SmallT2star.seq'];

% Read the entire content of the .seq file
raw = fileread(seqFile);

% Find the position of the '[SIGNATURE]' section
sigPos = strfind(raw, '[SIGNATURE]');

if ~isempty(sigPos)
    % Exclude the '[SIGNATURE]' section and the preceding newline
    raw = raw(1:sigPos(1)-2);
end

% Create a MessageDigest object for MD5
md = java.security.MessageDigest.getInstance('MD5');

% Update the digest with the content
md.update(uint8(raw));

% Compute the hash
hash = md.digest();

% Convert the hash to a hexadecimal string
hash_hex = dec2hex(typecast(hash, 'uint8'))';
hash_str = lower(reshape(hash_hex, 1, []));

% Display the recalculated hash
disp(['Recalculated MD5 hash: ', hash_str]);