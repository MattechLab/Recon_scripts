function make_slice_gif(matFile, varName, i1, i2, gifName, delay)
%MAKESLICEGIF  Create an animated GIF from abs(<volume>) slices.
%
%   makeSliceGif(matFile, varName, i1, i2)
%   makeSliceGif(matFile, varName, i1, i2, gifName, delay)
%
%   INPUTS
%     maxFile  – path to the .mat (MAT-file) that contains the 3-D array
%     varName  – name of the variable inside the file (e.g. 'x')
%     i1,i2    – first and last slice to show (along the 3rd dim)
%     gifName  – (opt) output file, default = '<varName>_slices.gif'
%     delay    – (opt) frame delay in seconds, default = 0.10 s
%
%   The script converts each slice to 8-bit grayscale, scales every frame
%   to its own full dynamic range, and loops forever.
%
%   Example
%     makeSliceGif('volume.max','x',30,80);
% ---------------- load volume ----------------------
S = load(matFile, varName);                     % assumes .mat is a MAT-file
vol = abs(S.(varName));                         % magnitude
gifFolder = fileparts(matFile);
% ---------------- default arguments ----------------
if nargin < 3 || isempty(i1)
    i1 = 1;
end
if nargin < 4 || isempty(i2)
    i2 = size(vol,3);
end
if nargin < 5 || isempty(gifName)
    gifName = [varName '_slices.gif'];
end
gifPath = fullfile(gifFolder, gifName);
if nargin < 6 || isempty(delay)
    delay = 0.10;                              % 100 ms per frame
end

% sanity-check slice indices
if i1 < 1 || i2 > size(vol,3) || i1 >= i2
    error('Slice indices out of range.');
end

% ---------------- write animated GIF --------------
for k = i1:i2
    frame = vol(:,:,k);
    frame = frame - min(frame(:));              % zero-baseline
    if max(frame(:)) > 0                        % avoid divide-by-zero
        frame = frame / max(frame(:));          % 0…1
    end
    frame8 = uint8(frame * 255);                % 8-bit image
    [imind, cmap] = gray2ind(frame8, 256);      % indexed + colormap

    if k == i1                                   % first frame → create
        imwrite(imind, cmap, gifPath, ...
                'gif', 'LoopCount', inf, 'DelayTime', delay);
    else                                         % subsequent → append
        imwrite(imind, cmap, gifPath, ...
                'gif', 'WriteMode', 'append', 'DelayTime', delay);
    end
end

fprintf('GIF written to %s (%d frames, %.0f ms/frame)\n', ...
        gifPath, i2-i1+1, delay*1000);

end