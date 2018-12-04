function         buildBacteriaTrainingSet(sourceD,frame,optical,segmentation_dir,trainingSave_dir, varargin)


if nargin > 5
    thresh = varargin{1};
    thresh_red = thresh(1);
    thresh_green = thresh(2);
    thresh_blue = thresh(3);
else
    thresh_red = 2000;
    thresh_green = 1600;
    thresh_blue = 800;
end


% save patches
save_dir = fullfile(trainingSave_dir);
if ~exist(save_dir)
    mkdir(save_dir)
end
if ~exist(fullfile(save_dir, 'Bacterium'))
    mkdir(fullfile(save_dir, 'Bacterium'))
end
if ~exist(fullfile(save_dir,  'notBact'))
    mkdir(fullfile(save_dir, 'notBact'))
end
% convnet parameters
shift =10; % number of pixels cut from an image around an object
siz = [224 224]; % size for the final cropped image. It should fit the network requirements 

if frame < 10
  counter = strcat('00',int2str(frame)); 
elseif frame < 100 
  counter = strcat('0',int2str(frame));   
else
  counter = int2str(frame);   
end
prefix = 'section_';
name = strcat(prefix, counter);
% load a mask after svm segmentation 
mask_name = fullfile(segmentation_dir, [name, '_0' int2str(optical) ,'.pbm']);
BW = imread(mask_name);

if sum(BW(:))>0
    ext = '.tif';
    green = imread(fullfile(sourceD, '2',[name, '_0',  int2str(optical), ext]));
    red = imread(fullfile(sourceD, '1', [name, '_0',  int2str(optical), ext]));
    blue = imread(fullfile(sourceD, '3', [name, '_0',  int2str(optical), ext]));
    rgbIm =  cat(3, red,green,blue);
    cc = bwconncomp(BW,8);
    s = regionprops(cc,'basic');
    centroids = cat(1, s.Centroid);
    rect = round(cat(1,s.BoundingBox));
    PixelList = cat(1,cc.PixelIdxList);
    
    for i =1:size(centroids,1)
        rect2 = rect(i,:);
        mask1 = zeros(size(BW),'uint16');
        mask1(PixelList{i})=1;    
        % make an RGB image with only 1 object 
        im1=rgbIm(:,:,1).*mask1;
        im2=rgbIm(:,:,2).*mask1;
        im3=rgbIm(:,:,3).*mask1;
        rgbIm1object =  cat(3, im1,im2,im3);

        if shift > rect2(1) || shift > rect2(2) || rect2(1)+shift>size(red,2) || rect2(2)+shift>size(red,1)
            % if an object is clode to the image border
            shift = 0;
            IM = imcrop(rgbIm1object,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        else
            IM = imcrop(rgbIm1object,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        end

        cont = [];
        % Construct a questdlg with three options
        RGBIM = rgb16bit_to_8bit(red, green, blue,[thresh_red thresh_green thresh_blue]); % for visulalization
        shift2 = 200; % for visualization

        if shift2 > rect2(1) || shift2 > rect2(2) || rect2(1)+shift2>size(RGBIM,2) || rect2(2)+shift2>size(RGBIM,1)
            shift2 = 0;
            Im2 = imcrop(RGBIM,[rect2(1)-shift2/2 rect2(2)-shift2/2 rect2(3)+shift2 rect2(4)+shift2]);
            impl = imcrop(mask1,[rect2(1)-shift2/2 rect2(2)-shift2/2 rect2(3)+shift2 rect2(4)+shift2]);%to highlight mask pixels

        else
            Im2 = imcrop(RGBIM,[rect2(1)-shift2/2 rect2(2)-shift2/2 rect2(3)+shift2 rect2(4)+shift2]);
            impl = imcrop(mask1,[rect2(1)-shift2/2 rect2(2)-shift2/2 rect2(3)+shift2 rect2(4)+shift2]);
        end
        [x,y] = find(impl(:,:,1)>0);
        figure, imshow(Im2)
        truesize([1000 1000]); hold on
        plot(y(1:2:end),x(1:2:end), 'y*'); hold off
        pause(1)
        questTitle='Sort bacteria'; 
        start(timer('StartDelay',1,'TimerFcn',@(o,e)set(findall(0,'Tag',questTitle),'WindowStyle','normal')));
        choice = questdlg('Is it a bacterium?', questTitle, 'Yes','No','Yes');
        switch choice
            case 'Yes'
                cont = 0;
            case 'No'
                cont = 1;
        end
        if cont ==0
            save_dir_bact = fullfile(save_dir, 'Bacterium');
        elseif cont ==1
             save_dir_bact = fullfile(save_dir, 'notBact');
        end
        % pad image to fit network size
        IM = padarray(IM,[siz(1)-size(IM,1) siz(2)-size(IM,2)],'post');
%         name2  = sprintf('Frame_%i_optical_%i_Bacterium_%i_patch.tif',frame,optical,i);
%         imwrite(IM,fullfile(save_dir_bact, name2));
        name3  = sprintf('Frame_%i_optical_%i_Bacterium_%i_noRed.tif',frame,optical,i);
        IM(:,:,1) = zeros(size(IM(:,:,2)),'uint16'); 
        imwrite(IM,fullfile(save_dir_bact, name3));
        close all
    end
end
