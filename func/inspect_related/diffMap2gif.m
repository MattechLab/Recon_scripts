function diffMap2gif(vol, slices, gifName, gifFolder, varargin)
%DIFFMAP2GIF  Create an animated GIF from 3-D difference maps.
%
% diffMap2gif(VOL, SLICES, GIFNAME, GIFFOLDER) displays VOL(:,:,k) for each
% slice index in SLICES and writes the frames to  <GIFFOLDER/GIFNAME>.
% SLICES can be a vector (e.g. 1:60) or a two-element range [i1 i2].
%
% Name-value overrides:
%   'Colormap'   – Nx3 RGB array or colormap name   (default 'redblue')
%   'DelayTime'  – seconds per frame                (default 0.10)
%   'LoopCount'  – GIF loop count (Inf = forever)   (default Inf)
%   'CLim'       – [cmin cmax] | 'sym' | 'auto'     (default 'sym')
%                  'sym' maps ±max(|VOL|)  →  blue/white/red
%                  'auto' rescales every frame independently
%
% Example
%   gifFile = fullfile('C:\tmp','diff.gif');
%   diffMap2gif(diffVol, 30:90, 'diff.gif', 'C:\tmp', ...
%               'Colormap','redblue', 'DelayTime',0.05);

% ------------------------------------------------------------------------
%  Input parsing
% ------------------------------------------------------------------------
p = inputParser;
p.addRequired ('vol',     @(x)isnumeric(x)&&ndims(x)==3);
p.addRequired ('slices',  @(x)isnumeric(x)&&isvector(x));
p.addRequired ('gifName', @(x)ischar(x)||isstring(x));
p.addRequired ('gifFolder',@(x)ischar(x)||isstring(x));

p.addParameter('Colormap',  'redblue');
p.addParameter('DelayTime', 0.10, @(x)isnumeric(x)&&x>0);
p.addParameter('LoopCount', Inf,   @(x)isnumeric(x)&&x>=0);
p.addParameter('CLim',      'sym');   % 'sym' | 'auto' | [cmin cmax]
p.parse(vol,slices,gifName,gifFolder,varargin{:});
opt = p.Results;

vol       = double(opt.vol);
slices    = unique(round(opt.slices));
gifPath   = fullfile(opt.gifFolder, char(opt.gifName));

% ------------------------------------------------------------------------
%  Decide colour limits & scaling function
% ------------------------------------------------------------------------
switch lower(string(opt.CLim))
    case "sym"
        clim      = max(abs(vol(:)));
        scaleFun  = @(x)(x+clim)/(2*clim);        % −clim→0  +clim→1
    case "auto"
        scaleFun  = @(x)(x-min(x(:))) ./ (max(x(:))-min(x(:))+eps);
    otherwise   % user supplied [cmin cmax]
        clim      = opt.CLim;
        scaleFun  = @(x)(x-clim(1)) / (clim(2)-clim(1));
end

% ------------------------------------------------------------------------
%  Resolve colormap
% ------------------------------------------------------------------------
if ischar(opt.Colormap)||isstring(opt.Colormap)
    cmap = feval(opt.Colormap,256);      % e.g. 'redblue','turbo'
else
    cmap = opt.Colormap;
end
if size(cmap,2)==4                       % drop alpha if present
    cmap = cmap(:,1:3);
end
if size(cmap,2)~=3
    error('Colormap must be Nx3 RGB.');
end

% ------------------------------------------------------------------------
%  Write frames
% ------------------------------------------------------------------------
for n = 1:numel(slices)
    k      = slices(n);
    frame  = scaleFun(vol(:,:,k));
    frame  = min(max(frame,0),1);              % clip to 0-1
    indImg = uint8(round(frame*255));          % indexed 0-255

    if n==1
        imwrite(indImg, cmap, gifPath, 'gif', ...
            'LoopCount', opt.LoopCount, 'DelayTime', opt.DelayTime);
    else
        imwrite(indImg, cmap, gifPath, 'gif', 'WriteMode','append', ...
            'DelayTime', opt.DelayTime);
    end
end

fprintf('GIF written: %s  (%d slice%s, %.0f ms / frame)\n', ...
        gifPath, numel(slices), plural(numel(slices)), opt.DelayTime*1000);
end
% ------------------------------------------------------------------------
%  small helper for plural-s
% ------------------------------------------------------------------------
function s = plural(n)
s = char(double('s')*(n~=1));   % 's' if n≠1, else ''
end