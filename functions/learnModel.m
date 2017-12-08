function SVMModel = learnModel(SVMModel_linear,RED_mask, RED, GREEN, BLUE)

%% show the image
red_lim = 1000;%input(prompt)%1786;
blue_lim = red_lim%1000;
green_lim = red_lim%1000;
l = RED;
l(l>red_lim)=red_lim;
im1_8 = uint8(double(l)./double(max(l(:)))*2^8);
m=GREEN;
m(m>green_lim)=green_lim;
im2_8 = uint8(double(m)./double(max(m(:)))*2^8);
n = BLUE;
n(n>blue_lim)=blue_lim;
im3_8 = uint8(double(n)./double(max(n(:)))*2^8);

rgbIm = cat(3, im1_8,im2_8,im3_8);
bw4_perim = bwperim(RED_mask);
overlay = imoverlay(rgbIm, bw4_perim);
figure, imshow(overlay, [])
hold on
cc = bwconncomp(RED_mask,4);
s = regionprops(cc,'basic');
centroids_area = cat(1, s.Centroid);
plot(centroids_area(:,1),centroids_area(:,2), 'y*')
hold off

% Construct a questdlg with three options
questTitle='Image Contrast'; 
start(timer('StartDelay',1,'TimerFcn',@(o,e)set(findall(0,'Tag',questTitle),'WindowStyle','normal')));
choice = questdlg('Are you happy with the segmentation?', questTitle, 'Yes','No','Yes');
switch choice
    case 'Yes'
        cont = 0;
    case 'No'
        cont = 1;
end


%% get new features
if cont == 0
    HSV = rgb2hsv(cat(3, RED, GREEN, BLUE));
    [row_backgr, col_backgr] = find(RED_mask==0 && HSV(:,:,3)>??);
    [row_foregr, col_foregr] =find(RED_mask==1);
    inD = sub2ind(size(im1_8),row_foregr,col_foregr);
    inDB = sub2ind(size(im1_8),row_backgr,col_backgr);

    x1 = horzcat(RED(inD),GREEN(inD),BLUE(inD));
    y1 = repmat(20,length(inD),1);

    x2 = horzcat(RED(inDB),GREEN(inDB),BLUE(inDB));
    y2 = repmat(66,length(inDB),1);
    X = [x1;x2];
    Y = [y1;y2];
    %%
    SVMModel = fitcsvm(double(X),Y,'Verbose',1);
    
else
    disp('No learning performed');
    SVMModel = SVMModel_linear;
end