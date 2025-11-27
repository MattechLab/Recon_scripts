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
