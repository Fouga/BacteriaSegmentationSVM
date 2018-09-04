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
%     if options.training_done ~=1 
% 
%         % load pre-trained network 
% %         save
%     end
    
    for i=1:size(RED,2)
        M = MASK{i};
        red = RED{i};
        green = GREEN{i};
        blue = BLUE{i};
        M = discardNonBacteriaCNN(red, green, blue,M,options);
        MASK{i} = M;
    end
end