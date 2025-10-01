function [img1_scaled] = norm_image(img1)
    img1 = double(abs(img1));
    % Scale img1 to [0, 1]
    img1_scaled = (img1 - min(img1(:))) / (max(img1(:)) - min(img1(:)));
    
    disp('Scaling Done')
end
