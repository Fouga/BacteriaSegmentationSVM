function RED_mask = regionGrowingBacteria(RED_mask, red_8, gr_8, bl_8,patch)

threshold = 1539;
if patch ==1
    r=red_8;
    r(r>threshold)=threshold;
    im1_8 = uint8(double(r)./double(max(r(:)))*2^8);
else
    im1_8 = uint8(zeros(size(red_8)));
end
m=gr_8;
m(m>threshold)=threshold;
im2_8 = uint8(double(m)./double(max(m(:)))*2^8);

n = bl_8;
n(n>threshold)=threshold;
im3_8 = uint8(double(n)./double(max(n(:)))*2^8);
rgbIm = cat(3, im1_8,im2_8,im3_8);


cc = bwconncomp(RED_mask,8);
% find pixel with the brightest value
seeds = zeros(size(cc.PixelIdxList,2),2);
for Inten = 1: size(cc.PixelIdxList,2)
    IND = cc.PixelIdxList{:,Inten};
    [pixel_values,Ind_maxInt] = max(m(IND)+n(IND));
    [I,J] = ind2sub(size(m),IND(Ind_maxInt));
    seeds(Inten,:) = [J,I];
%     figure, imshow(rgbIm)
%     hold on
%     plot(J,I, 'r*')
%     hold off
end
s = regionprops(cc,'basic');
centroids_area = cat(1, s.Centroid);

rect = round(cat(1,s.BoundingBox));
% seeds = round(cat(1, s.Centroid));

BW_new = zeros(size(RED_mask)); J1_big = zeros(size(RED_mask));

for i =1:size(centroids_area,1)
    shift = 2*max(max(rect(:,3:4)))+2;
    % check if the seed is already in the mask
    [x,y] = find(BW_new>0);
    if (isempty(find(y==seeds(i,1) & x==seeds(i,2))) || isempty(x)) && patch~=1
        rect2 = rect(i,:);
        seed_point = seeds(i,:)-rect2(1:2)+shift/2+1;

        if shift > rect2(1) || shift > rect2(2) || rect2(1)+shift>size(rgbIm,2) || rect2(2)+shift>size(rgbIm,1)
%             shift = 2*min(rect2(3:4))-2;
%             Im = imcrop(rgbIm,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
%             seed_point = seeds(i,:)-rect2(1:2)+shift/2+1;
                        shift = 0;
            Im = imcrop(rgbIm,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
            seed_point = seeds(i,:)-rect2(1:2)+shift/2+1;
        else
            Im = imcrop(rgbIm,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
        end
%         overlay_patch = imcrop(overlay,[rect2(1)-shift/2 rect2(2)-shift/2 rect2(3)+shift rect2(4)+shift]);
%         figure,imshow(Im,[])
%         hold on
%         plot(seed_point(1), seed_point(2),'*r')
%         hold off
        % region growing
        IM = rgb2gray(Im);
        dist_inten = 100;
        [~,J1] = regionGrowing(IM,[seed_point(2) seed_point(1)],dist_inten); 
        if (length(find(J1==1))== size(IM,1)*size(IM,2) || length(find(J1==1))>10*length(cc.PixelIdxList{i}))
%             if i~=168
            J1 = zeros(size(IM));
            [P1,P2] = ind2sub(size(red_8),cc.PixelIdxList{i});
            Points =[P2,P1] -rect2(1:2)+shift/2+1;
            J1(sub2ind(size(J1),Points(:,2),Points(:,1))) = 1;
%             i  
%             else
%                 J1 = zeros(size(IM));
%                 [P1,P2] = ind2sub(size(red_8),cc.PixelIdxList{i});
%                 Points =[P2,P1] -rect2(1:2)+shift/2+1;
%                 J1(sub2ind(size(J1),Points(:,2),Points(:,1))) = 1;
%             end
        end
            
%         figure, imshow(J1)
%         bw_perim = bwperim(J1);
%         overlay_patch2 = imoverlay(Im, bw_perim);
%         figure,imshow(overlay_patch2,[])
%         pause
        % make a new mask
%         if size (IM,1)<rect2(4)+1
           sh1 = (rect2(4)+shift+1)-size(J1,1);
           sh2 = (rect2(3)+shift+1)-size(J1,2);
           if sh1~=0 || sh2~=0 % only if rectnagle is approaching right border of the image
               J1_big(rect2(2)-shift/2: rect2(2)+shift/2+rect2(4)-sh1, ...
                rect2(1)-shift/2 :rect2(1)+shift/2 +rect2(3)-sh2) = J1;
            
           else
               J1_big(rect2(2)-shift/2: rect2(2)+shift/2+rect2(4), ...
                rect2(1)-shift/2 :rect2(1)+shift/2 +rect2(3)) = J1;
           end
        BW_new = BW_new+J1_big;
        
    elseif (isempty(find(y==seeds(i,1) & x==seeds(i,2))) || isempty(x)) && patch==1
        seed_point = seeds(i,:);
        dist_inten = 20;
        IM = rgb2gray(rgbIm);
        [~,J1] = regionGrowing(IM,[seed_point(2) seed_point(1)],dist_inten); 
%           figure, imshow(J1)
%           pause
        BW_new = J1;
        
    end
end
RED_mask = BW_new>0; % logical image
% cc = bwconncomp(RED_mask,8);
% s = regionprops(cc,'basic');
% centroids_area = cat(1, s.Centroid);
% % if cc.NumObjects~=0
%     bw4_perim = bwperim(BW_new);
%     overlay = imoverlay(rgbIm, bw4_perim);
%     figure, imshow(overlay)
%     hold on
%     plot(centroids_area(:,1),centroids_area(:,2), 'r*')
%     hold off
% else
%     disp('No objects found')
% end
