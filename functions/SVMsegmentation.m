function MASK = SVMsegmentation(RED, GREEN, BLUE, SVMModel, inds,options)


CPRE = ApplySVMModel(RED, GREEN, BLUE, SVMModel,inds, options);


% build a mask
MASK = cell(1,size(RED,2));

for i = 1:size(RED,2)
        red = RED{i};
        Mask = zeros(size(red));
        Mask(CPRE{i}==20) =1;
        
        MASK{i} = Mask;
end
 




function  CPRE = ApplySVMModel(RED, GREEN, BLUE, SVMModel,inds, options)
% paramFile=getTiledAcquisitionParamFile;
% OBJECT=returnSystemSpecificClass;
% param = readMosaicMetaData(OBJECT,paramFile,1);
if options.OptBrightCorrection
    % TO DO
    CorrectionTable = readtable(fullfile(options.folder_destination, 'BrightnessCorrection.txt'));
    ratioGreen = CorrectionTable.ratio( CorrectionTable.Channel==options.green);
    ratioGreen = repmat(ratioGreen,options.number_of_optic_sec*options.number_of_frames,1);
    ratioGreen = ratioGreen(inds);
    ratioRed = CorrectionTable.ratio( CorrectionTable.Channel==options.red);
    ratioRed = repmat(ratioRed,options.number_of_optic_sec*options.number_of_frames,1);
    ratioRed = ratioRed(inds);
    ratioBlue = CorrectionTable.ratio( CorrectionTable.Channel==options.blue);
    ratioBlue = repmat(ratioBlue,options.number_of_optic_sec*options.number_of_frames,1);
    ratioBlue = ratioBlue(inds);
    %param.layers
else
    ratioGreen = ones(size(RED,2),1);
    ratioRed = ones(size(RED,2),1);
    ratioBlue = ones(size(RED,2),1);
end
% to do brightness correction
test = cell(1,size(RED,2));
parfor i = 1:size(RED,2)
    gr = GREEN{i}.*ratioGreen(i);
    red = RED{i}.*ratioRed(i);
    bl = BLUE{i}.*ratioBlue(i);
    test{i}= [red(:), gr(:), bl(:)];
end

CPRE = cell(1,size(RED,2));
for i = 1:size(RED,2)
    fprintf('Predicting model %i...\n',i);
    cpre = predict(SVMModel,double(test{i}));
    CPRE{i} = cpre;
end