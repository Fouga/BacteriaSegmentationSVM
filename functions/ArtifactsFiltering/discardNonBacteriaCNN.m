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
shift =30;% 
if options.Debag == 1
    shiftVisu = 200;
end
categories = {options.Labels{1}, options.Labels{2}};
rgbIm =  cat(3, red,green,blue);
% imdsNew = imageDatastore(fullfile(rootFolder, 'newImages','bacts'),'FileExtensions',{'.tif'});
for i =1:cc.NumObjects
    rect2 = rect(i,:);
    mask1 = zeros(size(M),'uint16');
    mask1(PixelList{i})=1;    
    % make an RGB image with only 1 object 
    %im1=im(:,:,1).*mask1;
    %im2=im(:,:,2).*mask1;
    %im3=im(:,:,3).*mask1;
    %rgbIm1object =  cat(3, im1,im2,im3);
    if shift > rect2(1) || shift > rect2(2) || rect2(1)+shift>size(red,2) || rect2(2)+shift>size(red,1)
        % if an object is clode to the image border
        shift = 0;
        IM = imcrop(rgbIm,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
    else
        IM = imcrop(rgbIm,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
    end
        
        
    if shift > rect2(1) || shift > rect2(2) || rect2(1)+shift>size(red,2) || rect2(2)+shift>size(red,1)
        shift = 0;
%         Im = imcrop(rgbIm1object,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        if options.Debag == 1 && ( (shiftVisu > rect2(1) || shiftVisu > rect2(2) || rect2(1)+shiftVisu>size(red,2) || rect2(2)+shiftVisu>size(red,1)) )
            rgbImcrop = imcrop(rgbIm,[rect2(1)-shiftVisu/2 rect2(2)-shiftVisu/2 rect2(3)+shiftVisu rect2(4)+shiftVisu]);
            impl = imcrop(mask1,[rect2(1)-shiftVisu/2 rect2(2)-shiftVisu/2 rect2(3)+shiftVisu rect2(4)+shiftVisu]);%to highlight mask pixels

        end
    else
%         Im = imcrop(rgbIm1object,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        if options.Debag == 1 && (~(shiftVisu > rect2(1) || shiftVisu > rect2(2) || rect2(1)+shiftVisu>size(red,2) || rect2(2)+shiftVisu>size(red,1)) )
            rgbImcrop = imcrop(rgbIm,[rect2(1)-shiftVisu/2 rect2(2)-shiftVisu/2 rect2(3)+shiftVisu rect2(4)+shiftVisu]);
            impl = imcrop(mask1,[rect2(1)-shiftVisu/2 rect2(2)-shiftVisu/2 rect2(3)+shiftVisu rect2(4)+shiftVisu]);%to highlight mask pixels

        end
    end
    % remove red channel
    IM(:,:,1) = zeros(size(IM(:,:,2)),'uint16'); 
    
    
    newImage= padarray(IM,[imageSize(1)-size(IM,1) imageSize(2)-size(IM,2)],'post');

    % Create augmentedImageDatastore to automatically resize the image when
    % image features are extracted using activations.
    ds = augmentedImageDatastore(imageSize, newImage);

    % Extract image features using the CNN
    imageFeatures = activations(net, ds, featureLayer, 'OutputAs', 'columns');
 
    % Make a prediction using the classifier
    label = predict(classifier, imageFeatures, 'ObservationsIn', 'columns')
%     if label==categories{2} 
        if options.Debag == 1
            [x,y] = find(impl(:,:,1)>0);
            RGBIM = rgb16bit_to_8bit(rgbImcrop(:,:,1), rgbImcrop(:,:,2), rgbImcrop(:,:,3),[2000 1800 1800]);
            figure, imshow(RGBIM,[],'InitialMagnification',500), hold on 
               plot(y(1:end),x(1:end), 'y*'); hold off
               title(options.Labels{2})
            pause(3)
%             frame = 1;
%             optical = 1;
%             save_dir_bact = '/media/natasha/0C81DABC57F3AF06/Data/Spleen_data/20170223_D5_GFPfil/Segmentation_results_bacteria/tmp_notBact/';
           save_dir_bact = '/home/natasha/Programming/Matlab_wd/Projects_Biozentrum/Data_analysis/CNN_for_singleBacteria/TrainingSingleMultiple/test/';
           print(fullfile(save_dir_bact, sprintf('Print_frame%i_opt%i_ind%i.png',options.frame, options.optical,i)),'-dpng')
           name3  = sprintf('frame%i_opt%i_ind%i.tif',options.frame, options.optical,i);
           imwrite(newImage,fullfile(save_dir_bact, name3)); 
           name4  = sprintf('RGB_frame%i_opt%i_ind%i.tif',options.frame, options.optical,i);
           imwrite(RGBIM,fullfile(save_dir_bact, name4));
        end
        M(PixelList{i})=0;
        close all
%     end
    
end