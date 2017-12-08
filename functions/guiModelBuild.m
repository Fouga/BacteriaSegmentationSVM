function [SVMModel,model_name] = guiModelBuild(RED, GREEN, BLUE)
% This function allows to build a Support Vector Mashine model to separate
% RGB values of the objects of interest from the background. 

cont = 0;
SavedBackground = zeros(size(RED));
SavedForegr = zeros(size(RED));
while cont==0
    % show iamge with sprecified thresholds
    [totalBinary_backr, totalBinary_foregr,rgbIm] =guiChooseRegions(RED, GREEN, BLUE);

    % fit svm
    SVMModel = guiBuildSVMModel(RED,GREEN,BLUE,totalBinary_backr, totalBinary_foregr, SavedBackground,SavedForegr);

    % see how the model works on the image
    guiTestSVMModel(SVMModel,RED, GREEN, BLUE, rgbIm);

    SavedBackground = totalBinary_backr;
    SavedForegr = totalBinary_foregr;
    
    prompt = 'Do you want to add more data? ';
    choice = input(prompt,'s');
    switch choice
        case {'Yes','yes','y'}
            cont = 0;
        case {'No','no','n'}
            cont = 1;
    end
end

% save you model in the model folder
prompt = 'Name you model: ';
model_name = input(prompt,'s');
save(['./models/' model_name '.mat'],'SVMModel');
