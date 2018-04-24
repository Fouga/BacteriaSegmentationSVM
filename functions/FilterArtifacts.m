function MASK = FilterArtifacts(MASK,RED, GREEN, BLUE,options)

% filter very bright pixels and remove small objects. Very bright pixels 
% are the pixels that have values > 6000. The size of the
% objects is specified by options.NumPixThresh

thrBright = 6000;
for optical=1:options.number_of_optic_sec
    M = MASK{optical};
    red = RED{optical};
    green = GREEN{optical};
    blue = BLUE{optical};
    
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
            for i=1:length(idX)
                M(cc.PixelIdxList{idX(i)}) = 0;
            end

            MASK{optical} = M;
        case 'neutrophil'
              % remove very bright pixels
            M(red>thrBright & green>thrBright & blue>thrBright)=0;
            cc = bwconncomp(M,8);
            numPixels = cellfun(@numel,cc.PixelIdxList);
            idX = find(numPixels<=options.NumPixThresh);
            for i=1:length(idX)
                M(cc.PixelIdxList{idX(i)}) = 0;
            end
            
            MASK{optical} = M;
            
    end
%     showSegmenatedImage(M, red, green, blue);
    % remove straight lines
    
end

