<img src="https://github.com/Fouga/BacteriaSegmentationSVM/blob/gh-pages/pipe.png" />

# Bacteria Segmentation using Support Vector Machine

This segmentation pipeline uses Support Vector Machine to cluster distinctive colors of an image. It is based on the idead that image colors (red, green, blue) can be represented using Cartesian coordinates, i.e. a point of an image with cyan color is a (0,255,255) point in 3D RGB space. Hence segmentation of an object with destinctive color is reduced to clustering a cloud of points in 3D coordinate system. 

# Motivation

Localization of bacteria in a large 3D volume is time consuming using simple thresholding because, first, there are many false positive outcomes after thresholding which should be removed manually. Second, the thresholds should be tuned manually to each data set. Therefore, we developed a method that could work as the thresholding but in a user friendly mode and with more options, e.g. SVM model can be plane or parabolla.  


# Example
```Matlab
addpath(genpath('./functions/'));

sourceD = 'FULL_PATH_DATA/';

% load an image which has the largest amount of objects of interest (bacteria)
red_name = PATH_TO_RED_CHANNEL; % point to the red channel image
green_name = PATH_TO_GREEN_CHANNEL;
blue_name = PATH_TO_BLUE_CHANNEL;
 
[SVMModel, model_name] = InitializeYourModel(red_name, green_name, blue_name);

% segment the object in the entire data set
AllBacteriaSegmentation(sourceD,model_name);

```

# Remarks

```AllBacteriaSegmentation() ``` is made specifically for the data after tile stitching ([*StitchIt*](https://github.com/Fouga/StitchIt/) or [*StitchIt*](https://github.com/BaselLaserMouse/StitchIt)).
