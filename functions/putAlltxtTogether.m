function putAlltxtTogether(options)

B = [];cnt = 1;% cnt is for verstical axis
for i = 1:options.number_of_frames*options.number_of_optic_sec
  % load images
    txt_name = fullfile(options.folder_destination_perSlice, ['positions_', options.ALLfilenames{i},  '.txt']);    
    A = readtable(txt_name);

    if ~isempty(A)
        Z = repmat(cnt,size(A,1),1);
        A = addvars(A,Z,'Before','area');
        B = [B;A];
    end
    cnt = cnt+1;
 
end
txt_name = fullfile(options.folder_destination,[ 'Allpositions', '.txt']);    
writetable(B,txt_name);
    
    
