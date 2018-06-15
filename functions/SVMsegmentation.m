function MASK = SVMsegmentation(RED, GREEN, BLUE, SVMModel, options)


CPRE = ApplySVMModel(RED, GREEN, BLUE, SVMModel, options);


% build a mask
MASK = cell(1,size(RED,2));

for i = 1:size(RED,2)
        red = RED{i};
        Mask = zeros(size(red));
        Mask(CPRE{i}==20) =1;
        
        MASK{i} = Mask;
end
 




function  CPRE = ApplySVMModel(RED, GREEN, BLUE, SVMModel, options)

if options.OptBrightCorrection
    % TO DO
    CorrectionTable = readtable(fullfile(options.folder_destination, 'BrightnessCorrection.txt'));
    ratioGreen = CorrectionTable.ratio( CorrectionTable.Channel==options.green);
    % repmat(options.number_of_opt_sec)
    ratioRed = CorrectionTable.ratio( CorrectionTable.Channel==options.red);
    ratioBlue = CorrectionTable.ratio( CorrectionTable.Channel==options.blue);
else
    ratioGreen = ones(size(RED,2),1);
    ratioRed = ones(size(RED,2),1);
    ratioBlue = ones(size(RED,2),1);
end
% to do brightness correction
test = cell(1,size(RED,2));
parfor i = 1:size(RED,2)
    gr = GREEN{i};
    red = RED{i};
    bl = BLUE{i};
    test{i}= [red(:), gr(:), bl(:)];
end

CPRE = cell(1,size(RED,2));
for i = 1:size(RED,2)
    fprintf('Predicting model %i...\n',i);
    cpre = predict(SVMModel,double(test{i}));
    CPRE{i} = cpre;
end