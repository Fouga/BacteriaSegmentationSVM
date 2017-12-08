function [totalBinary_backr, totalBinary_foregr,rgbIm,options] = guiChooseRegions(RED, GREEN, BLUE,options)

cont =1;
while cont==1
    prompt = 'What is the RED color threshold? ';
    red_lim = input(prompt);
    prompt = 'What is the GREEN color threshold? ';
    green_lim = input(prompt);
    prompt = 'What is the BLUE color threshold? ';
    blue_lim = input(prompt);
    options.redThresh = red_lim;
    options.greenThresh = green_lim;
    options.blueThresh = blue_lim;

    % convert to 8bit
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

    figure, imshow(rgbIm, [])
    
    % Construct a questdlg with three options
    questTitle='Image Contrast'; 
    start(timer('StartDelay',1,'TimerFcn',@(o,e)set(findall(0,'Tag',questTitle),'WindowStyle','normal')));
    choice = questdlg('Are you happy with the image?', questTitle, 'Yes','No','Yes');
    switch choice
        case 'Yes'
            cont = 0;
            close all
        case 'No'
            cont = 1;
    end
    
end

% figure, subplot(1,2,1), imshow(grayImage, []);
figure, imshow(rgbIm, [])

% choose background
message = sprintf('Choose 5 SMALL BACKGROUND regions. \n It is important to pick ONLY background pixels!');
uiwait(msgbox(message));
hFH = imfreehand();
binaryImage = hFH.createMask();
totalBinary_backr = false(size(im1_8));
for k = 1:5
    totalBinary_backr = totalBinary_backr | binaryImage;
%     subplot(1,2,2); imshow(totalBinary_backr); 
%     drawnow

%     subplot(1,2,1);
    hFH = imfreehand();
    binaryImage = createMask(hFH);
end
totalBinary_backr = totalBinary_backr | binaryImage ;

% [row_backgr, col_backgr] = find(totalBinary_backr==1);
close all
pause(2);

%%%%%
figure, imshow(rgbIm, []);
message = sprintf('Choose 8 BACTERIA regions.\n It is important to pick ONLY object s pixels!');
uiwait(msgbox(message));
hFH = imfreehand();
binaryImage = hFH.createMask();
totalBinary_foregr = false(size(im1_8));
for k = 1:8
    totalBinary_foregr = totalBinary_foregr | binaryImage;
%     subplot(1,2,2); imshow(totalBinary_foregr); drawnow

%     subplot(1,2,1); 
    hFH = imfreehand();
    binaryImage = createMask(hFH);
end
totalBinary_foregr = totalBinary_foregr | binaryImage;
% [row_foregr, col_foregr] =find(totalBinary_foregr==1);
close all
pause(2);


