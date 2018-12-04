function [net,featureLayer,classifier,options] = trainCNNbacteria(options)

disp('Training convolutional network...');

rootFolder = options.CNNdataDir;
categories = {options.Labels{1}, options.Labels{2}};

imds = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');

tbl = countEachLabel(imds);
minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category

% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount, 'randomize');

% Notice that each set now has exactly the same number of images.
countEachLabel(imds)
% Find the first instance of an image for each category
Bacterium = find(imds.Labels == options.Labels{1}, 1);
notBact = find(imds.Labels == options.Labels{2}, 1);

% Load pretrained network
net = resnet50();

[trainingSet, testSet] = splitEachLabel(imds, 0.7, 'randomize');
options.imageSizeCNN = [224 224];
augmentedTrainingSet = augmentedImageDatastore(options.imageSizeCNN, trainingSet);
augmentedTestSet = augmentedImageDatastore(options.imageSizeCNN, testSet);

featureLayer = 'fc1000';
trainingFeatures = activations(net, augmentedTrainingSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

% Get training labels from the trainingSet
trainingLabels = trainingSet.Labels;

% Train multiclass SVM classifier using a fast linear solver, and set
% 'ObservationsIn' to 'columns' to match the arrangement used for training
% features.
classifier = fitcecoc(trainingFeatures, trainingLabels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

% Extract test features using the CNN
testFeatures = activations(net, augmentedTestSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

% Pass CNN image features to trained classifier
predictedLabels = predict(classifier, testFeatures, 'ObservationsIn', 'columns');

% Get the known labels
testLabels = testSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

% Convert confusion matrix into percentage form
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))



options.training_done = 1;