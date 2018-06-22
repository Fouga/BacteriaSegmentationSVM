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
    options.training_done = 0;
if strcmp(options.Object,'neutrophil')==1 && options.NumPixThresh <20
    options.NumPixThresh = 20;
end
% load SVM model
options.model_name = model_name;  
options.folder_source = sourceD;

load(model_name);
if ispc
    filsep = '\';
else
    filsep = '/';
end



if isempty(options.folder_destination)
    startIndex = regexp(fullfile(sourceD,'.'),filsep);
    Sdir = sourceD(1:startIndex(end-1));
    save_dir=fullfile(Sdir, ['Segmentation_results_' options.Object]);
    if ~exist(save_dir)
        mkdir(save_dir);
    end
    options.folder_destination = save_dir;
    if ~exist(fullfile(save_dir,'SegmenatationPerSlice'))
        mkdir(fullfile(save_dir,'SegmenatationPerSlice'));
    end
    options.folder_destination_perSlice = fullfile(save_dir,'SegmenatationPerSlice');
end
disp(options);

p = mfilename('fullpath');
Fdir = fileparts(p);
if options.FilterCNN ==1 && ~exist(fullfile(Fdir,'ArtifactsFiltering','Data4CNNtrain'))
    makeTrainingData(options);
end

if options.OptBrightCorrection == 1
   CorrectionTable = correctOpticalBrightness(sourceD,options.folder_destination);
end

% read all the images' names
ext = '.tif';
redf = num2str(options.red);
greenf = num2str(options.green);
bluef = num2str(options.blue);
d = dir([fullfile(sourceD,redf,'*') ext]);

% get all images names
imdsr = imageDatastore(fullfile(sourceD,redf), 'FileExtensions', {'.tif'});
imdsg = imageDatastore(fullfile(sourceD,greenf), 'FileExtensions', {'.tif'});
imdsb = imageDatastore(fullfile(sourceD,bluef), 'FileExtensions', {'.tif'});

% collect filenames withour extentions
options.ALLfilenames = cell(numel(d),1);
for i = 1:numel(d)
    [~,options.ALLfilenames{i}] = fileparts(d(i).name);
end
NAMES = options.ALLfilenames;

% get the number of physical and optical section independent of Mosaic.txt
% from the names of the images
optical_section = []; physical_section = [];
for z=1:numel(d)
    FileName = options.ALLfilenames{z};
    sign_ = strfind( FileName,'_');
    optical_section = [optical_section; str2num( FileName(sign_(2)+1:end))];
    physical_section = [physical_section; str2num( FileName(sign_(1)+1:sign_(2)-1) )];
end
options.number_of_optic_sec = max(optical_section);
options.number_of_frames = max(physical_section);

%threshold for region growing in order to convert it to 8bit
if options.RegionGrow == true
    if ~exist([model_name '.txt'],'file')
        options.greenThresh = 2000;
        options.blueThresh = 1000;
        options.redThresh = 1000;
    else
        TableOptions = readtable([model_name '.txt']);
        options.greenThresh = TableOptions.greenThresh;
        options.blueThresh = TableOptions.blueThresh;
        options.redThresh = TableOptions.redThresh;
    end
    options.IncludeRed = 0;
end


%%%%%%%%%%%%%%%%%%%% LOOP THE SLICES
myCluster = parcluster('local');
myCluster.NumWorkers = 12;  % 'Modified' property now TRUE
%saveProfile(myCluster);    % 'local' profile now updated
                           % 'Modified' property now FALSE
cnt = 1;
num = options.number_of_images;
while cnt<=numel(d)
  % load images
     if cnt+num > numel(d)
         steps = numel(d)-cnt+1;
     else
         steps = num;
     end
    if steps ==0
        steps = 1;
    end
    inds =  cnt:cnt+steps-1;
    GREEN = cell(1,length(inds));
    RED = cell(1,length(inds));
    BLUE = cell(1,length(inds));

    tic;
    
    parfor i = 1:length(inds)
        display(['Loading ', NAMES{inds(i)}]);
        green = readimage(imdsg,inds(i));
        GREEN{i} = green;
        red = readimage(imdsr,inds(i));
        RED{i} = red;
        blue = readimage(imdsb,inds(i));
        BLUE{i} = blue;
    end
    disp(['Loading took ', int2str(toc), ' sec']);
    
    % segment using RGB model from SVM
    tic;
    MASK = SVMsegmentation(RED, GREEN, BLUE, SVMModel, options);
    disp(['Segmentation took ', int2str(toc), ' sec']);

    % filter artifacts: this is specific to 2-photon microscopy
    tic;
    if options.filtering==true
        MASK = FilterArtifacts(MASK,RED, GREEN, BLUE,options);
    end
    disp(['Artifacts filtering took ', int2str(toc), ' sec']);
    
    % include neighboring pixels % TODO
    if options.RegionGrow == true 
        MASK = GrowingRegion(MASK,RED, GREEN, BLUE,options);
    end
    
    for j=1:length(inds)
        M = MASK{j};
        if options.showImage==true && (j==1 || mod(j,20)==0 )
            showSegmenatedImage(M, RED{j}, GREEN{j}, BLUE{j},options,model_name);
        end
        mask_name = fullfile(options.folder_destination_perSlice,[ NAMES{inds(j)} ,'.pbm']);
        save_image(M, mask_name);
        txt_name = fullfile(options.folder_destination_perSlice,['positions_',NAMES{inds(j)},  '.txt']); 
        sign_ = strfind( NAMES{inds(j)},'_');
        optical = str2num( NAMES{inds(j)}(sign_(2)+1:end));
        frame = str2num(NAMES{inds(j)}(sign_(1)+1:sign_(2)-1));
        saveParameters(frame, optical, MASK{j}, RED{j},GREEN{j},BLUE{j},txt_name,options);
 
    end
    clear GREEN
    clear RED
    clear BLUE
    clear MASK
    
    cnt = cnt+steps;
end

% save options
struct2File( options,fullfile(save_dir,'Segmentation_options.txt'));
putAlltxtTogether(options);

if options.Filter3D == true
    txt_name = fullfile(options.folder_destination, ['Allpositions', '.txt']);    
    A = readtable(txt_name,'Format', '%12.0f %12.0f %12.0f %6.0f %6.0f %6.0f %12.3f %15.1f %15.4f %15.1f %15.1f %15.1f %15.1f %15.1f %15.1f');

    Afiltered = filterByPosition(A,options);
    txt_name = fullfile(options.folder_destination,['Allpositions_filter3D', '.txt']); 
    writetable(Afiltered,txt_name);
end
