function snr_estimate = calSNR(roi_values, bg_values)
        snr_estimate = mean(roi_values) / std(bg_values);
       fprintf('Estimated SNR in ROI: %.2f\n', snr_estimate);
end