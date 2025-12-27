load(['/Users/cag/Documents/Dataset/recon_results/251120_card/output/' ...
    'MT_monalisa/carMask2/x_nIter20_delta_.mat']);

%%
x_mona = x;
bmImage(x_mona);
%%

x_trans = x_mona;
for idx = 1: size(x_mona,1)
    x_sag{idx} = permute(x_mona{idx}, [3,1,2]);
    x_cor{idx} = permute(x_mona{idx}, [3,2,1]);
end
bmImage(x_sag);
bmImage(x_cor);
%% sagittal 61 53
sl = 61;
for idx = 1: size(x,1)
    x_sag_flow(:,:,idx) = x_sag{idx}(:,:,sl);
end
x_sag_flow = norm_image(x_sag_flow);
bmImage(x_sag_flow)
matPath = ['//Users/cag/Documents/Dataset/recon_results/251120_card/output/MT_monalisa/carMask2/' ...
     'x_sag_flow_' num2str(sl) '.mat'];
save(matPath, 'x_sag_flow', '-v7.3');

make_slice_gif(matPath, 0.1)

%% trans 41 38
sl = 61;
for idx = 1: size(x,1)
    x_trans_flow(:,:,idx) = x_trans{idx}(:,:,sl);
end
x_trans_flow = norm_image(x_trans_flow);
bmImage(x_trans_flow)

matPath = ['//Users/cag/Documents/Dataset/recon_results/251120_card/output/MT_monalisa/carMask2/' ...
     'x_trans_flow_' num2str(sl) '.mat'];
save(matPath, 'x_trans_flow', '-v7.3');

make_slice_gif(matPath, 0.1)

%% coronal view with slice 48 58

sl = 58;
for idx = 1: size(x,1)
    x_cor_flow(:,:,idx) = x_cor{idx}(:,:,sl);
end
x_cor_flow = norm_image(x_cor_flow);
bmImage(x_cor_flow);
matPath = ['//Users/cag/Documents/Dataset/recon_results/251120_card/output/MT_monalisa/carMask2/' ...
     'x_cor_flow_' num2str(sl) '.mat'];
save(matPath, 'x_cor_flow', '-v7.3');

make_slice_gif(matPath, 0.1);