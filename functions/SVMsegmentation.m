function MASK = SVMsegmentation(RED, GREEN, BLUE, SVMModel, options)


CPRE = ApplySVMModel(RED, GREEN, BLUE, SVMModel, options);


% build a mask
MASK = cell(1,options.number_of_optic_sec);

for optical = 1:options.number_of_optic_sec
        red = RED{optical};
        Mask = zeros(size(red));
        Mask(CPRE{optical}==20) =1;
        
        MASK{optical} = Mask;
end
 




function  CPRE = ApplySVMModel(RED, GREEN, BLUE, SVMModel, options)

if options.OptBrightCorrection
    CorrectionTable = readtable(fullfile(options.folder_destination, 'BrightnessCorrection.txt'));
    ratioGreen = CorrectionTable.ratio( CorrectionTable.Channel==options.green);
    ratioRed = CorrectionTable.ratio( CorrectionTable.Channel==options.red);
    ratioBlue = CorrectionTable.ratio( CorrectionTable.Channel==options.blue);
else
    ratioGreen = ones(options.number_of_optic_sec,1);
    ratioRed = ones(options.number_of_optic_sec,1);
    ratioBlue = ones(options.number_of_optic_sec,1);
end

test = cell(1,options.number_of_optic_sec);
parfor optical = 1:options.number_of_optic_sec
    gr = GREEN{optical}.*ratioGreen(optical);
    red = RED{optical}.*ratioRed(optical);
    bl = BLUE{optical}.*ratioBlue(optical);
    test{optical}= [red(:), gr(:), bl(:)];
end

CPRE = cell(1,options.number_of_optic_sec);
for optical = 1:options.number_of_optic_sec 
    fprintf('Predicting model %i...\n',optical);
    cpre = predict(SVMModel,double(test{optical}));
    CPRE{optical} = cpre;
end