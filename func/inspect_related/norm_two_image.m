function [img1_scaled, img2_scaled] = norm_two_image(img1,img2)
    img1 = double(abs(img1));
    img2 = double(abs(img2));
    
    % Scale img1 to [0, 1]
    img1_scaled = (img1 - min(img1(:))) / (max(img1(:)) - min(img1(:)));
    
    % Scale img2 to [0, 1]
    img2_scaled = (img2 - min(img2(:))) / (max(img2(:)) - min(img2(:)));
    disp('Scaling Done')
end