%test
% 
sourceD = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170320_ABX7dosage_GFPfil/stitchedImages_100_brightCorrec/';

model_name = 'Neutrophils_model';
save_dir = [sourceD 'Segmentation_results_' model_name '/'];
% read all the images' names
source_dir = [sourceD '*.tif'];
[pth filter ext] = fileparts(source_dir);
folder_source = pth; 
pth1 = [pth '/1/'];
d = dir([pth1 filter ext]);

% save all filenames in options
options.ALLfilenames = cell(numel(d),1);
for i = 1:numel(d)
    options.ALLfilenames{i} = d(i).name;
end

% get the number of physical and optical section independent of Mosaic.txt
% from the names of the images
optical_section = []; physical_section = [];
for z=1:numel(d)
    FileName = options.ALLfilenames{z};
    sign_ = strfind( FileName,'_');
    optical_section = [optical_section; str2num( FileName(sign_(2)+1:end-length(ext)))];
    physical_section = [physical_section; str2num( FileName(sign_(1)+1:sign_(2)-1) )];
end
options.number_of_optic_sec = max(optical_section);
options.number_of_frames = max(physical_section);


options.showImage=true

for frame = 1:options.number_of_frames
  % load images
    if frame < 10 
      counter = strcat('00',int2str(frame)); 
    elseif frame < 100 
      counter = strcat('0',int2str(frame));   
    else
      counter = int2str(frame);   
    end
    name = strcat('section_', counter);
  
  
    GREEN = cell(1,options.number_of_optic_sec);
    RED = cell(1,options.number_of_optic_sec);
    BLUE = cell(1,options.number_of_optic_sec);

    tic;
    parfor optical = 1:options.number_of_optic_sec
        display(['Loading ', name, '_0',  int2str(optical), ext]);
        green = imread([folder_source '/1/', name, '_0',  int2str(optical), ext]);
        GREEN{optical} = green;
        red = imread([folder_source '/2/', name, '_0',  int2str(optical), ext]);
        RED{optical} = red;
        blue = imread([folder_source '/3/', name, '_0',  int2str(optical), ext]);
        BLUE{optical} = blue;
    end
    disp(['Loading took ', int2str(toc), ' sec']);
    
    MASK = cell(1,options.number_of_optic_sec);

    for optical = 1:options.number_of_optic_sec
       mask_name = [save_dir, name, '_', int2str(optical) ,'.pbm'];
       MASK{optical} = imread(mask_name);
    end
    
    MASK = FilterArtifacts(MASK,RED, GREEN, BLUE,options);

    for optical=1:options.number_of_optic_sec
        M = MASK{optical};
        if options.showImage==true && optical ==1 && ( mod(frame,50)==0 || frame==1)
            showSegmenatedImage(M, RED{optical}, GREEN{optical}, BLUE{optical});
        end
        mask_name = [save_dir, name, '_', int2str(optical) ,'.pbm'];
        save_image(M, mask_name);
        txt_name = [save_dir 'positions_', name, '_', int2str(optical),  '.txt'];    
        saveParameters(frame, optical, MASK{optical}, RED{optical},GREEN{optical},BLUE{optical},txt_name,options);
 
    end

    
end
