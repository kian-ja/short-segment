clear

load('results/systemIDExperiment.mat')
numLevelsLen = length(sysID);
K = cell(numLevelsLen,1);
Gr = cell(numLevelsLen,1);
vafTot = cell(numLevelsLen,1);
vafTotSDSS = cell(numLevelsLen,1);
vafIntrinsic = cell(numLevelsLen,1);
vafReflex = cell(numLevelsLen,1);
x = -2 :0.001:2;
x = nldat(x','domainIncr',0.001);
for i = 1 : numLevelsLen
    sysIDTemp = sysID{i};
    sysID_SDSSTemp = sysID_SDSS{i};
    KTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafTotTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafTot_SDSS_Temp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafIntrinsicTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafReflexTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    GrTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    for j = 1 : size(sysIDTemp,1)%levels
        for k = 1 : size(sysIDTemp,2)%MC iteration
            systemTemp = sysIDTemp{j,k};
            systemTemp_SDSS = sysID_SDSSTemp{j,k};
            intrinsicTemp = systemTemp{1};
            reflexTemp = systemTemp{2};
            reflexNLTemp = reflexTemp{1};
            y = nlsim(reflexNLTemp,x);
            if isnan(reflexNLTemp.polyCoef)
                slope = 0;
            else
                [~,slope] = slope_fitNoPlot(x.dataSet,y.dataSet,0);
            end
            GrTemp(j,k) = slope;
            vafsTemp = systemTemp{3};
            
            KTemp(j,k)= max(-0.01*sum(intrinsicTemp.dataSet),0);
            vafTotTemp(j,k)= vafsTemp(1);
            vafIntrinsicTemp(j,k)= vafsTemp(2);
            vafReflexTemp(j,k)= vafsTemp(3);
            vafsTemp_SDSS = systemTemp_SDSS{3};
            vafTot_SDSS_Temp(j,k)= vafsTemp_SDSS(1);
        end
    end
    K{i} = KTemp;
    Gr{i} = GrTemp;
    vafTot{i} = vafTotTemp;
    vafTotSDSS{i} = vafTot_SDSS_Temp;
    vafIntrinsic{i} = vafIntrinsicTemp;
    vafReflex{i} = vafReflexTemp;
end
%%
load results/experimentalTQVaryingData
voluntaryTorque = subject1.voluntaryTorque;
minTQ = prctile(voluntaryTorque,5);
maxTQ = prctile(voluntaryTorque,95);
minTQ = minTQ - maxTQ;
maxTQ = 0;
numLevels = 3:7;
figure
subplot(1,2,1)
hold on
subplot(1,2,2)
hold on
for i = 1 : numLevelsLen
    levels = linspace(minTQ,maxTQ,numLevels(i));
    xAxis = (levels(1:end-1)+levels(2:end))/2;
    subplot(1,2,1)
    KTemp = K{i}';
    KTemp = max(KTemp,0);
    KTemp5 = prctile(KTemp,5);
    KTemp95 = prctile(KTemp,95);
    KTempMean = mean(KTemp);
    errorbar(xAxis,KTempMean + (i-1) * 20,KTempMean-KTemp5,KTemp95-KTempMean,'k')
    subplot(1,2,2)
    GrTemp = Gr{i}';
    GrTemp = max(GrTemp,0);
    GrTemp5 = prctile(GrTemp,5);
    GrTemp95 = prctile(GrTemp,95);
    GrTempMean = mean(GrTemp);
    errorbar(xAxis,GrTempMean + (i-1) * 10,GrTempMean-GrTemp5,GrTemp95-GrTempMean,'k')
end
subplot(1,2,1)
xlabel('Torque (Nm)')
ylabel('Elastic parameter (Nm/rad)')
title('Elastic Parameter')
subplot(1,2,2)
xlabel('Torque (Nm)')
ylabel('Reflex Gain (Nms/rad)')
title('Reflex Gain')
%%
figure
hold on
for i = 1 : numLevelsLen
    vafTot_SS_SDSSThisLevel = vafTot{i};
    vafTot_SDSSThisLevel = vafTotSDSS{i};
    vafTot_SS_SDSSThisLevel = vafTot_SS_SDSSThisLevel(:);
    vafTot_SDSSThisLevel = vafTot_SDSSThisLevel(:);
    vafTot_SS_SDSSThisLevelMean = mean(vafTot_SS_SDSSThisLevel);
    vafTot_SS_SDSSThisLevel5 = prctile(vafTot_SS_SDSSThisLevel,5);
    vafTot_SS_SDSSThisLevel95 = prctile(vafTot_SS_SDSSThisLevel,95);
    
    vafTot_SDSSThisLevelMean = mean(vafTot_SDSSThisLevel);
    vafTot_SDSSThisLevel5 = prctile(vafTot_SDSSThisLevel,5);
    vafTot_SDSSThisLevel95 = prctile(vafTot_SDSSThisLevel,95);
    bar(numLevels(i)-0.15,vafTot_SDSSThisLevelMean,0.25)
    bar(numLevels(i)+0.15,vafTot_SS_SDSSThisLevelMean,0.25)

end