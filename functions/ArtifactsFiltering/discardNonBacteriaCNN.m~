function  M = discardNonBacteriaCNN(red, green, blue,M,net,featureLayer,classifier,options)


% size of the images for the resnet50 network
imageSize = options.imageSizeCNN;
cc = bwconncomp(M,8);
s = regionprops(cc,'basic');
rect = round(cat(1,s.BoundingBox));
PixelList = cat(1,cc.PixelIdxList);
shift =5;% 
categories = {'Bacterium', 'notBact'};
im =  cat(3, red,green,blue);
% imdsNew = imageDatastore(fullfile(rootFolder, 'newImages','bacts'),'FileExtensions',{'.tif'});
for i =1:cc.NumObjects
    rect2 = rect(i,:);
%     im = zeros(size(red),'uint16');
%     mask1 = zeros(size(M),'uint16');
%     mask1(PixelList{i})=1;
%     im1=red.*mask1;
%     im2=green.*mask1;
%     im3=blue.*mask1;
%     im(:,:,1) = im1;
%     im(:,:,2) = im2;
%     im(:,:,3) = im3;


    if shift > rect2(1) || shift > rect2(2) || rect2(1)+shift>size(im,2) || rect2(2)+shift>size(im,1)
        shift = 0;
        Im = imcrop(im,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
%         IM = imcrop(rgbIm,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
    else
        Im = imcrop(im,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
%         IM = imcrop(rgbIm,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
    end
    Im(:,:,1) = zeros(size(Im(:,:,2)),'uint16'); 
    newImage= padarray(Im,[imageSize(1)-size(Im,1) imageSize(2)-size(Im,2)],'post');
%     newImage = readimage(imdsNew,i);

    % Create augmentedImageDatastore to automatically resize the image when
    % image features are extracted using activations.
    ds = augmentedImageDatastore(imageSize, newImage);

    % Extract image features using the CNN
    imageFeatures = activations(net, ds, featureLayer, 'OutputAs', 'columns');

    % Make a prediction using the classifier
    label = predict(classifier, imageFeatures, 'ObservationsIn', 'columns');
    if label==categories{2} 
visualize_vector = [[0 0.03]; [0 0.03];[0 0.03]]; % for brain
      RGBIM  = cat(3,imadjust(newImage(:,:,1),visualize_vector(1,:),[]),...
            imadjust(newImage(:,:,2),visualize_vector(2,:),[]),imadjust(newImage(:,:,3),visualize_vector(3,:),[]));
        figure, imshow(RGBIM,[])
        M(PixelList{i})=0;
    end
    
end