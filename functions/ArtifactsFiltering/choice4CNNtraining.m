function choice4CNNtraining(frame,optical,options)

% if nargin > 4
%     doMask = varargin{1};
% end
% if nargin > 5
%     doSort = varargin{2};
% end
% save patches
% save_dir = fullfile(segmentation_dir, 'Patches');
% if ~exist(save_dir)
%     mkdir(save_dir)
% end
save_dir = options.CNNdataDir;

if frame < 10
  counter = strcat('00',int2str(frame)); 
elseif frame < 100 
  counter = strcat('0',int2str(frame));   
else
  counter = int2str(frame);   
end
prefix = 'section_';
name = strcat(prefix, counter);
mask_name = fullfile(options.folder_destination_perSlice,[name, '_0', int2str(optical) ,'.pbm']);
% load the mask
BW = imread(mask_name);
% visualize_vector = [[0 0.03]; [0 0.015];[0 0.015]]; % for spleen
visualize_vector = [[0 0.03]; [0 0.03];[0 0.03]]; % for brain

if sum(BW(:))>0
%     [pth filter ext] = fileparts(source_dir);
    ext = '.tif';
    green = imread(fullfile(options.folder_source, num2str(options.green), [name, '_0',  int2str(optical), ext]));
    red = imread(fullfile(options.folder_source, num2str(options.red), [name, '_0',  int2str(optical), ext]));
    blue =imread(fullfile(options.folder_source, num2str(options.blue), [name, '_0',  int2str(optical), ext]));

    im =  cat(3, red,green,blue);
%     if doMask
%        rgbIm = rgbIm.*uint16(BW);
%     end
        siz = [224 224];
%         if doSort
    if ~exist(fullfile(save_dir, 'Bacterium'))
        mkdir(fullfile(save_dir, 'Bacterium'))
    end
    if ~exist(fullfile(save_dir,  'notBact'))
        mkdir(fullfile(save_dir, 'notBact'))
    end
    cc = bwconncomp(BW,8);
    s = regionprops(cc,'basic');
    centroids = cat(1, s.Centroid);
    rect = round(cat(1,s.BoundingBox));
    PixelList = cat(1,cc.PixelIdxList);
    shift =5;% 
    for i =1:size(centroids,1)
        rect2 = rect(i,:);
        % take only pixel of the object
        mask = zeros(size(BW),'uint16');
        mask(PixelList{i}) = 1;
        % rgb image around the object      
        if shift > rect2(1) || shift > rect2(2) || rect2(1)+shift>size(im,2) || rect2(2)+shift>size(im,1)
            shift = 0;
%             Im = imcrop(im,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
            IM = imcrop(im,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        else
%             Im = imcrop(im,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
            IM = imcrop(im,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        end
        % for resnet 50
        cont = [];
        % Construct a questdlg with three options
        RGBIM  = cat(3,imadjust(im(:,:,1),visualize_vector(1,:),[]),...
            imadjust(im(:,:,2),visualize_vector(2,:),[]),imadjust(im(:,:,3),visualize_vector(3,:),[]));
        shift2 = 200;
        if shift2 > rect2(1) || shift2 > rect2(2) || rect2(1)+shift2>size(RGBIM,2) || rect2(2)+shift2>size(RGBIM,1)
            shift2 = 0;
            Im2 = imcrop(RGBIM,[rect2(1)-shift2/2 rect2(2)-shift2/2 rect2(3)+shift2 rect2(4)+shift2]);
            impl = imcrop(mask,[rect2(1)-shift2/2 rect2(2)-shift2/2 rect2(3)+shift2 rect2(4)+shift2]);

        else
            Im2 = imcrop(RGBIM,[rect2(1)-shift2/2 rect2(2)-shift2/2 rect2(3)+shift2 rect2(4)+shift2]);
            impl = imcrop(mask,[rect2(1)-shift2/2 rect2(2)-shift2/2 rect2(3)+shift2 rect2(4)+shift2]);
        end
        [x,y] = find(impl(:,:,1)>0);
        figure, imshow(Im2)
        truesize([1000 1000]);
        hold on
        plot(y(1:2:end),x(1:2:end), 'y*')
        hold off
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
          
%             Im = padarray(Im,[siz(1)-size(Im,1) siz(2)-size(Im,2)],'post');
        IM = padarray(IM,[siz(1)-size(IM,1) siz(2)-size(IM,2)],'post');

%             name  = sprintf('Frame_%i_optical_%i_Bacterium_%i.tif',frame,optical,i);
%             imwrite(Im,fullfile(save_dir_bact, name));
%             name2  = sprintf('Frame_%i_optical_%i_Bacterium_%i_patch.tif',frame,optical,i);
%             imwrite(IM,fullfile(save_dir_bact, name2));
        name3  = sprintf('Frame_%i_optical_0%i_Bacterium_%i_noRed.tif',frame,optical,i);
        IM(:,:,1) = zeros(size(IM(:,:,2)),'uint16'); 
        imwrite(IM,fullfile(save_dir_bact, name3));

        close all
    end
end
