
x1 = norm_image(xrms_mreye,[0,0.7]);

bmImage(x1);

%%
x1_sag = flip(permute(x1, [3,1,2]),1);
bmImage(x1_sag);

%%
% Define folder where images and ppt will be saved
saveFolder = '/Users/cag/Documents/Dataset/recon_results/251216/MID00248_recon/output/sag/';
sliceRange=272:335;
% function ppt_generator(saveFolder, sliceRange, x)
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end
% Index range of slices
% sliceRange = 212:279;


% --- 1) Save slices as PNGs ---

for idx = sliceRange
    img = x1_sag(:, :, idx);

    % Normalize to [0, 1] for saving as image (optional but usually helpful)
    imgNorm = mat2gray(img);

    % Construct filename like slice_070.png, slice_071.png, ...
    imgName = sprintf('slice_%03d.png', idx);
    saveFile = fullfile(saveFolder, imgName);

    % Save image
    imwrite(imgNorm, saveFile);
end

disp('All slices saved as PNGs');

%% --- 2) Create PowerPoint and add each slice as a slide ---

import mlreportgen.ppt.*;

pptFile = fullfile(saveFolder, 'slices_sag.pptx');
presentation = Presentation(pptFile);
open(presentation);

for idx = sliceRange
    imgName = sprintf('slice_%03d.png', idx);
    imgPath = fullfile(saveFolder, imgName);

    % Add a new slide with title + content layout
    slide = add(presentation, 'Title and Content');

    % Title
    replace(slide, 'Title', sprintf('Slice %d', idx));

    % Add the picture to the content placeholder
    pic = Picture(imgPath);
    % Make PNG almost full-slide
    pic.Width  = '20in';   % adjust as needed
    pic.Height = '20in';
    replace(slide, 'Content', pic);
end

close(presentation);
disp(['PowerPoint created: ' pptFile]);