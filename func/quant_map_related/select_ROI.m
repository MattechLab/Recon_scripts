function [roi_values, mask]= select_ROI(imageSlice, shapeInfo)
    figure;
    imshow(imageSlice, [], 'InitialMagnification', 'fit');

    if strcmp(shapeInfo, 'circle')
        title('Draw a circle ROI. Double-click to confirm.'); 
        % Let user select circle ROI
        h = imellipse(gca, []);
    elseif strcmp(shapeInfo, 'rect')
        title('Draw a rect ROI. Double-click to confirm.'); 
        % Let user select rectangular background
        h = imrect(gca, []);
    elseif strcmp(shapeInfo, 'poly')
        title('Draw a poly ROI. Double-click to confirm.'); 
        % Let user select rectangular background
        h = impoly(gca, []);
    end

    % Create binary mask from the selected region
    position = wait(h);  % Wait for user to finish drawing
    mask = createMask(h); 

    check_overlay_mask_img(mask, imageSlice);
    roi_values = imageSlice(mask);

end

