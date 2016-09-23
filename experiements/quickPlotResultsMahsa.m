K = zeros(3,2);
vafTot = zeros(5,2);
vafIntrinsic = zeros(5,2);
vafReflex = zeros(5,2);
for i = 1 : 5
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
        vafIntrinsic(i,j) = vafs(1);
        vafReflex(i,j) = vafs(1);
        pause 
        close(100)
    end
end