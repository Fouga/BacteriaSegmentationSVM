function guiTestSVMModel(SVMModel,RED, GREEN, BLUE,rgbIm)

test = [RED(:),GREEN(:),BLUE(:)];

disp('Applying model to the image...')
[cpre,scores1] = predict(SVMModel,double(test));

IND= find(cpre==20);
RED_mask = zeros(size(RED));
RED_mask(IND) =1;

% find 8 connectivity
disp('Discarding small objects...')
cc = bwconncomp(RED_mask,8);
numPixels = cellfun(@numel,cc.PixelIdxList);
idX = find(numPixels<5);

for i=1:length(idX)
    RED_mask(cc.PixelIdxList{idX(i)}) = 0;
end
    
cc = bwconncomp(RED_mask,8);
s = regionprops(cc,'basic');
centroids = cat(1, s.Centroid);
if ~isempty(centroids)
    figure,imshow(rgbIm)
    hold on
    plot(centroids(:,1),centroids(:,2), 'b*')
    hold off
    title('The image with segmented objects')
    pause(3);
    %%
    bw4_perim = bwperim(RED_mask);
    overlay = imoverlay(rgbIm, bw4_perim);
    figure, imshow(overlay), title('Overlay with object borders.')
else 
    disp('there are no objects found :)')
end

    