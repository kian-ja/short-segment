clear
load('results/LPVSimulationData1Trial.mat')
load('results/systemIDExperiment2.mat')

numLevelsLen = length(sysID);
schedulingSegmentNumber = numLevels;%3:3:12
%%
K = cell(numLevelsLen,1);
Gr = cell(numLevelsLen,1);
KSDSS = cell(numLevelsLen,1);
GrSDSS = cell(numLevelsLen,1);

vafTot = cell(numLevelsLen,1);
vafTotSDSS = cell(numLevelsLen,1);
vafIntrinsic = cell(numLevelsLen,1);
vafReflex = cell(numLevelsLen,1);
vafIntrinsicSDSS = cell(numLevelsLen,1);
vafReflexSDSS = cell(numLevelsLen,1);
x = -2 :0.001:2;
x = nldat(x','domainIncr',0.001);
for i = 1 : numLevelsLen
    disp(['Preparing data: ',num2str(i),' out of ',num2str(numLevelsLen)]);
    sysIDTemp = sysID{i};
    sysID_SDSSTemp = sysID_SDSS{i};
    KTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    KSDSSTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafTotTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafTot_SDSS_Temp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafIntrinsicTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafReflexTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafIntrinsic_SDSS_Temp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafReflex_SDSS_Temp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    GrTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    GrSDSSTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    for j = 1 : size(sysIDTemp,1)%levels
        for k = 1 : size(sysIDTemp,2)%MC iteration
            systemTemp = sysIDTemp{j,k};
            systemTemp_SDSS = sysID_SDSSTemp{j,k};
            intrinsicTemp = systemTemp{1};
            reflexTemp = systemTemp{2};
            reflexNLTemp = reflexTemp{1};
            
            intrinsicTempSDSS = systemTemp_SDSS{1};
            reflexTempSDSS = systemTemp_SDSS{2};
            reflexNLTempSDSS = reflexTempSDSS{1};
            
            y = nlsim(reflexNLTemp,x);
            ySDSS = nlsim(reflexNLTempSDSS,x);
            if isnan(reflexNLTemp.polyCoef)
                slope = 0;
            else
                [~,slope] = slope_fitNoPlot(x.dataSet,y.dataSet,0);
            end
            if isnan(reflexNLTempSDSS.polyCoef)
                slopeSDSS = 0;
            else
                [~,slopeSDSS] = slope_fitNoPlot(x.dataSet,ySDSS.dataSet,0);
            end
            GrTemp(j,k) = abs(slope);
            GrSDSSTemp(j,k) = abs(slopeSDSS);
            
            vafsTemp = systemTemp{3};
            
            KTemp(j,k) = sum(intrinsicTemp.dataSet)/100;
            KSDSSTemp(j,k) = sum(intrinsicTempSDSS.dataSet)/100;
            
            vafTotTemp(j,k)= vafsTemp(1);
            vafIntrinsicTemp(j,k)= vafsTemp(2);
            vafReflexTemp(j,k)= vafsTemp(3);
            vafsTemp_SDSS = systemTemp_SDSS{3};
            vafTot_SDSS_Temp(j,k)= vafsTemp_SDSS(1);
            
            vafIntrinsic_SDSS_Temp(j,k)= vafsTemp_SDSS(2);
            vafReflex_SDSS_Temp(j,k)= vafsTemp_SDSS(3);
        end
    end
    K{i} = KTemp;
    Gr{i} = GrTemp;
    
    KSDSS{i} = KSDSSTemp;
    GrSDSS{i} = GrSDSSTemp;
    
    vafTot{i} = vafTotTemp;
    vafTotSDSS{i} = vafTot_SDSS_Temp;
    vafIntrinsic{i} = vafIntrinsicTemp;
    vafReflex{i} = vafReflexTemp;
    vafIntrinsicSDSS{i} = vafIntrinsic_SDSS_Temp;
    vafReflexSDSS{i} = vafReflex_SDSS_Temp;
end
%%

figure
hold on
xAxisTicks = [1;3;5];
i = 1;
vafTot_SS_SDSSThisLevel = vafTot{i};
vafTot_SDSSThisLevel = vafTotSDSS{i};
vafTot_SS_SDSSThisLevel = vafTot_SS_SDSSThisLevel(:);
vafTot_SDSSThisLevel = vafTot_SDSSThisLevel(:);
pValue = pValueSign2Sided(vafTot_SS_SDSSThisLevel',vafTot_SDSSThisLevel');
vafTot_SS_SDSSThisLevelMean = mean(vafTot_SS_SDSSThisLevel);
vafTot_SS_SDSSThisLevel5 = prctile(vafTot_SS_SDSSThisLevel,5);
vafTot_SS_SDSSThisLevel95 = prctile(vafTot_SS_SDSSThisLevel,95);

vafTot_SDSSThisLevelMean = mean(vafTot_SDSSThisLevel);
vafTot_SDSSThisLevel5 = prctile(vafTot_SDSSThisLevel,5);
vafTot_SDSSThisLevel95 = prctile(vafTot_SDSSThisLevel,95);
bar(xAxisTicks(i)-0.3,vafTot_SDSSThisLevelMean,0.5,'FaceColor',[0.95,0.95,0.95])
bar(xAxisTicks(i)+0.3,vafTot_SS_SDSSThisLevelMean,0.5,'FaceColor',[0.45,0.45,0.45])
if i == 1 
    legend('SDSS','SS-SDSS');
end
errorbar(xAxisTicks(i)-0.3,vafTot_SDSSThisLevelMean,...
    vafTot_SDSSThisLevelMean-vafTot_SDSSThisLevel5,...
    vafTot_SDSSThisLevel95-vafTot_SDSSThisLevelMean,'color','k','lineWidth',2)

errorbar(xAxisTicks(i)+0.3,vafTot_SS_SDSSThisLevelMean,...
    vafTot_SS_SDSSThisLevelMean-vafTot_SS_SDSSThisLevel5,...
    vafTot_SS_SDSSThisLevel95-vafTot_SS_SDSSThisLevelMean,'color','k','lineWidth',2)
if pValue < 0.05
    plot(xAxisTicks(i),105,'*','MarkerEdgeColor','k','markerSize',10)
end


vafTot_SS_SDSSThisLevel = vafIntrinsic{i};
vafTot_SDSSThisLevel = vafIntrinsicSDSS{i};
vafTot_SS_SDSSThisLevel = vafTot_SS_SDSSThisLevel(:);
vafTot_SDSSThisLevel = vafTot_SDSSThisLevel(:);
pValue = pValueSign2Sided(vafTot_SS_SDSSThisLevel',vafTot_SDSSThisLevel');
vafTot_SS_SDSSThisLevelMean = mean(vafTot_SS_SDSSThisLevel);
vafTot_SS_SDSSThisLevel5 = prctile(vafTot_SS_SDSSThisLevel,5);
vafTot_SS_SDSSThisLevel95 = prctile(vafTot_SS_SDSSThisLevel,95);

vafTot_SDSSThisLevelMean = mean(vafTot_SDSSThisLevel);
vafTot_SDSSThisLevel5 = prctile(vafTot_SDSSThisLevel,5);
vafTot_SDSSThisLevel95 = prctile(vafTot_SDSSThisLevel,95);
bar(xAxisTicks(i+1)-0.3,vafTot_SDSSThisLevelMean,0.5,'FaceColor',[0.95,0.95,0.95])
bar(xAxisTicks(i+1)+0.3,vafTot_SS_SDSSThisLevelMean,0.5,'FaceColor',[0.45,0.45,0.45])
if i == 1 
    legend('SDSS','SS-SDSS');
end
errorbar(xAxisTicks(i+1)-0.3,vafTot_SDSSThisLevelMean,...
    vafTot_SDSSThisLevelMean-vafTot_SDSSThisLevel5,...
    vafTot_SDSSThisLevel95-vafTot_SDSSThisLevelMean,'color','k','lineWidth',2)

errorbar(xAxisTicks(i+1)+0.3,vafTot_SS_SDSSThisLevelMean,...
    vafTot_SS_SDSSThisLevelMean-vafTot_SS_SDSSThisLevel5,...
    vafTot_SS_SDSSThisLevel95-vafTot_SS_SDSSThisLevelMean,'color','k','lineWidth',2)
if pValue < 0.05
    plot(xAxisTicks(i+1),105,'*','MarkerEdgeColor','k','markerSize',10)
end
%subplot(1,2,2)
hold on
vafTot_SS_SDSSThisLevel = vafReflex{i};%vafIntrinsic{i};
vafTot_SDSSThisLevel = vafReflexSDSS{i};%vafIntrinsicSDSS{i};
vafTot_SS_SDSSThisLevel = vafTot_SS_SDSSThisLevel(:);
vafTot_SDSSThisLevel = vafTot_SDSSThisLevel(:);
pValue = pValueSign2Sided(vafTot_SS_SDSSThisLevel',vafTot_SDSSThisLevel');
vafTot_SS_SDSSThisLevelMean = mean(vafTot_SS_SDSSThisLevel);
vafTot_SS_SDSSThisLevel5 = prctile(vafTot_SS_SDSSThisLevel,5);
vafTot_SS_SDSSThisLevel95 = prctile(vafTot_SS_SDSSThisLevel,95);

vafTot_SDSSThisLevelMean = mean(vafTot_SDSSThisLevel);
vafTot_SDSSThisLevel5 = prctile(vafTot_SDSSThisLevel,5);
vafTot_SDSSThisLevel95 = prctile(vafTot_SDSSThisLevel,95);
bar(xAxisTicks(i+2)-0.3,vafTot_SDSSThisLevelMean,0.5,'FaceColor',[0.95,0.95,0.95])
bar(xAxisTicks(i+2)+0.3,vafTot_SS_SDSSThisLevelMean,0.5,'FaceColor',[0.45,0.45,0.45])
%    if i == 1 
%        legend('SDSS','SS-SDSS');
%    end
errorbar(xAxisTicks(i+2)-0.3,vafTot_SDSSThisLevelMean,...
    vafTot_SDSSThisLevelMean-vafTot_SDSSThisLevel5,...
    vafTot_SDSSThisLevel95-vafTot_SDSSThisLevelMean,'color','k','lineWidth',2)

errorbar(xAxisTicks(i+2)+0.3,vafTot_SS_SDSSThisLevelMean,...
    vafTot_SS_SDSSThisLevelMean-vafTot_SS_SDSSThisLevel5,...
    vafTot_SS_SDSSThisLevel95-vafTot_SS_SDSSThisLevelMean,'color','k','lineWidth',2)
if pValue < 0.05
    plot(xAxisTicks(i+2),105,'*','MarkerEdgeColor','k','markerSize',10)
end
set(gca,'Xtick',[xAxisTicks(i),xAxisTicks(i+1),xAxisTicks(i+2)],'XTickLabel',{'VAF_{total}', 'VAF_{Intrinsic}', 'VAF_{Reflex}'})
ylim([0,110])
%xlabel('Number of bins')
ylabel('%VAF')

%%
schedulingVariableType = 'torque';
if strcmp(schedulingVariableType , 'pos')
    levels = [-0.48 -0.4 -0.32 -0.24 -0.16 -0.08 0.0 0.08 0.16 0.24];%from Mirbagheri et al 2000
    reflexGain = [0.0625,0.0938,0.1042,0.1094,0.2813,0.5000,0.6250,0.7000,0.8000,0.8100];%from Mirbagheri et al 2000
    reflexGain = reflexGain + 0.1;
    elasticParameter = [0.32 0.36 0.42 0.48 0.52 0.55 0.6 0.7 0.8 1];%from Mirbagheri et al 2000
end
if strcmp(schedulingVariableType , 'torque')
    levels = [0 -3 -6 -9 -12 -15 -18 -21 -24];%from Mirbagheri et al 2000
    reflexGain = [0.2 0.7 0.9 0.8 0.6 0.35 0.35 0.3 0.4];
    elasticParameter = [0.18 0.4 0.5 0.65 0.75 0.81 0.875 0.94 1];%from Mirbagheri et al 2000
end
minTQ = prctile(schedulingVariableMC,5);
maxTQ = prctile(schedulingVariableMC,95);

figure
subplot(2,2,1)
polyCoeffK = 50 * polyfit(levels,elasticParameter,5);
svTrueXAxis = minTQ:0.05:maxTQ;
elasticParamTrue = polyval(polyCoeffK,svTrueXAxis);
for i = 1 : length(schedulingSegmentNumber)
    newLevels = linspace(minTQ,maxTQ,schedulingSegmentNumber(i));
    xAxis = (newLevels(1:end-1)+newLevels(2:end))/2;
    
    KTemp5 = prctile(K{i}',5);
    KTemp95 = prctile(K{i}',95);
    KTempMean = nanmean(K{i}');
    plot(svTrueXAxis,elasticParamTrue + (i-1) * 20,'lineWidth',2,'color','k')
    hold on
    errorbar(xAxis,KTempMean + (i-1) * 35,KTempMean-KTemp5,KTemp95-KTempMean...
        ,'lineWidth',2,'color','r','lineStyle','--')
    
    %errorbar(xAxis,mean(K{i}') + (i-1) * 20,std(K{i}')...
    %    ,'lineWidth',2,'color','r','lineStyle','--')
    
    
end
ylim([0,100])
ylabel('Elastic parameter (Nm/k)')
%set(gca,'Ytick',0:10:40,'YTickLabel',{'0', '10', '20', '30','40'})
title('Elastic Parameter')
box off
axis square

subplot(2,2,3)
polyCoeffGr = 40 * polyfit(levels,reflexGain,5);
reflexGainTrue = polyval(polyCoeffGr,svTrueXAxis);
for i = 1 : length(schedulingSegmentNumber)    
    reflexGainTemp = Gr{i};
    newLevels = linspace(minTQ,maxTQ,schedulingSegmentNumber(i));
    xAxis = (newLevels(1:end-1)+newLevels(2:end))/2;
    posAxis = linspace(-0.48,0.24,size(reflexGainTemp,2));
    
    reflexGain5 = prctile(reflexGainTemp',5);
    reflexGain95 = prctile(reflexGainTemp',95);
    reflexGainMean = nanmean(reflexGainTemp');
    plot(svTrueXAxis,reflexGainTrue + (i-1) * 10,'lineWidth',2,'color','k')
    hold on
    errorbar(xAxis,reflexGainMean + (i-1) * 35,reflexGainMean-reflexGain5,reflexGain95-reflexGainMean...
        ,'lineWidth',2,'color','r','lineStyle','--')
    
    %errorbar(xAxis,nanmean(reflexGainTemp') + (i-1) * 10,...
    %    nanstd(reflexGainTemp'),'lineWidth',2,'color','r','lineStyle','--')
    
    
    if i == 1 
        legend('Estimate','True')
    end

end
if strcmp(schedulingVariableType, 'torque')
    xlabel('Torque (Nm)')
elseif strcmp(schedulingVariableType, 'pos')
    xlabel('Position (rad)')
end

ylabel('Reflex gain (Nms/rad)')
%set(gca,'Ytick',0:5:35,'YTickLabel',{'0','5', '10','5', '20','25', '30','35'})
title('Reflex Gain')
box off
axis square


subplot(2,2,2)
polyCoeffK = 50 * polyfit(levels,elasticParameter,5);
svTrueXAxis = minTQ:0.05:maxTQ;
elasticParamTrue = polyval(polyCoeffK,svTrueXAxis);
for i = 1 : length(schedulingSegmentNumber)
    newLevels = linspace(minTQ,maxTQ,schedulingSegmentNumber(i));
    xAxis = (newLevels(1:end-1)+newLevels(2:end))/2;
    
    KTemp5 = prctile(KSDSS{i}',5);
    KTemp95 = prctile(KSDSS{i}',95);
    KTempMean = nanmean(KSDSS{i}');
    plot(svTrueXAxis,elasticParamTrue + (i-1) * 20,'lineWidth',2,'color','k')
    hold on
    
    errorbar(xAxis,KTempMean + (i-1) * 35,KTempMean-KTemp5,KTemp95-KTempMean...
        ,'lineWidth',2,'color','r','lineStyle','--')
    
end
ylim([0,100])


%ylabel('Elastic parameter (Nm/k)')
%set(gca,'Ytick',0:10:40,'YTickLabel',{'0', '10', '20', '30','40'})
title('Elastic Parameter')
box off
axis square

subplot(2,2,4)
polyCoeffGr = 40 * polyfit(levels,reflexGain,5);
reflexGainTrue = polyval(polyCoeffGr,svTrueXAxis);
for i = 1 : length(schedulingSegmentNumber)    
    reflexGainTemp = GrSDSS{i};
    newLevels = linspace(minTQ,maxTQ,schedulingSegmentNumber(i));
    xAxis = (newLevels(1:end-1)+newLevels(2:end))/2;
    posAxis = linspace(-0.48,0.24,size(reflexGainTemp,2));
    
    reflexGain5 = prctile(reflexGainTemp',5);
    reflexGain95 = prctile(reflexGainTemp',95);
    reflexGainMean = nanmean(reflexGainTemp');
    plot(svTrueXAxis,reflexGainTrue + (i-1) * 10,'lineWidth',2,'color','k')
    hold on
    errorbar(xAxis,reflexGainMean + (i-1) * 35,reflexGainMean-reflexGain5,reflexGain95-reflexGainMean...
        ,'lineWidth',2,'color','r','lineStyle','--')
    
    
    
end
if strcmp(schedulingVariableType, 'torque')
    xlabel('Torque (Nm)')
elseif strcmp(schedulingVariableType, 'pos')
    xlabel('Position (rad)')
end

ylabel('Reflex gain (Nms/rad)')
%set(gca,'Ytick',0:5:35,'YTickLabel',{'0','5', '10','5', '20','25', '30','35'})
title('Reflex Gain')
box off
axis square