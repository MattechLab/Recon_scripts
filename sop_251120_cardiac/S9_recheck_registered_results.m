%% load the data 
load(['/Users/cag/Documents/Dataset/recon_results/251120_card/output/' ...
     'card_th10_low0.9_high1.1/r_nifti/x_r.mat']);
%%
bmImage(x);
x_trans = x;
for idx = 1: size(x,1)
    x_sag{idx} = permute(x{idx}, [3,1,2]);
    x_cor{idx} = permute(x{idx}, [3,2,1]);
end
bmImage(x_sag);
bmImage(x_cor);
%% Prepare the same slice across bins for gif demonstration
% coronal 40
for idx = 1: size(x,1)
    x_cor_flow(:,:,idx) = x_cor{idx}(:,:,40);
end
x_cor_flow = norm_image(x_cor_flow);
bmImage(x_cor_flow)
matPath = ['/Users/cag/Documents/Dataset/recon_results/251120_card/output/' ...
     'card_th10_low0.9_high1.1/r_nifti/x_cor_flow_40.mat'];
save(matPath, 'x_cor_flow', '-v7.3');
%
x_cor_flow_clip = norm_image(x_cor_flow, [0.15,1]);
bmImage(x_cor_flow_clip)
matPath = ['/Users/cag/Documents/Dataset/recon_results/251120_card/output/' ...
     'card_th10_low0.9_high1.1/r_nifti/x_cor_flow_clip_40.mat'];
save(matPath, 'x_cor_flow_clip', '-v7.3');
% clipping to [0.15,1]

%% sagittal 47 49

for idx = 1: size(x,1)
    x_sag_flow(:,:,idx) = x_sag{idx}(:,:,47);
end
x_sag_flow = norm_image(x_sag_flow);
bmImage(x_sag_flow)
matPath = ['/Users/cag/Documents/Dataset/recon_results/251120_card/output/' ...
     'card_th10_low0.9_high1.1/r_nifti/x_sag_flow_47.mat'];
save(matPath, 'x_sag_flow', '-v7.3');

%
x_sag_flow_clip = norm_image(x_sag_flow, [0.15,1]);
bmImage(x_sag_flow_clip)
matPath = ['/Users/cag/Documents/Dataset/recon_results/251120_card/output/' ...
     'card_th10_low0.9_high1.1/r_nifti/x_sag_flow_clip_47.mat'];
save(matPath, 'x_sag_flow_clip', '-v7.3');
% clipping to [0.15,1]

%% trans 57? honestly I didn't find a good slice
for idx = 1: size(x,1)
    x_trans_flow(:,:,idx) = x_trans{idx}(:,:,57);
end
x_trans_flow = norm_image(x_trans_flow);
bmImage(x_trans_flow)
matPath = ['/Users/cag/Documents/Dataset/recon_results/251120_card/output/' ...
     'card_th10_low0.9_high1.1/r_nifti/x_trans_flow_57.mat'];
save(matPath, 'x_trans_flow', '-v7.3');

%
x_trans_flow_clip = norm_image(x_trans_flow, [0.15,1]);
bmImage(x_trans_flow_clip)
matPath = ['/Users/cag/Documents/Dataset/recon_results/251120_card/output/' ...
     'card_th10_low0.9_high1.1/r_nifti/x_trans_flow_clip_57.mat'];
save(matPath, 'x_trans_flow_clip', '-v7.3');
% clipping to [0.15,1]