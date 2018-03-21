function A = filterByPosition(A)

flag = zeros(1, size(A,1));
x = A.X;
y = A.Y;
z = A.Z;
cherry = A.RedMeanInt;
for p = 1:size(A,1)
    for q = 1:size(A,1)
        if p ~= q && flag(q) ~= 1 && flag(p) ~= 1
            xy_distance = sqrt((x(p)-x(q))^2 + (y(p)-y(q))^2);      
            z_dist = abs(z(p)-z(q));
            if xy_distance < 5 && z_dist < 11
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
A.RedMeanInt = cherry;
A(logical(flag),:) = [];                

end

