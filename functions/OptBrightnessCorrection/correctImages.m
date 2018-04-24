function ratio = correctImages(Model_needed, Model_change)

% [pth filter ext] = fileparts(source);
% pth2 = [pth '/**/'];
% 
% % store the source path in the options structure
% options.folder_source = pth2;  
% options.source = source; 
% % read all the files in d
% d = dir([options.folder_source filter ext]);
% % create a new field for all file names of the channel in options.
% options.ALLfilenames = cell(numel(d),1);
% 
% for i = 1:numel(d)
%     options.ALLfilenames{i} = [pth '/' d(i).name];
% end
% % store the number of source images into the options structure
% options.ALLnum_images_provided = numel(options.ALLfilenames);
% 
% NAMES = options.ALLfilenames;

m1 = Model_needed(Model_needed>0);
m2 = Model_change(Model_change>0);
ratio = (median(m1)/median(m2))^2
if ratio<1
    disp('No changes to the brightness')
    ratio = 1;
end
% switch options.Opticalmethod
%     case 'average'
%         % load all the images from the given channel into the memory
%         for z = 1:options.ALLnum_images_provided
%                 if mod(z,100) == 0; fprintf('.'); end  % progress to the command line
%                I = imread(NAMES{z});
%  
%  
%                Im = uint16(double(I).*ratio); 
%                imwrite(Im,[save_dir d(z).name]);
%         end
%     case 'cidre'
%         Model_cidre = Model_needed;
%         Model_cidre = imresize(Model_cidre, options.image_size, 'bilinear');
%         
%         for z = 1:options.ALLnum_images_provided
%                 if mod(z,100) == 0; fprintf('.'); end  % progress to the command line
%                I = imread(NAMES{z});
%                Im = uint16(double(I)./Model_cidre); 
%                imwrite(Im,[save_dir d(z).name]);
%         end
% end

