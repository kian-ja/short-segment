clear
load('results/systemIDExperiment.mat')
numLevelsLen = length(sysID);
%%
K = cell(numLevelsLen,1);
Gr = cell(numLevelsLen,1);
T = cell(numLevelsLen,1);
vafTot = cell(numLevelsLen,1);
vafTotSDSS = cell(numLevelsLen,1);
vafIntrinsic = cell(numLevelsLen,1);
vafReflex = cell(numLevelsLen,1);
x = -1.5 :0.001:2.5;
x = nldat(x','domainIncr',0.001);
searchUpperLimit = linspace(16,5,numLevels-1);
searchLowerLimit = linspace(8,0,numLevels-1);
for i = 1 : numLevelsLen
    sysIDTemp = sysID{i};
    sysID_SDSSTemp = sysID_SDSS{i};
    KTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafTotTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafTot_SDSS_Temp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafIntrinsicTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    vafReflexTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    GrTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    TTemp = zeros(size(sysID{i},1),size(sysIDTemp,2));
    for j = 1 : size(sysIDTemp,1)%levels
        disp(['Now checking level : ',num2str(j),' out of ',num2str(numLevels(i)-1)])
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
                %figure(100)
                %plot(x.dataSet,y.dataSet)
                [threshold,slope] = slope_fitNoPlot(x.dataSet,y.dataSet,0);
                %disp(['Threshold is: ',num2str(threshold),' and slope is: ',num2str(slope)])
                
                    
                %hold on
                %plot(x.dataSet,(slope*((x.dataSet-threshold)+(x.dataSet-threshold).*sign(x.dataSet-threshold)))/2);
                %pause
                %close(100)
            end
            GrTemp(j,k) = slope;
            TTemp(j,k) = threshold;
            vafsTemp = systemTemp{3};
            
            KTemp(j,k)= -0.01*sum(intrinsicTemp.dataSet);
            if KTemp(j,k) < 0
                KTemp(j,k) = NaN;
            end
            if (slope >searchUpperLimit(j))||(slope<searchLowerLimit(j))
                    GrTemp(j,k) = NaN;
                    KTemp(j,k) = NaN;
            end
            vafTotTemp(j,k)= vafsTemp(1);
            vafIntrinsicTemp(j,k)= vafsTemp(2);
            vafReflexTemp(j,k)= vafsTemp(3);
            vafsTemp_SDSS = systemTemp_SDSS{3};
            vafTot_SDSS_Temp(j,k)= vafsTemp_SDSS(1);
        end
    end
    K{i} = KTemp;
    Gr{i} = GrTemp;
    T{i} = TTemp;
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
%numLevels = [9];%3:7;
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
    %KTemp = max(KTemp,0);
    KTemp5 = prctile(KTemp,5);
    KTemp95 = prctile(KTemp,95);
    KTempMean = nanmean(KTemp);
    errorbar(xAxis,KTempMean + (i-1) * 35,KTempMean-KTemp5,KTemp95-KTempMean,'k')
    subplot(1,2,2)
    GrTemp = Gr{i}';
    %GrTemp = max(GrTemp,0);
    GrTemp5 = prctile(GrTemp,5);
    GrTemp95 = prctile(GrTemp,95);
    
    GrTempMean = nanmean(GrTemp);
    errorbar(xAxis,GrTempMean + (i-1) * 15,GrTempMean-GrTemp5,GrTemp95-GrTempMean,'k')
end
subplot(1,2,1)
xlabel('Torque (Nm)')
ylabel('Elastic parameter (Nm/rad)')
title('Elastic Parameter')
set(gca,'Ytick',[0,15,30,45],'YTickLabel',{'0','15', '30', '45'})
subplot(1,2,2)
xlabel('Torque (Nm)')
ylabel('Reflex Gain (Nms/rad)')
title('Reflex Gain')
set(gca,'Ytick',[0,5,10,15,20],'YTickLabel',{'0', '5', '10','15','20'})
%%
figure
hold on
xAxisTicks = [2;4;6];
for i = 1 : numLevelsLen
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
        %legend('SDSS','SS-SDSS');
    end
    errorbar(xAxisTicks(i)-0.3,vafTot_SDSSThisLevelMean,...
        vafTot_SDSSThisLevelMean-vafTot_SDSSThisLevel5,...
        vafTot_SDSSThisLevel95-vafTot_SDSSThisLevelMean,'color','k','lineWidth',2)
    
    errorbar(xAxisTicks(i)+0.3,vafTot_SS_SDSSThisLevelMean,...
        vafTot_SS_SDSSThisLevelMean-vafTot_SS_SDSSThisLevel5,...
        vafTot_SS_SDSSThisLevel95-vafTot_SS_SDSSThisLevelMean,'color','k','lineWidth',2)
    if pValue < 0.05
        plot(xAxisTicks(i),100,'*','MarkerEdgeColor','k','markerSize',10)
    end
end
set(gca,'Xtick',[xAxisTicks(i)-0.3,xAxisTicks(i)+0.3],'XTickLabel',{'SDSS', 'SS-SDSS'})
ylim([0,105])
%xlabel('Number of bins')
ylabel('%VAF total')
title('Identification %VAF')