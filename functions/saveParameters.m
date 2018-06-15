function saveParameters(frame, optical, M, RED, GREEN, BLUE, txt_name,options)
   
    cc = bwconncomp(M,8);
    if cc.NumObjects~=0
        Ob = 1:cc.NumObjects;
        FRAME = repmat(frame,cc.NumObjects,1);
        OPTICAL = repmat(optical,cc.NumObjects,1);


        s = regionprops(cc,'basic');
        centroids = cat(1, s.Centroid);
        area =cat(1,s.Area);
        % green
        stat = regionprops(cc, GREEN,'MeanIntensity');
        statIllum = [stat.MeanIntensity]';
        stats_eccen = regionprops( cc, GREEN, 'Eccentricity');
        Eccentricity = [stats_eccen.Eccentricity]';
        stats_eccen = regionprops( cc, GREEN, 'MajorAxisLength');
        MajorAxisLength = [stats_eccen.MajorAxisLength]';
        stats_eccen = regionprops( cc, GREEN, 'MinorAxisLength');
        MinorAxisLength = [stats_eccen.MinorAxisLength]';

        GREEN_param = [statIllum, Eccentricity, MajorAxisLength, MinorAxisLength];

        % blue
        stat = regionprops(cc, BLUE,'MeanIntensity');
        statIllumBl = [stat.MeanIntensity]';

        % red
        stat = regionprops(cc, RED,'MeanIntensity');
        statIllumRed = [stat.MeanIntensity]';

        % brightness correction using neighboring intensity
        if strcmp(options.Object, 'bacteria')
            [RedVal,GreenVal] = NeighborBrightnessAdjustment(cc,M, RED, GREEN);
        else
            RedVal=NaN(1,cc.NumObjects);
            GreenVal = NaN(1,cc.NumObjects);
        end
        A = [Ob', FRAME, OPTICAL, centroids, area, GREEN_param, statIllumBl,statIllumRed,...
        RedVal',GreenVal'];
    else
        A = [];
    end
    % save parameters
    fileID = fopen(txt_name,'w');
    fprintf(fileID,'%12s %12s %12s %6s %6s %12s %15s %15s %15s %15s %15s %15s %15s %15s\n','ObjectNum','Frame','Optical','X','Y','area','GreenMeanInten','GreenEccentr',...
        'GreenMajAxis','GreenMinAxis','BlueMeanInt','RedMeanInt', 'RedMedNeigh', 'GreenMedNeigh');

    fprintf(fileID,'%12.0f %12.0f %12.0f %6.0f %6.0f %12.3f %15.1f %15.4f %15.1f %15.1f %15.1f %15.1f %15.1f %15.1f\n', A');
    fclose(fileID);
    
    
    
    
    
function [RedVal,GreenVal] = NeighborBrightnessAdjustment(cc, M, red, green)
    s = regionprops(cc,'basic');
    rect = round(cat(1,s.BoundingBox));  
    RedVal = zeros(1, cc.NumObjects);
    GreenVal = zeros(1, cc.NumObjects);
    seOut = strel('disk',8);
    seIn = strel('disk',4);
    shift = 2*max(max(rect(:,3:4)))+2;
    
    for i=1:cc.NumObjects

        rect2 = rect(i,:);
        if shift > rect2(1) || shift > rect2(2) || rect2(1)+shift>size(red,2) || rect2(2)+shift>size(red,1)
            shift = 0;
        end            
        %         figure, imshow(imadjust(redIm),[])
        cropVec = [rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift];
        maskInit = imcrop(M,cropVec);
        redIm = imcrop(red,cropVec);
        greenIm = imcrop(green,cropVec);

        maskDil1 = imdilate(maskInit,seIn);
        maskDil2 = imdilate(maskInit,seOut);
        Ring = abs(maskDil2 - maskDil1);

        imRing = double(redIm).*Ring;
        vecIm = imRing(imRing~=0);        
        RedVal(i) = median(vecIm);

        imRingGreen = double(greenIm).*Ring;
        vecImGreen = imRingGreen(imRingGreen~=0);
        GreenVal(i) = median(vecImGreen); 
    end