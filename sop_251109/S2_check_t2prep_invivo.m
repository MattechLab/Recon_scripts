load('/Users/cag/Documents/Dataset/recon_results/251109/t2prep_invivo/Sub001/T1_LIBRE_woBinning/output/pq_wurst_40_321p18/xrms.mat');
x1_short = norm_image(xrms);
load('/Users/cag/Documents/Dataset/recon_results/251109/t2prep_invivo/Sub002/T1_LIBRE_woBinning/output/mask_pq_wurst_40/xrms.mat')
x2_long = norm_image(xrms);
%%
% bmImage(cat(2, x1_short, x2_long))
x_t2prep = cat(2, x1_short, x2_long);
x_t2_path = '/Users/cag/Documents/Dataset/recon_results/251109/t2prep_invivo/x_t2prep.mat';
save(x_t2_path, 'x_t2prep', '-v7.3');
%%
x_t2prep_diff = x1_short - x2_long;
x_path = '/Users/cag/Documents/Dataset/recon_results/251109/t2prep_invivo/x_t2prep_diff.mat';
save(x_path, 'x_t2prep_diff', '-v7.3');