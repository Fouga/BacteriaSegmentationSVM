function MASK = FilterArtifacts(MASK,RED, GREEN, BLUE,options)

% filter very bright pixels and remove small objects. Very bright pixels 
% are the pixels that have values > 6000. The size of the
% objects is specified by options.NumPixThresh

thrBright = 6000;
for i=1:size(RED,2)
    M = MASK{i};
    red = RED{i};
    green = GREEN{i};
    blue = BLUE{i};
    
    switch options.Object
        case 'bacteria'
            % for filtering
%             options.NumPixThresh = 2;
            % remove very bright pixels
            M(red>thrBright & green>thrBright & blue>thrBright)=0;

            % remove pixels with larger red values
            M(red>green | blue>green)=0;

            cc = bwconncomp(M,8);
            numPixels = cellfun(@numel,cc.PixelIdxList);
            idX = find(numPixels<=options.NumPixThresh);
            for j=1:length(idX)
                M(cc.PixelIdxList{idX(j)}) = 0;
            end

            MASK{i} = M;
        case 'neutrophil'
              % remove very bright pixels
            M(red>thrBright & green>thrBright & blue>thrBright)=0;
            cc = bwconncomp(M,8);
            numPixels = cellfun(@numel,cc.PixelIdxList);
            idX = find(numPixels<=options.NumPixThresh);
            for j=1:length(idX)
                M(cc.PixelIdxList{idX(j)}) = 0;
            end
            
            MASK{i} = M;
            
    end
%     showSegmenatedImage(M, red, green, blue);
    % filter using traned CNN 

    
end

if options.FilterCNN ==1

    % do the training only ones
    if options.training_done ~=1 
        p = mfilename('fullpath');
        Fdir = fileparts(p);
        % if no train data
        if ~exist(fullfile(Fdir,'Data4CNNtrain'))
            questTitle='Sort bacteria'; 
            start(timer('StartDelay',1,'TimerFcn',@(o,e)set(findall(0,'Tag',questTitle),'WindowStyle','normal')));
            choice = questdlg('There is no data for CNN filtering.\n Do you want to train CNN for filtering?', questTitle, 'Yes','No','Yes');
            switch choice
                case 'Yes'
                    cont = 1;
                case 'No'
                    cont = 0;
            end
            if cont ==1 
                mkdir(fullfile(Fdir,'Data4CNNtrain'));
                % make training data set
                % the an image with many objects
                source_dir = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/stitchedImages_100/';
                segmentation_dir = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/stitchedImages_100/Segmentation_results_bacteria_withoutCNN/';
                
                for frame = 10
                    for optical = 1%:5
                        show_segmentation_resutlsPatches(source_dir,frame,optical,segmentation_dir,0,1);
                    end
                end
            end
        end
        options.CNNdataDir = fullfile(Fdir,'Data4CNNtrain');

        % train network if needed
        [net,featureLayer,classifier,options] =trainCNNbacteria(options);
    end
    
    for i=1:size(RED,2)
        M = MASK{i};
        red = RED{i};
        green = GREEN{i};
        blue = BLUE{i};
        M = discardNonBacteriaCNN(red, green, blue,M,net,featureLayer,classifier,options);
        MASK{i} = M;
    end
end