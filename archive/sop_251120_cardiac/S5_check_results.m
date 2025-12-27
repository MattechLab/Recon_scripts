load(['/Users/cag/Documents/Dataset/recon_results/251120_card/output/' ...
    'card_th10_low0.9_high1.1/x_nIter15_delta_0.100.mat'])

bmImage(x);

x_trans = x;
for idx = 1: size(x,1)
    x_sag{idx} = permute(x{idx}, [3,1,2]);
    x_cor{idx} = permute(x{idx}, [3,2,1]);
end
bmImage(x_sag);
bmImage(x_cor);

