function [intrinsic,reflexNL,reflexSS] = extractIntrinsicReflex(system)

intrinsic = cell(size(system,1),size(system,2),size(system,3));
reflexNL = cell(size(system,1),size(system,2),size(system,3));
reflexSS = cell(size(system,1),size(system,2),size(system,3));
for i = 1 : size(system,1)
    for j = 1 : size(system,2)
        for k = 1 : size(system,3)
            intrinsic{i,j,k} = system{i,j,k,1};
            reflex = system{i,j,k,2};
            reflexNL{i,j,k} = reflex{1};
            reflexSS{i,j,k} = reflex{2};
        end
    end
end
