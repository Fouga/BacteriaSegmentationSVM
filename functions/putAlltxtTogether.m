function putAlltxtTogether(options)

B = [];cnt = 1;
for frame = 1:options.number_of_frames
  % load images
    if frame < 10 
      counter = strcat('00',int2str(frame)); 
    elseif frame < 100 
      counter = strcat('0',int2str(frame));   
    else
      counter = int2str(frame);   
    end
    name = strcat('section_', counter);
    for optical=1:options.number_of_optic_sec
        txt_name = [options.saving_dir 'positions_', name, '_', int2str(optical),  '.txt'];    
        A = readtable(txt_name,'Format', '%12.0f %12.0f %12.0f %6.0f %6.0f %12.3f %15.1f %15.4f %15.1f %15.1f %15.1f %15.1f %15.1f %15.1f');

        if ~isempty(A)
            z = repmat(cnt,size(A,1),1);
            A = addvars(A,z,'Before','area');
            B = [B;A];
        end
        cnt = cnt+1;
        
    end
        
end
txt_name = [options.saving_dir 'Allpositions', '.txt'];    
% writetable(B,txt_name,'Delimiter',' ');

C = B{:,{'ObjectNum','Frame','Optical','X','Y','z','area','GreenMeanInten','GreenEccentr',...
        'GreenMajAxis','GreenMinAxis','BlueMeanInt','RedMeanInt', 'RedMedNeigh', 'GreenMedNeigh'}};
    
fileID = fopen(txt_name,'w');
fprintf(fileID,'%12s %12s %12s %6s %6s %6s %12s %15s %15s %15s %15s %15s %15s %15s %15s\n','ObjectNum','Frame','Optical','X','Y','Z','area','GreenMeanInten','GreenEccentr',...
    'GreenMajAxis','GreenMinAxis','BlueMeanInt','RedMeanInt', 'RedMedNeigh', 'GreenMedNeigh');

fprintf(fileID,'%12.0f %12.0f %12.0f %6.0f %6.0f %6.0f %12.3f %15.1f %15.4f %15.1f %15.1f %15.1f %15.1f %15.1f %15.1f\n', C');
fclose(fileID);