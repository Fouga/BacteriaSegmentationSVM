% amke a movie for new txt coordinates
%sourceD = '/media/natasha/0C81DABC57F3AF06/Data/brain/20171013_brain_MT_5wka/';

function [nameC, A] = makeMatCoodinates(source_dir,frames, opt)

read_dir = [source_dir 'Segmentation_results/'];

% load new txt
k = 1; A = [];
for frame = 1:frames
  if frame < 10 
      counter = strcat('00',int2str(frame)); 
  elseif frame < 100 
      counter = strcat('0',int2str(frame));   
  else
      counter = int2str(frame);   
  end
  name = strcat( 'section_', counter);
    for optical = 1:opt
        txt_name = [read_dir 'positions_', name, '_', int2str(optical),  '.txt'];
        fileID = fopen(txt_name,'r');
        numTotal = fscanf(fileID,'%f',[1 2]);
        Matr = fscanf(fileID,'%f',[4 Inf]);
        fclose(fileID);

      % slice #, coor1 coor2 illum
      a = [repmat(k,size(Matr,2),1), Matr' ];
      A = [A;a];
      k = k+1;
    end
end
nameC = [read_dir 'toxo_coordinate.mat'];
save(nameC,'A');