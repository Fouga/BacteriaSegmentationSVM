% run
clear all
close all
addpath(genpath('./functions/'));

sourceD = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20171124_Enro_resist_D5_M2/';
% sourceD = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/jia/gfpYfp/';

% load an image which has the largest amount of objects of interest (bacteria)
red_name = [sourceD 'stitchedImages_100/2/section_010_05.tif']; % point to the red channel image
green_name = [sourceD 'stitchedImages_100/1/section_010_05.tif'];
blue_name = [sourceD 'stitchedImages_100/3/section_010_05.tif'];

[SVMModel, model_name] = InitializeYourModel(red_name, green_name, blue_name);

% segment the object in the entire data set
AllBacteriaSegmentation(sourceD,model_name);

