function [SVMModel,X,Y] = guiBuildSVMModel(RED,GREEN,BLUE,totalBinary_backr, totalBinary_foregr, SavedBackground,SavedForegr)

% from the points distribution you must decide upon the model
% 'KernelFunction','polynomial'
% 'KernelFunction','linear'

totalBinary_backr = double(totalBinary_backr)+SavedBackground;
totalBinary_backr = totalBinary_backr>0;

totalBinary_foregr = double(totalBinary_foregr)+SavedForegr;
totalBinary_foregr = totalBinary_foregr>0;

[row_backgr, col_backgr] = find(totalBinary_backr==1);
[row_foregr, col_foregr] =find(totalBinary_foregr==1);

inD = sub2ind(size(RED),row_foregr,col_foregr);
inDB = sub2ind(size(RED),row_backgr,col_backgr);

x1 = horzcat(RED(inD),GREEN(inD),BLUE(inD));
y1 = repmat(20,length(inD),1);

x2 = horzcat(RED(inDB),GREEN(inDB),BLUE(inDB));
y2 = repmat(66,length(inDB),1);
X = [x1;x2];
Y = [y1;y2];
figure, plot3(x1(:,1),x1(:,2),x1(:,3),'r*')
hold on
plot3(x2(:,1),x2(:,2),x2(:,3),'bo')
hold off
title('RGB values distribution for the chosen areas')
xlabel ('RED')
ylabel ('GREEN')
zlabel ('BLUE')
pause(2);

%% Fit SVM
disp('Applying model to the image...')
% if a plane model is not able to separate the data try polinimial (paraboloid)
SVMModel = fitcsvm(double(X),Y,'Verbose',1,'IterationLimit',50000);
outliers = 0;
if ~SVMModel.ConvergenceInfo.Converged
    disp('Linear model did not work. Switched to polynomial kernel.')
    fprintf('Number of outliers is %i %% \n',outliers*100);

    % set the outlier percentage and switch to polynomial kernel
    SVMModel = fitcsvm(double(X),Y,'Verbose',1,'KernelFunction','polynomial', 'PolynomialOrder',2,'Standardize',true,'OutlierFraction',outliers);
    outliers = outliers +0.02;
end

% check the model on the chosen areas
[cpre,scores1] = predict(SVMModel,double(X));
T  = X(cpre==20,:);
T_back= X(cpre==66,:);
figure,scatter3(T(:,1),T(:,2),T(:,3),'r','filled')
hold on
scatter3(T_back(:,1),T_back(:,2),T_back(:,3),'b','filled')
hold off
title('Clustered RGB values distribution for the chosen areas')
xlabel ('RED')
ylabel ('GREEN')
zlabel ('BLUE')
