function [SVMModel,Name] = guiModelBuild(RED, GREEN, BLUE)
% This function allows to build a Support Vector Mashine model to separate
% RGB values of the objects of interest from the background. 
% This function builds a 2 classes SVM model based on selected object's
% pixels and background pixels. The user should manually mark areas of the image which contain 
% pixels that belong to the object to segment (e.g. bacteria, toxoplasma)
% and areas of the image which contain background, i.e. everything which is not the object.
%
% HINT: the more pixels of the object are selected the more robust the model
%       will be.
% 
% 
% Usage:          [SVMModel,model_name]  = InitializeYourModel(red_name,green_name,blue_name)
%
% Input: red_name    full path to the image which contains red color of the data.  
%                    e.g. red_name = [~/Data/20180503_Antibiotic02/1/section_004_01.tif'];
%        green_name  full path to the image which contains green color of the data.  
%                    e.g. green_name = [~/Data/20180503_Antibiotic02/2/section_004_01.tif'];
%        blue_name   full path to the image which contains blue color of the data.  
%                    e.g. blue_name = [~/Data/20180503_Antibiotic02/3/section_004_01.tif'];
%
%                 
%
% Output: SVMModel   SVM model that is used to segment objects with a
%                    specific color. It can be a plane or paraboloid in RGB space
%                    that separates the color of the selected object from
%                    the background color.
%       model_name   name of the SVM model which can be given to
%                    AllBacteriaSegmentation function.
%
% See also: guiModelBuild, AllBacteriaSegmentation, SVMsegmentation
%
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
% Author: Chicherova Natalia, 2019
%         University of Basel  

cont = 0;
SavedBackground = zeros(size(RED));
SavedForegr = zeros(size(RED));
while cont==0
    % show image with sprecified thresholds
    [totalBinary_backr, totalBinary_foregr,rgbIm,options] =guiChooseRegions(RED, GREEN, BLUE);

    % fit svm
    SVMModel = guiBuildSVMModel(RED,GREEN,BLUE,totalBinary_backr, totalBinary_foregr, SavedBackground,SavedForegr);

    % see how the model works on the image
    guiTestSVMModel(SVMModel,RED, GREEN, BLUE, rgbIm);
    
    % save the marked mask and add additional mask if needed
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

mydir  = mfilename('fullpath');
idcs   = strfind(mydir,filesep);
newdir = mydir(1:idcs(end-1)-1); 
Name = fullfile(newdir, 'models', model_name);
disp(['saving model: ' Name]);
save([Name '.mat'],'SVMModel');
writetable(struct2table(options),[Name '.txt']);

