function MASK = FilterArtifacts(MASK,RED, GREEN, BLUE,options)

thrBright = 6000;
parfor optical=1:options.number_of_optic_sec
    M = MASK{optical};
    red = RED{optical};
    green = GREEN{optical};
    blue = BLUE{optical};
    % remove very bright pixels
    M(red>thrBright & green>thrBright & blue>thrBright)=0;
%     showSegmenatedImage(M, RED{optical}, GREEN{optical}, BLUE{optical});

    % remove pixels with larger red values
    M(red>green | blue>green)=0;
%     showSegmenatedImage(M, RED{optical}, GREEN{optical}, BLUE{optical});

    cc = bwconncomp(M,8);
    numPixels = cellfun(@numel,cc.PixelIdxList);
    idX = find(numPixels<=5);
    for i=1:length(idX)
        M(cc.PixelIdxList{idX(i)}) = 0;
    end
%     showSegmenatedImage(M, RED{optical}, GREEN{optical}, BLUE{optical});

    
    
    
    MASK{optical} = M;
    
    % remove straight lines
    
end

