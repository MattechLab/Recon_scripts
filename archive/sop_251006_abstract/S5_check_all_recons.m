dataset_label = '251006_bern_abs'; %or '251007_chuv_abs'
x_b_set={};
for subject_num = [1,2,3,4]
for datatype = [1,2,3,4]

subject_suffix = {'_ml', '_jb', '_yj',  '_phantom'};
mask_note_list{1}= 'idea_ori'; mask_note_list{2}= 'idea_ptp';
mask_note_list{3}= 'pq_ori'; mask_note_list{4}= 'pq_ptp';
mask_note = mask_note_list{datatype};

reconDir = ['/Users/cag/Documents/Dataset/recon_results/',dataset_label, ...
    '/sub', num2str(subject_num), subject_suffix(subject_num), '/'];
reconDir = [reconDir{:}];

x0Dir = [reconDir, '/T1_LIBRE_woBinning/output/mask_',mask_note,'/'];
xDir = [reconDir, '/T1_LIBRE_woBinning/output/mask_',mask_note,'/'];

nIter = 15;
delta = 1;
xPath = fullfile(xDir, sprintf('x_nIter%d_delta_%.3f.mat', nIter, delta));

x_b_set{subject_num, datatype} = load(xPath);
disp([xPath, ' is imported'])
end
end

%
x1 = cat(2, x_b_set{1,1}.x, x_b_set{1,2}.x,x_b_set{1,3}.x,x_b_set{1,4}.x);
bmImage(x1)

x2 = cat(2, x_b_set{2,1}.x, x_b_set{2,2}.x,x_b_set{2,3}.x,x_b_set{2,4}.x);
bmImage(x2)

x3 = cat(2, x_b_set{3,1}.x, x_b_set{3,2}.x,x_b_set{3,3}.x,x_b_set{3,4}.x);
bmImage(x3)

x4 = cat(2, x_b_set{4,1}.x, x_b_set{4,2}.x,x_b_set{4,3}.x,x_b_set{4,4}.x);
bmImage(x4)

%%
dataset_label = '251007_chuv_abs'; %or '251006_bern_abs'
x_c_set={};
for subject_num = [1,2,3]
for datatype = [1,2]

subject_suffix = {'_ml', '_jb', '_yj'};

mask_note_list{1}= 'pq_ori'; mask_note_list{2}= 'pq_ptp';
mask_note = mask_note_list{datatype};

reconDir = ['/Users/cag/Documents/Dataset/recon_results/',dataset_label, ...
    '/sub', num2str(subject_num), subject_suffix(subject_num), '/'];
reconDir = [reconDir{:}];

x0Dir = [reconDir, '/T1_LIBRE_woBinning/output/mask_',mask_note,'/'];
xDir = [reconDir, '/T1_LIBRE_woBinning/output/mask_',mask_note,'/'];
nIter = 15;
delta = 1;
xPath = fullfile(xDir, sprintf('x_nIter%d_delta_%.3f.mat', nIter, delta));
x_i = load(xPath);
x_c_set{subject_num, datatype} = x_i; 
x_c_set{subject_num, datatype} .x = permute(x_i.x, [2,1,3]);
disp([xPath, ' is imported'])

end
end

%
x1 = cat(2, norm_image(x_c_set{1,1}.x), norm_image(x_c_set{1,2}.x));
bmImage(x1)

x2 = cat(2, x_c_set{2,1}.x, x_c_set{2,2}.x);
bmImage(x2)

x3 = cat(2,norm_image(x_c_set{3,1}.x) , x_c_set{3,2}.x);
bmImage(x3)


%% import all the registered .mat files (with _back suffix, except ref images: bern x_pq_ptp)
dataset_label = '251006_bern_abs'; %or '251007_chuv_abs'
x_b_set_back={};
for subject_num = [1,2,3]
    for datatype = [1,2,3,4]
        subject_suffix = {'_ml', '_jb', '_yj',  '_phantom'};
        mat_note_list{1}= 'r_x_idea_ori_back.mat'; mat_note_list{2}= 'r_x_idea_ptp_back.mat';
        mat_note_list{3}= 'r_x_pq_ori_back.mat'; mat_note_list{4}= 'x_pq_ptp_back.mat';
        mat_note = mat_note_list{datatype};
        
        reconDir = ['/Users/cag/Documents/Dataset/recon_results/',dataset_label, ...
            '/sub', num2str(subject_num), subject_suffix(subject_num), '/'];
        reconDir = [reconDir{:}];
        
        xPath = fullfile(reconDir, mat_note);
        
        x_b_set_back{subject_num, datatype} = load(xPath);
        disp([xPath, ' is imported'])
    end
end

%
f = 'img';
x1 = cat(2, x_b_set_back{1,1}.(f),  x_b_set_back{1,2}.(f),x_b_set_back{1,3}.(f),x_b_set_back{1,4}.(f));
bmImage(x1)

x2 = cat(2, x_b_set_back{2,1}.(f), x_b_set_back{2,2}.(f),x_b_set_back{2,3}.(f),x_b_set_back{2,4}.(f));
bmImage(x2)

x3 = cat(2, x_b_set_back{3,1}.(f), x_b_set_back{3,2}.(f),x_b_set_back{3,3}.(f),x_b_set_back{3,4}.(f));
bmImage(x3)


%% import all the registered .mat files (with _back suffix, except ref images: bern x_pq_ptp)
dataset_label = '251007_chuv_abs'; %or '251007_chuv_abs'
x_c_set_back={};
for subject_num = [1,2,3]
    for datatype = [1,2]
        subject_suffix = {'_ml', '_jb', '_yj',  '_phantom'};

        mat_note_list{1}= 'r_x_pq_ori_back.mat'; mat_note_list{2}= 'r_x_pq_ptp_back.mat';
        mat_note = mat_note_list{datatype};
        
        reconDir = ['/Users/cag/Documents/Dataset/recon_results/',dataset_label, ...
            '/sub', num2str(subject_num), subject_suffix(subject_num), '/'];
        reconDir = [reconDir{:}];
        
        xPath = fullfile(reconDir, mat_note);
        
        x_c_set_back{subject_num, datatype} = load(xPath);
        disp([xPath, ' is imported'])
    end
end

%
f = 'img';
x1 = cat(2, x_c_set_back{1,1}.(f),  x_c_set_back{1,2}.(f));
bmImage(x1)

x2 = cat(2, x_c_set_back{2,1}.(f), x_c_set_back{2,2}.(f));
bmImage(x2)

x3 = cat(2, x_c_set_back{3,1}.(f), x_c_set_back{3,2}.(f));
bmImage(x3)

%%

