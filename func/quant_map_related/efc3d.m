function efc = efc3d(vol, mask)
% EFC3D  Entropy-Focus Criterion (MRIQC 公式)
%
%   efc = EFC3D(vol)          % 整个体积
%   efc = EFC3D(vol, mask)    % 仅在 mask==true 的体素上计算
%
% 返回值范围约 0–1；越低表示越少鬼影/模糊。

% -------------------------------------------------------------------------
if nargin < 2 || isempty(mask)
    mask = true(size(vol));
else
    mask = logical(mask);
end

v = abs(vol(mask));          % 只看掩膜内幅度
v = v(~isnan(v));            % 去掉 NaN
n = numel(v);                % 有效体素数
if n == 0                    % 空掩膜
    efc = NaN; return
end

b_max = sqrt(sum(v.^2));     % (1) 图像总能量的 L2 范数
if b_max == 0                % 全零图像
    efc = 0;  return
end

a = v / b_max;               % (2) 归一化强度 ∈ (0,1]
small = 1e-16;               %   防 log(0)
num  = sum(a .* log(a + small));  % (3) 未取负号，保持与 MRIQC 一致

% (4) 归一化以便不同体素数可比
efc_max = n * (1/sqrt(n)) * log(1/sqrt(n));   % < 0
efc     = num / efc_max;                      % 0–1

end