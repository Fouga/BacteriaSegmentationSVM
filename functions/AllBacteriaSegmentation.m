function AllBacteriaSegmentation(sourceD,model_name,varargin)

% Using the SVM model this function runs object segmentation on the Tissue 
% Vision image dataset. The segmentation  model is obtained using function 
% InitializeYourModel. 
% 
% 
% Usage:          AllBacteriaSegmentation(sourceD,model_name)
%
% Input: sourceD  The address of a directory that points to the image data.
%                 One must pay attention to the colors separation folders! 
%                 In this implementation red is in the folder named '2',
%                 green - 1, blue - 3. 
%
%     model_name  need to provide a full path and a name to the SVM model 
%                 that is saved in a './models/' directory.
%       varargin  optional parameters needed for the pipeline in order to 
%                 generalize filed of application or speciafy to show results
%                 or not.
%                 options.Object can be 'bacteria' or 'parasite'
%                 options.showImage can be 0 or 1 
%                 
%
% Output:         Stores segmentation results: image masks and objects' text files 
%                 to the  [sourceD 'Segmentation_results_' model_name '/']
%       
% The obtained mask also needs to be filtered to get rid of outliers. The
% filtering depends on the object of interest. This option can be changed: 
% options.filtering = true;
% Usualy very small objects do not belong to the correct ones. To change
% the number of pixels inside an object one need this threshold 
% options.NumPixThresh = 2;
%
% To include neighboring pixels of the detected object region growing
% algorithm is used: options.RegionGrow = true;

% See also: InitializeYourModel, SVMsegmentation
%
% Author:
% Natalia Chicherova, 2018

options = Segmentation_parseInputs(varargin);
if strcmp(options.Object,'neutrophil')==1 && options.NumPixThresh <20
    options.NumPixThresh = 20;
end
% load SVM model
options.model_name = model_name;  
options.folder_source = sourceD;

load(model_name);
if isempty(options.folder_destination)
    save_dir=fullfile(sourceD, ['Segmentation_results_' options.Object]);
    if ~exist(save_dir)
        mkdir(save_dir);
    end
    options.folder_destination = save_dir;
end
disp(options);

if options.OptBrightCorrection == 1
   CorrectionTable = correctOpticalBrightness(sourceD,options.folder_destination);
end

% read all the images' names
% source_dir = [sourceD '*.tif'];
% [pth filter ext] = fileparts(source_dir);
% folder_source = pth; 
% pth1 = [pth '/1/'];
ext = '.tif';
redf = num2str(options.red);
greenf = num2str(options.green);
bluef = num2str(options.blue);
d = dir([fullfile(sourceD,redf,'*') ext]);

% save all filenames in options
options.ALLfilenames = cell(numel(d),1);
for i = 1:numel(d)
    options.ALLfilenames{i} = d(i).name;
end

% get the number of physical and optical section independent of Mosaic.txt
% from the names of the images
% make it when no mosaIC!!!!!
optical_section = []; physical_section = [];
for z=1:numel(d)
    FileName = options.ALLfilenames{z};
    sign_ = strfind( FileName,'_');
    optical_section = [optical_section; str2num( FileName(sign_(2)+1:end-length(ext)))];
    physical_section = [physical_section; str2num( FileName(sign_(1)+1:sign_(2)-1) )];
end
options.number_of_optic_sec = max(optical_section);
options.number_of_frames = max(physical_section);

%threshold for region growing in order to convert it to 8bit
if options.RegionGrow == true 
    TableOptions = readtable ([model_name '.txt']);
    options.greenThresh = TableOptions.greenThresh;
    options.blueThresh = TableOptions.blueThresh;
    options.redThresh = TableOptions.redThresh;
    options.IncludeRed = 0;
end



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
        green = imread(fullfile(sourceD, greenf ,[ name, '_0',  int2str(optical), ext]));
        GREEN{optical} = green;
        red = imread(fullfile(sourceD, redf, [name, '_0',  int2str(optical), ext]));
        RED{optical} = red;
        blue = imread(fullfile(sourceD, bluef, [name, '_0',  int2str(optical), ext]));
        BLUE{optical} = blue;
    end
    disp(['Loading took ', int2str(toc), ' sec']);
    
    % segment using RGB model from SVM
    tic;
    MASK = SVMsegmentation(RED, GREEN, BLUE, SVMModel, options);
    disp(['Segmentation took ', int2str(toc), ' sec']);

    % filter artifacts: this is specific to 2-photon microscopy
    if options.filtering==true
        MASK = FilterArtifacts(MASK,RED, GREEN, BLUE,options);
    end

    
    % include neighboring pixels 
    if options.RegionGrow == true 
        MASK = GrowingRegion(MASK,RED, GREEN, BLUE,options);
    end
    
    for optical=1:options.number_of_optic_sec
        M = MASK{optical};
        if options.showImage==true && optical ==1 && ( mod(frame,50)==0 || frame==1)
            showSegmenatedImage(M, RED{optical}, GREEN{optical}, BLUE{optical},model_name);
        end
        mask_name = [save_dir, name, '_', int2str(optical) ,'.pbm'];
        save_image(M, mask_name);
        txt_name = [save_dir 'positions_', name, '_', int2str(optical),  '.txt'];    
        saveParameters(frame, optical, MASK{optical}, RED{optical},GREEN{optical},BLUE{optical},txt_name,options);
 
    end
        
  
end

putAlltxtTogether(options);

if options.Filter3D == true
    txt_name = [options.saving_dir 'Allpositions', '.txt'];    
    A = readtable(txt_name,'Format', '%12.0f %12.0f %12.0f %6.0f %6.0f %6.0f %12.3f %15.1f %15.4f %15.1f %15.1f %15.1f %15.1f %15.1f %15.1f');

    Afiltered = filterByPosition(A,options);
    txt_name = [options.saving_dir 'Allpositions_filter3D', '.txt']; 
    writetable(Afiltered,txt_name);
end