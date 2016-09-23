K = zeros(4,2);
vafTot = zeros(4,2);
vafIntrinsic = zeros(4,2);
vafReflex = zeros(4,2);
for i = 1 : 4
    for j = 1 : 1
        system = sysID{i,j};
        intrinsic = system{1};
        K(i,j)= -100*sum(intrinsic.dataSet);
        reflex = system{2};
        figure(100)
        subplot(1,2,1)
        plot(reflex{1})
        subplot(1,2,2)
        plot(reflex{2})
        vafs = system{3};
        vafTot(i,j) = vafs(1);
        vafIntrinsic(i,j) = vafs(2);
        vafReflex(i,j) = vafs(3);
        pause 
        close(100)
    end
end