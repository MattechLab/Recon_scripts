function [diff_img]=diff_vol(img1,img2)
    img1_s = norm_image(img1);
    img2_s = norm_image(img2);
    diff_img = img1_s-img2_s;
    disp(max(diff_img(:)))
    disp(min(diff_img(:)))
end