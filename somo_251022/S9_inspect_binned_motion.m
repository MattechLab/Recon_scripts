load('/Users/cag/Documents/Dataset/recon_results/251022/sub1_hemo/Sub001/T1_LIBRE_Binning/output/sequentialBinning_win15.0s/x0.mat')
bmImage(x0)
%%
nFr = size(x0,1);
nSlices = size(x0{1},3);

for iFr = 1:nFr
    x0_tran(:,:,iFr) = x0{iFr}(:,:, nSlices/2);
end

%%
for iFr = 1:nFr
    x0_sag(:,:,iFr) = x0{iFr}(:,nSlices/2,:);
end
x0_sag = flip(permute(x0_sag, [2 1 3]),1);
