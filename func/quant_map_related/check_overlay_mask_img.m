function check_overlay_mask_img(mask, imageSlice)
    % Show the mask overlay
    figure;
    imshow(imageSlice, [], 'InitialMagnification', 'fit'); hold on;
    visboundaries(mask, 'Color', 'r');
    title('Selected ROI Overlay');

end