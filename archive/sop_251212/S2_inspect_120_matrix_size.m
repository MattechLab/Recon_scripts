% /Users/cag/Documents/forclone/Recon_scripts/sop_user_select/
load('/Users/cag/Documents/Dataset/recon_results/251212/MID00413_recon/xrms_120.mat');
x_wfoam = norm_image(xrms);
load('/Users/cag/Documents/Dataset/recon_results/251212/MID00428_recon/xrms_120.mat');
x1 = norm_image(xrms);
load('/Users/cag/Documents/Dataset/recon_results/251212/MID00440_recon/xrms_120.mat')
x2 = norm_image(xrms);
%%
x_cat = cat(2, x_wfoam,x1,x2);
bmImage(x_cat);
%%
x_sag = {flip(permute(x_wfoam, [3,1,2]),1), flip(permute(x1, [3,1,2]),1), flip(permute(x2, [3,1,2]),1)};
bmImage(cat(2, x_sag{1}, x_sag{2}, x_sag{3}));

%%

 load('/Users/cag/Documents/Dataset/recon_results/251212/libre_std_xrms.mat')
 bmImage(norm_image(xrms))
%%
 load('/Users/cag/Documents/Dataset/recon_results/251212/MID00428_recon/output/x0.mat')
xsess1 = norm_image(x0{1});


load('/Users/cag/Documents/Dataset/recon_results/251212/MID00440_recon/output/x0.mat')
xsess2 = norm_image(x0{1});
bmImage(cat(2, xsess1,xsess2))
 %%
load('/Users/cag/Documents/Dataset/recon_results/251208/MID00362_recon/output/xrms.mat')
x_wET_woFoam = norm_image(xrms);
load('/Users/cag/Documents/Dataset/recon_results/251208/MID00542_recon/output/xrms.mat')
x_wFoam =norm_image(xrms);
bmImage(cat(2, x_wET_woFoam, x_wFoam))