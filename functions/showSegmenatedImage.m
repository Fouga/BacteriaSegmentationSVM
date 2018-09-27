function showSegmenatedImage(M, red, green, blue,varargin)

if nargin == 4
    
    thresh_red = 2000;
    thresh_green = 1600;
    thresh_blue = 800;
elseif nargin == 5
    % read txt from model
    options = varargin{1};
  
    if ~exist(fullfile([options.model_name '.txt']),'file')
        thresh_red = 2000;
        thresh_green = 1600;
        thresh_blue = 800;
    else
        % read txt from model
        TableOptions = readtable (fullfile([options.model_name '.txt']));
        thresh_red = TableOptions.redThresh;
        thresh_green = TableOptions.greenThresh;
        thresh_blue = TableOptions.blueThresh;
    end
end


rgbIm = rgb16bit_to_8bit(red, green, blue,[thresh_red thresh_green thresh_blue]);

cc = bwconncomp(M,8);
s = regionprops(cc,'basic');
centroids = cat(1, s.Centroid);
if cc.NumObjects~=0
    figure,imshow(rgbIm)
    hold on
        plot(centroids(:,1),centroids(:,2), 'b*')
    hold off
    title('The image with segmented objects')
    pause(3);
else
    disp('no objects found')
end
%%
if nargin == 5
if strcmp(options.Object,'neutrophil') 
    bw4_perim = bwperim(M);
    overlay = imoverlay(rgbIm, bw4_perim);
    figure, imshow(overlay), title('Overlay with object borders.')
    pause(3)
end
end

