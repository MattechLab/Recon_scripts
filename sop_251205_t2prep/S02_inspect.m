% check 120
check_120 = 0;
check_240 = 1;
%%
if check_120
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub001/output/mask_40_old_120/xrms.mat')
    x1 = norm_image(xrms);
    
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub002/output/mask_40_crusher_120/xrms.mat')
    x2 = norm_image(xrms);
    
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub003/output/mask_50_crusher_120/xrms.mat')
    x3 = norm_image(xrms);
    %
    
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub004/output/mask_40_2nd/xrms.mat')
    x4 = norm_image(xrms);
    
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub005/output/mask_40_crusher/xrms.mat')
    x5 = norm_image(xrms);
    
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub006/output/mask_50_crusher/xrms.mat')
    x6 = norm_image(xrms);
    
    %
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub007/output/mask_40_long_old/xrms.mat')
    x7 = norm_image(xrms);
     load('/Users/cag/Documents/Dataset/recon_results/251205/Sub008/output/mask_60_old/xrms.mat')
    x8 = norm_image(xrms);
    %
    bmImage(cat(2,x1,x4))
    bmImage(cat(2,x2,x5))
    bmImage(cat(2,x3,x6))
    %
    bmImage(cat(2,x4,x5,x6,x7,x8))
    x_cat = cat(2,x4,x5,x6,x7,x8);
    %
    make_slice_gif('/Users/cag/Documents/Dataset/recon_results/251205/x45678.mat', 0.2, 50, 75);
    %

end


%%
if check_240
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub001/output/mask_40_old/xrms.mat');
    x1 = norm_image(xrms);
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub002/output/mask_40_crusher/xrms.mat')
    x2 = norm_image(xrms);
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub003/output/mask_50_crusher/xrms.mat')
    x3 = norm_image(xrms);
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub004/output/mask_40_2nd_240/xrms.mat');
    x4 = norm_image(xrms);
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub005/output/mask_40_crusher_240/xrms.mat')
    x5 = norm_image(xrms);
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub006/output/mask_50_crusher_240/xrms.mat')
    x6 = norm_image(xrms);
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub007/output/mask_40_long_old_240/xrms.mat')
    x7 = norm_image(xrms);
    load('/Users/cag/Documents/Dataset/recon_results/251205/Sub008/output/mask_60_old_240/xrms.mat')
    x8 = norm_image(xrms);

    x_cat_1 = cat(2,x1,x2, x3);
    bmImage(x_cat_1)  
    x_cat_240 = cat(2,x4,x5,x6,x7,x8);
    bmImage(x_cat_240)  
end