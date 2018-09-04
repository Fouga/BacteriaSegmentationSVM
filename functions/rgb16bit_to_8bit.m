function  rgb8bit = rgb16bit_to_8bit(red, green, blue,varargin)

if nargin > 3
    thresh = varargin{1};
    thresh_red = thresh(1);
    thresh_green = thresh(2);
    thresh_blue = thresh(3);
else
    thresh_red = 2500;
    thresh_green = 1600;
    thresh_blue = 1200;
end


l = red;
l(l>thresh_red)=thresh_red;
im1_8 = uint8(double(l)./double(max(l(:)))*2^8);
m=green;
m(m>thresh_green)=thresh_green;
im2_8 = uint8(double(m)./double(max(m(:)))*2^8);
n = blue;
n(n>thresh_blue)=thresh_blue;
im3_8 = uint8(double(n)./double(max(n(:)))*2^8);

rgb8bit = cat(3, im1_8, im2_8, im3_8);