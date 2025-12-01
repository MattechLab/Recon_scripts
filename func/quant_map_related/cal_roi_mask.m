function cal_roi_mask(imageSlice, roiShape, SelectBack, CalSNR, note_suffix)
    % imageSlice: 2D matrix (e.g., one MRI slice)
   if CalSNR
       SelectBack = 1;
       warning('SelectBack should be 1 for SNR calculation!')
   end
   fprintf('select ROI!')
   [roi_values, maskROI] = select_ROI(imageSlice, roiShape);
   maskName =  strcat('maskROI_', note_suffix);

   assignin('base',maskName, maskROI);  % Optional: export to workspace
   assignin('base', 'roi_values', roi_values);  % Optional: export to workspace
   if SelectBack
       fprintf('select background!')
       [bg_values, maskBg] = select_ROI(imageSlice, 'rect');
       assignin('base', 'maskBg', maskBg);  % Optional: export to workspace
       fprintf('The background mask maskBg has been saved to workspace! \n')
       assignin('base', 'bg_values', bg_values);  % Optional: export to workspace
       fprintf('The background mean value bg_values has been saved to workspace! \n')
   end
   
   if SelectBack && CalSNR
      snr_estimate = calSNR(roi_values, bg_values);
      assignin('base', 'snr_estimate', snr_estimate);  % Optional: export to workspace
      fprintf('The SNR snr_estimate %f has been saved to workspace!', snr_estimate);
   end 
    
end
