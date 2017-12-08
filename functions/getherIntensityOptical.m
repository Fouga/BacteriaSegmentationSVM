function RATIO = getherIntensityOptical(RED_MASK,RED, GREEN,BLUE)

RGBbacteria = cell(1,5);
% colors = ['b';'r';'g';'c';'m'];
% figure, 
Mgreen = []; Mblue = []; Mred = [];
for optical = 1:5
    IND = [];
    mask = RED_MASK{optical};
    cc = bwconncomp(mask,8);
    red = RED{optical};
    green = GREEN{optical};
    blue = BLUE{optical};
    for i = 1:size(cc.PixelIdxList,2)
        IND = [IND;cc.PixelIdxList{i}];
    end
    RGBbacteria{optical} = [red(IND),green(IND),blue(IND)];
    Mgreen = [Mgreen; median(green(IND))];
    Mred = [Mred; median(red(IND))];
    Mblue = [Mblue; median(blue(IND))];

%   plot3(red(IND),green(IND),blue(IND),['*',colors(optical)])
%     hold on
end
% hold off

RATIO = [double(Mred)./double(Mred(1)),double(Mgreen)./double(Mgreen(1)), double(Mblue)./double(Mblue(1))];% red green blue