function [SVMModel,model_name]  = InitializeYourModel(red_name,green_name,blue_name)


% load slices
RED = imread(red_name); 
GREEN = imread(green_name); 
BLUE = imread(blue_name); 

% build a model
[SVMModel,model_name]  = guiModelBuild(RED, GREEN, BLUE);