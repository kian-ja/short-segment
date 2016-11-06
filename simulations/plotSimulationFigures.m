clear

load('results/systemIDExperiment.mat')
numLevelsLen = length(sysID);
%%
K = cell(numLevelsLen,1);
Gr = cell(numLevelsLen,1);
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
    vafTotTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafTot_SDSS_Temp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafIntrinsicTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafReflexTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafIntrinsic_SDSS_Temp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafReflex_SDSS_Temp = zeros(size(sysID{i},1),size(sysIDTemp,2));
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
            GrTemp(j,k) = abs(slope);
            vafsTemp = systemTemp{3};
            
            KTemp(j,k) = sum(intrinsicTemp.dataSet)/100;
            
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
xAxisTicks = [2;4;6];
schedulingSegmentNumber = [3 6 9];%3:3:12
for i = 1 : numLevelsLen
    subplot(1,2,1)
    hold on
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
    subplot(1,2,2)
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
    bar(xAxisTicks(i)-0.3,vafTot_SDSSThisLevelMean,0.5,'FaceColor',[0.95,0.95,0.95])
    bar(xAxisTicks(i)+0.3,vafTot_SS_SDSSThisLevelMean,0.5,'FaceColor',[0.45,0.45,0.45])
%    if i == 1 
%        legend('SDSS','SS-SDSS');
%    end
    errorbar(xAxisTicks(i)-0.3,vafTot_SDSSThisLevelMean,...
        vafTot_SDSSThisLevelMean-vafTot_SDSSThisLevel5,...
        vafTot_SDSSThisLevel95-vafTot_SDSSThisLevelMean,'color','k','lineWidth',2)
    
    errorbar(xAxisTicks(i)+0.3,vafTot_SS_SDSSThisLevelMean,...
        vafTot_SS_SDSSThisLevelMean-vafTot_SS_SDSSThisLevel5,...
        vafTot_SS_SDSSThisLevel95-vafTot_SS_SDSSThisLevelMean,'color','k','lineWidth',2)
    if pValue < 0.05
        plot(xAxisTicks(i),105,'*','MarkerEdgeColor','k','markerSize',10)
    end
end
subplot(1,2,1)
set(gca,'Xtick',xAxisTicks,'XTickLabel',{'3', '6', '9'})
ylim([0,110])
xlabel('Number of bins')
ylabel('%VAF total')
title('Intrinsic Identification %VAF')
axis square
subplot(1,2,2)
set(gca,'Xtick',xAxisTicks,'XTickLabel',{'3', '6', '9'})
ylim([0,110])
xlabel('Number of bins')
ylabel('%VAF total')
title('Reflex Identification %VAF')
axis square
%%
figure
subplot(1,2,1)
positionLevels = [-0.48 -0.4 -0.32 -0.24 -0.16 -0.08 0.0 0.08 0.16 0.24];%from Mirbagheri et al 2000
KPositionLevels = [0.45 0.47 0.48 0.5 0.52 0.55 0.6 0.7 0.8 1];
polyCoeffK = 50 * polyfit(positionLevels,KPositionLevels,5);
posLevel = -0.48:0.01:0.24;
KTrue = polyval(polyCoeffK,posLevel);
for i = 1 : length(schedulingSegmentNumber)
    posAxis = linspace(-0.48,0.24,size(K{i},2));
    levels = linspace(-0.48,0.24,schedulingSegmentNumber(i)+1);
    xAxis = (levels(1:end-1)+levels(2:end))/2;
    errorbar(xAxis,mean(K{i}') + (i-1) * 20,std(K{i}')...
        ,'lineWidth',2,'color','r','lineStyle','--')
    hold on
    plot(posLevel,KTrue + (i-1) * 20,'lineWidth',2,'color','k')
end
xlabel('Position (rad)')
ylabel('Elastic parameter (Nm/k)')
set(gca,'Ytick',0:10:40,'YTickLabel',{'0', '10', '20', '30','40'})
title('Elastic Parameter')
box off

subplot(1,2,2)
positionLevels = [-0.48 -0.4 -0.32 -0.24 -0.16 -0.08 0.0 0.08 0.16 0.24];%from Mirbagheri et al 2000
GrPositionLevels = [0.0625,0.0938,0.1042,0.1094,0.2813,0.5000,0.6250,0.7000,0.8000,0.8100];%from Mirbagheri et al 2000
GrPositionLevels = GrPositionLevels + 0.1;
polyCoeffGr = 40 * polyfit(positionLevels,GrPositionLevels,5);
posLevel = -0.48:0.01:0.24;
GrTrue = polyval(polyCoeffGr,posLevel);
for i = 1 : length(schedulingSegmentNumber)
    reflexGainTemp = Gr{i};
    levels = linspace(-0.48,0.24,schedulingSegmentNumber(i)+1);
    xAxis = (levels(1:end-1)+levels(2:end))/2;
    posAxis = linspace(-0.48,0.24,size(reflexGainTemp,2));
    errorbar(xAxis,nanmean(reflexGainTemp') + (i-1) * 10,...
        nanstd(reflexGainTemp'),'lineWidth',2,'color','r','lineStyle','--')
    hold on
    plot(posLevel,GrTrue + (i-1) * 10,'lineWidth',2,'color','k')
    if i == 1 
        legend('Estimate','True')
    end

end
xlabel('Position (rad)')
ylabel('Reflex gain (Nms/rad)')
set(gca,'Ytick',0:5:35,'YTickLabel',{'0','5', '10','5', '20','25', '30','35'})
title('Reflex Gain')
box off