function     [ModelC,options] = getCorrectionModel(source, save_dir,optS,chan)

CorrectModel_name = [save_dir sprintf('Model_opticalSection%i_chan%i.mat',optS,chan)];

[pth filter ext] = fileparts(source);
pth2 = [pth '/**/'];

% store the source path in the options structure
options.folder_source = pth2;  
options.source = source; 
% read all the files in d
d = dir([options.folder_source filter ext]);
% create a new field for all file names of the channel in options.
options.ALLfilenames = cell(numel(d),1);

for i = 1:numel(d)
    options.ALLfilenames{i} = [pth '/' d(i).name];
end
% store the number of source images into the options structure
options.ALLnum_images_provided = numel(options.ALLfilenames);

% load one image to check the downsampling size
I = imread(options.ALLfilenames{1});
if numel(size(I)) == 3
    error('CIDRE:loadImages', 'Non-monochromatic image provided. CIDRE is designed for monochromatic images. Store each channel as a separate image and re-run CIDRE.'); 
end
options.image_size = size(I);
options.target_num_pixels     	= 9400;
[R C] = determine_working_size(options.image_size, options.target_num_pixels);
options.working_size = [R C];
clear I

if ~exist(CorrectModel_name)
    % preallocate memory for loaded images
    S_all = zeros([options.working_size options.ALLnum_images_provided]);
    NAMES = options.ALLfilenames;
    fprintf(' Reading %d images from %s, section %s\n', ...
        options.ALLnum_images_provided, options.folder_source(1:end-3), filter(end-1:end));

    % load all the images from the given channel into the memory
    parfor z = 1:options.ALLnum_images_provided
           I = imread(NAMES{z});
           S_all(:,:,z) = double(imresize(I, [R C]));
    end

    ModelC = mean(S_all,3);
    save(CorrectModel_name,'ModelC');
else
    disp(['Model already exist: ' CorrectModel_name]);
    ModelC = load(CorrectModel_name);
    ModelC = ModelC.ModelC;
end


  
    

function [R_working C_working] = determine_working_size(image_size, N_desired)
% determines a working image size based on the original image size and
% the desired number of pixels in the working image, N_desired


R_original = image_size(1);
C_original = image_size(2);

scale_working = sqrt( N_desired/(R_original*C_original));

R_working = round(R_original * scale_working);
C_working = round(C_original * scale_working);
