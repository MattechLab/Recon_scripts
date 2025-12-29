% Analyze the mathilda image
load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00359_recon/T1_LIBRE_Binning/' ...
    'subject_MID00359_mask_clean_0.02/output/eMask_win3_th0.90_test/x0_480.mat'])
mid00359_0p02_win3_th0p9 = x0{1};%515.44

load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00359_recon/T1_LIBRE_Binning/' ...
    'subject_MID00359_mask_clean_0.3/output/eMask_win3_th0.90_test/x0_480.mat'])
mid00359_0p3_win3_th0p9 = x0{1}; %1.74

load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00359_recon/T1_LIBRE_Binning/' ...
    'subject_MID00359_mask_clean_0.05/output/eMask_win3_th0.90_test/x0_480.mat'])
mid00359_0p05_win3_th0p9 = x0{1}; %R=13.09

load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00359_recon/T1_LIBRE_Binning/' ...
    'subject_MID00359_mask_clean_0.5/output/eMask_win3_th0.90_test/x0_480.mat'])
mid00359_0p5_win3_th0p9 = x0{1}; %R=1.72

load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00359_recon/T1_LIBRE_Binning/' ...
    'subject_MID00359_mask_clean_0.08/output/eMask_win3_th0.90_test/x0_480.mat'])
mid00359_0p08_win3_th0p9 = x0{1}; %R=5.02

load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00359_recon/T1_LIBRE_Binning/' ...
    'subject_MID00359_mask_clean_0.15/output/eMask_win3_th0.90_test/x0_480.mat'])
mid00359_0p15_win3_th0p9 = x0{1}; % R=2.29

accR_list = [1.72, 1.74, 2.29, 5.02, 13.09, 515.44];
x0_list = {mid00359_0p5_win3_th0p9, mid00359_0p3_win3_th0p9, mid00359_0p15_win3_th0p9, ...
    mid00359_0p08_win3_th0p9, mid00359_0p05_win3_th0p9, mid00359_0p02_win3_th0p9};

%%
bmImage(cat(2, x0_list))

%%

% 0p1...

% 0p3---
load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00414_recon/T1_LIBRE_Binning/' ...
    'subject_MID00414_mask_clean_0.3/output/eMask_win3_th0/x0_480.mat'])
mid00414_0p3_win3_th0p9=x0{1};
% R=2.80

% 0p5---
load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00414_recon/T1_LIBRE_Binning/' ...
    'subject_MID00414_mask_clean_0.5/output/eMask_win3_th0/x0_480.mat'])
mid00414_0p5_win3_th0p9=x0{1};
 % R=2.52

% 0p08---
load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00414_recon/T1_LIBRE_Binning/' ...
    'subject_MID00414_mask_clean_0.08/output/eMask_win3_th0/x0_480.mat'])
mid00414_0p08_win3_th0p9=x0{1};
% R=11.32

% 0p13...

% 0p15---
load(['/mnt/filer01/MatTechLab/yiwei.jia/recon_results/251219/MID00414_recon/T1_LIBRE_Binning/' ...
    'subject_MID00414_mask_clean_0.15/output/eMask_win3_th0/x0_480.mat'])
mid00414_0p15_win3_th0p9=x0{1};
% R=4.54


accR_list = [2.52, 2.80, 4.54, 11.32];
x0_list = {mid00414_0p5_win3_th0p9, mid00414_0p3_win3_th0p9, mid00414_0p15_win3_th0p9, ...
    mid00414_0p08_win3_th0p9};
%%
bmImage(x0_list);