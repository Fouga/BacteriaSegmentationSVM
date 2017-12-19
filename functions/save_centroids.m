function save_centroids(cc,Channel, txt_name)

    s = regionprops(cc,'basic');
    centroids = cat(1, s.Centroid);
    area =cat(1,s.Area);
    
    stat = regionprops(cc, Channel,'MeanIntensity');
    statIllum = [stat.MeanIntensity]';
    illumination = area.*statIllum/1000;
    fileID = fopen(txt_name,'w');

    fprintf(fileID,'%10.1f\n',size(centroids,1));
    A = [centroids,area,illumination];
    fprintf(fileID,'%10.1f %10.1f %10.1f %10.1f\n',A');
    fclose(fileID);