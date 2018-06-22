function makeTrainingData(options)

p = mfilename('fullpath');
Fdir = fileparts(p);
% if no train data
questTitle='Sort bacteria'; 
start(timer('StartDelay',1,'TimerFcn',@(o,e)set(findall(0,'Tag',questTitle),'WindowStyle','normal')));
choice = questdlg('There is no training dataset for CNN. To make the data, prior filtering with SVM is needed. Do you want to do the training data?', questTitle, 'Yes','No','Yes');
switch choice
    case 'Yes'
        cont = 1;
    case 'No'
        cont = 0;
end
options.CNNdataDir = fullfile(Fdir,'Data4CNNtrain');
% which image you want to use
if cont ==1
    mkdir(fullfile(Fdir,'Data4CNNtrain'));
    prompt = 'Which FRAME do you want to use: ';
    frame = input(prompt);
    prompt = 'Which OPTICAL SECTION do you want to use: ';
    optical = input(prompt);
    % make training data set
     choice4CNNtraining(frame,optical,options);

end
