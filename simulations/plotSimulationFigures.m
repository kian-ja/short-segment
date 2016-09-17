load results/timeVaryingID_Results
%systemID numSamp
%systemID is a 5x100 variable
%The first dimension is the number of division in scheduling variable
%   1) 4
%   2) 8
%   3) 12
%   4) 16
%   5) 20
%%
schedulingSegmentNumber = 4:4:20;
monteCarloIteration = size(systemID,2);
vafIntrinsic = cell(length(schedulingSegmentNumber),1);
stiffness = cell(length(schedulingSegmentNumber),1);
reflexGain = cell(length(schedulingSegmentNumber),1);
vafReflex = cell(length(schedulingSegmentNumber),1);
x = -2:0.001:2;
x = nldat(x','domainIncr',0.001);

for i = 1 : length(schedulingSegmentNumber)
    disp([num2str(i),' out of 5']);
    vafIntrinsicTemp = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    stiffnessTemp = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    vafReflexTemp = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    reflexGainTemp = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    for j = 1 : monteCarloIteration
        system = systemID{i,j};
        for k = 1 : length(system)
            systemTemp = system{k};
            vafs = systemTemp{3};
            intrinsic = systemTemp{1};
            reflex = systemTemp{2};
            nonlin = reflex{1};
            intrinsic = intrinsic.dataSet;
            stiffnessTemp(j,k) = sum(intrinsic)/100;
            vafIntrinsicTemp(j,k) = vafs(2);
            vafReflexTemp(j,k) = vafs(3);
            if isnan(nonlin.polyCoef)
                reflexGainTemp(j,k) = NaN;
            else
                y = nlsim(nonlin,x);
                [~,slope]=slope_fitNoPlot(x.dataSet,y.dataSet,0);
                reflexGainTemp(j,k) = abs(slope);
            end
        end

    end
    vafIntrinsic{i} = vafIntrinsicTemp;
    vafReflex{i} = vafReflexTemp;
    stiffness{i} = stiffnessTemp;
    reflexGain{i} = reflexGainTemp;
end
%%

figure(1)
figure(2)
for i = 1 : 5
    figure(1)
    subplot(5,1,i)
    boxplot(vafIntrinsic{i})
    if i == 1
        title('VAF Intrinsic')
    end
    figure(2)
    subplot(5,1,i)
    boxplot(vafReflex{i})
    if i == 1
        title('VAF Reflex')
    end
    
end
%%
   
figure
positionLevels = [-0.48 -0.4 -0.32 -0.24 -0.16 -0.08 0.0 0.08 0.16 0.24];%from Mirbagheri et al 2000
K = [0.38 0.36 0.42 0.48 0.52 0.55 0.6 0.7 0.8 1];%from Mirbagheri et al 2000
polyCoeffK = 50 * polyfit(positionLevels,K,5);
posLevel = -0.48:0.01:0.24;
KTrue = polyval(polyCoeffK,posLevel);
for i = 1 : 5
    posAxis = linspace(-0.48,0.24,size(stiffness{i},2));
    errorbar(posAxis,mean(stiffness{i}) + (i-1) * 20,std(stiffness{i}))
    hold on
    plot(posLevel,KTrue + (i-1) * 20,'r')
end

%%
   
figure
positionLevels = [-0.48 -0.4 -0.32 -0.24 -0.16 -0.08 0.0 0.08 0.16 0.24];%from Mirbagheri et al 2000
Gr = [0.0625,0.0938,0.1042,0.1094,0.2813,0.5000,0.6250,0.7000,0.8000,0.8100];%from Mirbagheri et al 2000
polyCoeffGr = 30 * polyfit(positionLevels,Gr,5);
posLevel = -0.48:0.01:0.24;
GrTrue = polyval(polyCoeffGr,posLevel);
for i = 1 : 5
    reflexGainTemp = reflexGain{i};
    
    posAxis = linspace(-0.48,0.24,size(reflexGainTemp,2));
    errorbar(posAxis,nanmean(reflexGainTemp) + (i-1) * 10,nanstd(reflexGainTemp))
    hold on
    plot(posLevel,GrTrue + (i-1) * 10,'r')

end
