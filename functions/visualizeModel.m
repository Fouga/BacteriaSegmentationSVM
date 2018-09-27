function visualizeModel(model_name)

load([model_name '.mat'],'SVMModel');
% X = SVMModel.X;
% Y = SVMModel.Y;
% x1 = X(Y==20,:);
% x2 = X(Y==66,:);
% 
% figure, plot3(x1(:,1),x1(:,2),x1(:,3),'r*')
% hold on
% plot3(x2(:,1),x2(:,2),x2(:,3),'bo')
% hold off
% title('RGB values distribution for the chosen areas')
% xlabel ('RED')
% ylabel ('GREEN')
% zlabel ('BLUE')
% legend('object','backgr')

mdl = SVMModel;
X = SVMModel.X;
Y = SVMModel.Y;
group = zeros(size(Y));
group(Y==20)=1;
%%
 sv =  mdl.SupportVectors;

 %set step size for finer sampling
 d =50;%0.05;

 %generate grid for predictions at finer sample rate
 [x, y, z] = meshgrid(min(X(:,1)):d:max(X(:,1)),...
    min(X(:,2)):d:max(X(:,2)), min(X(:,3)):d:max(X(:,3)));
 xGrid = [x(:),y(:),z(:)];

 %get scores, f
 [ ~ , f] = predict(mdl,xGrid);

 %reshape to same grid size as the input
 f = reshape(f(:,2), size(x));

 % Assume class labels are 1 and 0 and convert to logical
 t = logical(group);

 %plot data points, color by class label
 figure
 plot3(X(t, 1), X(t, 2), X(t, 3), 'r.');
 hold on
 plot3(X(~t, 1), X(~t, 2), X(~t, 3), 'b.');
 hold on

 % load unscaled support vectors for plotting
 plot3(sv(:, 1), sv(:, 2), sv(:, 3), 'go');

 %plot decision surface
 [faces,verts,~] = isosurface(x, y, z, f, 0, x);
 patch('Vertices', verts, 'Faces', faces, 'FaceColor','k','edgecolor', ...
 'none', 'FaceAlpha', 0.2);
 grid on
 box on
 view(3)
 hold off
