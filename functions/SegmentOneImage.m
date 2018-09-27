function        SegmentOneImage(options) 

frame = options.one_image_segmenation(1);
optical = options.one_image_segmenation(2);
GREEN = cell(1,1);
RED = cell(1,1);
BLUE = cell(1,1);
NAMES = options.ALLfilenames;
for i =1:size(NAMES,1)
    str = NAMES{i};
    if contains(str,num2str(frame))
        if contains(str,num2str(optical))
            imName = NAMES{i};
            Ind = i;
        end
    end
end

redf = num2str(options.red);
greenf = num2str(options.green);
bluef = num2str(options.blue);
% get all images names
imdsr = imageDatastore(fullfile(options.folder_source,redf), 'FileExtensions', {'.tif'});
imdsg = imageDatastore(fullfile(options.folder_source,greenf), 'FileExtensions', {'.tif'});
imdsb = imageDatastore(fullfile(options.folder_source,bluef), 'FileExtensions', {'.tif'});

display(['Loading ',imName]);
green = readimage(imdsg,Ind);
GREEN{1} = green;
red = readimage(imdsr,Ind);
RED{1} = red;
blue = readimage(imdsb,Ind);
BLUE{1} = blue;
load(options.model_name);
MASK = SVMsegmentation(RED, GREEN, BLUE, SVMModel,Ind, options);
if options.filtering==true
    MASK = FilterArtifacts(MASK,RED, GREEN, BLUE,options);
end
showSegmenatedImage(MASK{1}, RED{1}, GREEN{1}, BLUE{1},options);
mask_name = fullfile(options.folder_destination_perSlice,[ NAMES{Ind} ,'.pbm']);
save_image(MASK{1}, mask_name);
txt_name = fullfile(options.folder_destination_perSlice,['positions_',NAMES{Ind},  '.txt']); 
sign_ = strfind( NAMES{Ind},'_');
optical = str2num( NAMES{Ind}(sign_(2)+1:end));
frame = str2num(NAMES{Ind}(sign_(1)+1:sign_(2)-1));
saveParameters(frame, optical, MASK{1}, RED{1},GREEN{1},BLUE{1},txt_name,options);
 