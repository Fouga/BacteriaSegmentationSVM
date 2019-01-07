function ratio = correctImages(Model_needed, Model_change,method)

m1 = Model_needed(Model_needed>0);
m2 = Model_change(Model_change>0);
switch method
    case 'mean'
        ratio = (mean(m1)/mean(m2))^2
    case 'median'
        ratio = (median(m1)/median(m2))^2
    case 'trimmean'
        percent = 25;
        ratio = (trimmean(m1,percent)/trimmean(m2,percent))^2
end
if ratio<1
    disp('No changes to the brightness')
    ratio = 1;
end


