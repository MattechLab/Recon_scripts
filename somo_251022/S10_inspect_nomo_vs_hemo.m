load(['/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/Sub001/' ...
    'T1_LIBRE_woBinning/output/mask_nobin/x0_C.mat']);
x0_raw = norm_image(x0);
clear x0;
load('/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/Sub001/T1_LIBRE_Binning/output/clean_sequentialBinning_win15.0/x0.mat')
x0_cl = norm_image(x0{1});



bmImage(cat(2,x0_raw,x0_cl));
