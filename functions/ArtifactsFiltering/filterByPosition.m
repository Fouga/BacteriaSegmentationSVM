function A = filterByPosition(A,options)
% filter if x,y,z position of a neighbor is less than a threshold distance
% x,y distance threshold is 5 micron and z - 11 micron
xy_res = options.xres;
Zmicron = A.Frame*50 + A.Optical*10;% in micron
flag = zeros(1, size(A,1));
x = A.X;
y = A.Y;
% z = A.Z;
cherry = A.GreenMeanInten;
for p = 1:size(A,1)
    for q = 1:size(A,1)
        if p ~= q && flag(q) ~= 1 && flag(p) ~= 1
            xy_distance = sqrt((x(p)-x(q))^2 + (y(p)-y(q))^2);      
            z_dist = abs(Zmicron(p)-Zmicron(q));
            if xy_distance < 5/xy_res && z_dist < 11
                if cherry( p) > cherry( q)
                 flag(q) = 1;
                 cherry(p) = cherry(p) + cherry(q);
                else
                 flag(p) = 1;
                 cherry(q) = cherry(p) + cherry(q);
                end
            end
        end
    end
end
% rewrite new intensities obtained with neighbor filtering
A.GreenMeanInten = cherry;
A = addvars(A,Zmicron,'Before','area');
RemoveA = A(logical(flag),:); 
A(logical(flag),:) = [];                

% apply to the segmented txt and masks
if sum(flag)>0 
    if ~exist(fullfile(options.folder_destination,'FilteredSegmenatationPerSlice'))
%         mkdir(fullfile(options.folder_destination,'FilteredSegmenatationPerSlice'));
        options.folder_destination_FilteredperSlice = fullfile(options.folder_destination,'FilteredSegmenatationPerSlice');
        copyfile(options.folder_destination_perSlice, options.folder_destination_FilteredperSlice)
    end
    flagDel = ones(1,size(RemoveA,1));
    for i = 1:size(RemoveA,1)
   
        frame = RemoveA.Frame(i);
      % load images
        if frame < 10 
          counter = strcat('00',int2str(frame)); 
        elseif frame < 100 
          counter = strcat('0',int2str(frame));   
        else
          counter = int2str(frame);   
        end
        name = strcat('section_', counter);
        optical= RemoveA.Optical(i);
        mask_name = fullfile(options.folder_destination_FilteredperSlice, [name, '_0', int2str(optical) ,'.pbm']);
        txt_name = fullfile(options.folder_destination_FilteredperSlice, ['positions_', name, '_0', int2str(optical),  '.txt']);  

        if flagDel(i)==1
        
        fprintf('Deleting objects in frame %i optical %i\nGreen Intensity is not changed in the position_*.txt BUT saved in the Allpositions_filter3D.txt\n',frame, optical);
        
       
        mask = imread(mask_name);
        PositionTxt = readtable(txt_name);

        cc = bwconncomp(mask,8);
        % index in RemoveA 
        OtherObj = find( RemoveA.Frame==frame & RemoveA.Optical==optical);
        ObjectDelete = zeros(1,length(OtherObj));
        for j = 1:length(OtherObj)
            objInd = OtherObj(j);
            % index in objects detection
            ObjectDelete(j) = RemoveA.ObjectNum(objInd);
            Pixs = cc.PixelIdxList{ObjectDelete(j)};
            mask(Pixs) = 0;
            flagDel( OtherObj(j)) = 0; 
        end
        save_image(mask, mask_name);


        PositionTxt(ObjectDelete,:) = [];
        writetable(PositionTxt,txt_name);
        end
    end
end

