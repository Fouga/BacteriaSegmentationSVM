function showSegmenatedImage(M, red, green, blue)

% read txt from model
thresh1 = 2000;
thresh2 = 1600;
thresh3 = 800;


l = red;
l(l>thresh1)=thresh1;
im1_8 = uint8(double(l)./double(max(l(:)))*2^8);
m=green;
m(m>thresh2)=thresh2;
im2_8 = uint8(double(m)./double(max(m(:)))*2^8);
n = blue;
n(n>thresh3)=thresh3;
im3_8 = uint8(double(n)./double(max(n(:)))*2^8);

rgbIm = cat(3, im1_8,im2_8,im3_8);
cc = bwconncomp(M,8);
s = regionprops(cc,'basic');
centroids = cat(1, s.Centroid);
figure,imshow(rgbIm)
hold on
if cc.NumObjects~=0
    plot(centroids(:,1),centroids(:,2), 'b*')
end
hold off
title('The image with segmented objects')
pause(3);
%%
bw4_perim = bwperim(M);
overlay = imoverlay(rgbIm, bw4_perim);
figure, imshow(overlay), title('Overlay with object borders.')

