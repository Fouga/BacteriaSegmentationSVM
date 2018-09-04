function  M = discardNonBacteriaCNN(red, green, blue,M,options)

options.Debag =1

net = options.net;
featureLayer = options.featureLayer;
classifier = options.classifier;


% size of the images for the resnet50 network
imageSize = options.imageSizeCNN;
cc = bwconncomp(M,8);
s = regionprops(cc,'basic');
rect = round(cat(1,s.BoundingBox));
PixelList = cat(1,cc.PixelIdxList);
shift =10;% 
if options.Debag == 1
    shiftVisu = 200;
end
categories = {'Bacterium', 'notBact'};
im =  cat(3, red,green,blue);
% imdsNew = imageDatastore(fullfile(rootFolder, 'newImages','bacts'),'FileExtensions',{'.tif'});
for i =1:cc.NumObjects
    rect2 = rect(i,:);
    mask1 = zeros(size(M),'uint16');
    mask1(PixelList{i})=1;    
    % make an RGB image with only 1 object 
    im1=im(:,:,1).*mask1;
    im2=im(:,:,2).*mask1;
    im3=im(:,:,3).*mask1;
    rgbIm1object =  cat(3, im1,im2,im3);

    if shift > rect2(1) || shift > rect2(2) || rect2(1)+shift>size(im,2) || rect2(2)+shift>size(im,1)
        shift = 0;
        Im = imcrop(rgbIm1object,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        if options.Debag == 1 && (shiftVisu > rect2(1) || shiftVisu > rect2(2) || rect2(1)+shiftVisu>size(im,2) || rect2(2)+shiftVisu>size(im,1))
            rgbImcrop = imcrop(im,[rect2(1)-shiftVisu/2 rect2(2)-shiftVisu/2 rect2(3)+shiftVisu rect2(4)+shiftVisu]);
            impl = imcrop(mask1,[rect2(1)-shiftVisu/2 rect2(2)-shiftVisu/2 rect2(3)+shiftVisu rect2(4)+shiftVisu]);%to highlight mask pixels

        end
    else
        Im = imcrop(rgbIm1object,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        if options.Debag == 1 && ~(shiftVisu > rect2(1) || shiftVisu > rect2(2) || rect2(1)+shiftVisu>size(im,2) || rect2(2)+shiftVisu>size(im,1))
            rgbImcrop = imcrop(im,[rect2(1)-shiftVisu/2 rect2(2)-shiftVisu/2 rect2(3)+shiftVisu rect2(4)+shiftVisu]);
            impl = imcrop(mask1,[rect2(1)-shiftVisu/2 rect2(2)-shiftVisu/2 rect2(3)+shiftVisu rect2(4)+shiftVisu]);%to highlight mask pixels

        end
    end
    % remove red channel
    Im(:,:,1) = zeros(size(Im(:,:,2)),'uint16'); 
    
    
    newImage= padarray(Im,[imageSize(1)-size(Im,1) imageSize(2)-size(Im,2)],'post');

    % Create augmentedImageDatastore to automatically resize the image when
    % image features are extracted using activations.
    ds = augmentedImageDatastore(imageSize, newImage);

    % Extract image features using the CNN
    imageFeatures = activations(net, ds, featureLayer, 'OutputAs', 'columns');
 
    % Make a prediction using the classifier
    label = predict(classifier, imageFeatures, 'ObservationsIn', 'columns');
    if label==categories{2} 
        if options.Debag == 1
            [x,y] = find(impl(:,:,1)>0);
            RGBIM = rgb16bit_to_8bit(rgbImcrop(:,:,1), rgbImcrop(:,:,2), rgbImcrop(:,:,3),[2500 1600 1200]);

            figure, imshow(RGBIM,[]), hold on 
               plot(y(1:end),x(1:end), 'y*'); hold off
            pause
%             frame = 1;
%             optical = 1;
            save_dir_bact = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/Segmentation_results_bacteria/tmp_notBact/';
            %notBact/';
            name3  = sprintf('Bacterium_%i_noRed.tif',i);
            imwrite(newImage,fullfile(save_dir_bact, name3));
             name4  = sprintf('BacteriumRGB_%i_noRed.tif',i);
            imwrite(RGBIM,fullfile(save_dir_bact, name4));
        end
        M(PixelList{i})=0;
    end
    
end