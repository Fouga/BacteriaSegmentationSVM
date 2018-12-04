function visualizeModel(model_name,varargin)

Axis_scale ='pixels';
if nargin>1
    Axis_scale = varargin{1};
end

load([model_name '.mat'],'SVMModel');

mdl = SVMModel;

X = SVMModel.X;
Y = SVMModel.Y;
%  sv =  mdl.SupportVectors;
%set step size for finer sampling
d =50;%0.05;
if strcmp(Axis_scale,'log') 
    Ind = X(:,1)==0;
    X(Ind,:) = [];
    Y(Ind,:) = [];

    Ind = X(:,2)==0;
    X(Ind,:) = [];
    Y(Ind,:) = [];

    Ind = X(:,3)==0;
    X(Ind,:) = [];
    Y(Ind,:) = [];
end

group = zeros(size(Y));
group(Y==20)=1;

%generate grid for predictions at finer sample rate
[x, y, z] = meshgrid(min(X(:,1)):d:max(X(:,1)),...
    min(X(:,2)):d:max(X(:,2)), min(X(:,3)):d:max(X(:,3)));
xGrid = [x(:),y(:),z(:)];

%get scores, f
[ ~ , f] = predict(mdl,xGrid);


%  %reshape to same grid size as the input
f = reshape(f(:,2), size(x));

if strcmp(Axis_scale,'log') 
    X = log10(X);
    f = real(log10(f));
    x = log10(x);
    y = log10(y);
    z = log10(z);

end


% Assume class labels are 1 and 0 and convert to logical
t = logical(group);
% if strcmp(Axis_scale,'pixels') 
 %plot data points, color by class label
figure
plot3(X(t, 1), X(t, 2), X(t, 3), 'r.');
hold on
plot3(X(~t, 1), X(~t, 2), X(~t, 3), 'b.');
hold on

 % load unscaled support vectors for plotting
%  plot3(sv(:, 1), sv(:, 2), sv(:, 3), 'go');

 %plot decision surface
[faces,verts,~] = isosurface(x, y, z, f, 0, x);
patch('Vertices', verts, 'Faces', faces, 'FaceColor','k','edgecolor', ...
'none', 'FaceAlpha', 0.2);
grid on
box on
view(3)
hold off

