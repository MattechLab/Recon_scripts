function snr_new = merge_idx(snr_all, mergeIdx)
% ----- inputs -----------------------------------------------------------

how      = @mean;         % combine rule:  @mean  |  @sum  |  @max  | …

% ----- 1. compute the merged column ------------------------------------
mergedCol = how(snr_all(:, mergeIdx), 2);   % 5 × 1  (slice-wise mean here)

% ----- 2. build the new matrix with one fewer ROI ----------------------
keepCols  = setdiff(1:size(snr_all,2), mergeIdx);  % all but 2 & 4
% Put the merged column right where the first ROI (col-2) used to be
snr_new   = [ snr_all(:, keepCols(keepCols < mergeIdx(1))), ...
              mergedCol, ...
              snr_all(:, keepCols(keepCols > mergeIdx(1))) ];