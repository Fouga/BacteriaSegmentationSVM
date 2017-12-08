function MASK = SVMsegmentation(RED, GREEN, BLUE, SVMModel, options)


CPRE = ApplySVMModel(RED, GREEN, BLUE, SVMModel, options);


% build a mask
MASK = cell(1,options.number_of_optic_sec);

for optical = 1:options.number_of_optic_sec
        red = RED{optical};
        Mask = zeros(size(red));
        Mask(CPRE{optical}==20) =1;
        
        % remove small objects
        cc = bwconncomp(Mask,8);
        numPixels = cellfun(@numel,cc.PixelIdxList);
        idX = find(numPixels<5);
        for i=1:length(idX)
            Mask(cc.PixelIdxList{idX(i)}) = 0;
        end
        
        MASK{optical} = Mask;
end
 




function  CPRE = ApplySVMModel(RED, GREEN, BLUE, SVMModel, options)


test = cell(1,options.number_of_optic_sec);
for optical = 1:options.number_of_optic_sec
    gr = GREEN{optical};
    red = RED{optical};
    bl = BLUE{optical};
    test{optical}= [red(:), gr(:), bl(:)];
end

CPRE = cell(1,options.number_of_optic_sec);
for optical = 1:options.number_of_optic_sec 
    fprintf('Predicting model %i\n',optical);
    cpre = predict(SVMModel,double(test{optical}));
    CPRE{optical} = cpre;
end