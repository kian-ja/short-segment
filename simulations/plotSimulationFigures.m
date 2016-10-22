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
schedulingSegmentNumber = 3:3:12;
monteCarloIteration = size(systemID_SS_SDSS,2);
vafIntrinsic = cell(length(schedulingSegmentNumber),1);
vafReflex = cell(length(schedulingSegmentNumber),1);
vafIntrinsic_SDSS = cell(length(schedulingSegmentNumber),1);
vafReflex_SDSS = cell(length(schedulingSegmentNumber),1);

stiffness = cell(length(schedulingSegmentNumber),1);
reflexGain = cell(length(schedulingSegmentNumber),1);

x = -2:0.001:2;
x = nldat(x','domainIncr',0.001);

for i = 1 : length(schedulingSegmentNumber)
    disp(['Preparing data: ',num2str(i),' out of ',num2str(length(schedulingSegmentNumber))]);
    vafIntrinsicTemp = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    vafReflexTemp = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    vafIntrinsicTemp_SDSS = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    vafReflexTemp_SDSS = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    stiffnessTemp = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    reflexGainTemp = zeros(monteCarloIteration,schedulingSegmentNumber(i));
    for j = 1 : monteCarloIteration
        system = systemID_SS_SDSS{i,j};
        system_SDSS = systemID_SDSS{i,j};
        for k = 1 : length(system)
            systemTemp = system{k};
            systemTemp_SDSS = system_SDSS{k};
            vafs = systemTemp{3};
            vafs_SDSS = systemTemp_SDSS{3};
            intrinsic = systemTemp{1};
            reflex = systemTemp{2};
            nonlin = reflex{1};
            intrinsic = intrinsic.dataSet;
            stiffnessTemp(j,k) = sum(intrinsic)/100;
            vafIntrinsicTemp(j,k) = vafs(2);
            vafReflexTemp(j,k) = vafs(3);
            vafIntrinsicTemp_SDSS(j,k) = vafs_SDSS(2);
            vafReflexTemp_SDSS(j,k) = vafs_SDSS(3);
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
    vafIntrinsic_SDSS{i} = vafIntrinsicTemp_SDSS;
    vafReflex_SDSS{i} = vafReflexTemp_SDSS;
    stiffness{i} = stiffnessTemp;
    reflexGain{i} = reflexGainTemp;
end
%%
xAxis = [1 2 3 4];
figure(1)
subplot(1,2,1)
hold on
subplot(1,2,2)
hold on
for i = 1 : length(schedulingSegmentNumber)
    vafIntrinsic_SS_SDSS_Temp = vafIntrinsic{i};
    vafIntrinsic_SS_SDSS_Temp = max(vafIntrinsic_SS_SDSS_Temp,0);
    vafIntrinsic_SDSS_Temp = vafIntrinsic_SDSS{i};
    vafIntrinsic_SDSS_Temp = max(vafIntrinsic_SDSS_Temp,0);
    vafReflex_SS_SDSS_Temp = vafReflex{i};
    vafReflex_SS_SDSS_Temp = max(vafReflex_SS_SDSS_Temp,0);
    vafReflex_SDSS_Temp = vafReflex_SDSS{i};
    vafReflex_SDSS_Temp = max(vafReflex_SDSS_Temp,0);
    vafIntrinsic_SS_SDSS_Temp = vafIntrinsic_SS_SDSS_Temp(:);
    vafIntrinsic_SDSS_Temp = vafIntrinsic_SDSS_Temp(:);
    vafReflex_SS_SDSS_Temp = vafReflex_SS_SDSS_Temp(:);
    vafReflex_SDSS_Temp = vafReflex_SDSS_Temp(:);
    subplot(1,2,1)
    meanVAFIntrinsicSS_SDSS = mean(vafIntrinsic_SS_SDSS_Temp);
    meanVAFIntrinsic_SDSS = mean(vafIntrinsic_SDSS_Temp);
    prctile25VAFIntrinsicSS_SDSS = prctile(vafIntrinsic_SS_SDSS_Temp,5);
    prctile975VAFIntrinsicSS_SDSS = prctile(vafIntrinsic_SS_SDSS_Temp,95);
    prctile25VAFIntrinsic_SDSS = prctile(vafIntrinsic_SDSS_Temp,5);
    prctile975VAFIntrinsic_SDSS = prctile(vafIntrinsic_SDSS_Temp,95);
    
    meanVAFReflexSS_SDSS = mean(vafReflex_SS_SDSS_Temp);
    meanVAFReflex_SDSS = mean(vafReflex_SDSS_Temp);
    prctile25VAFReflexSS_SDSS = prctile(vafReflex_SS_SDSS_Temp,5);
    prctile975VAFReflexSS_SDSS = prctile(vafReflex_SS_SDSS_Temp,95);
    prctile25VAFReflex_SDSS = prctile(vafReflex_SDSS_Temp,5);
    prctile975VAFReflex_SDSS = prctile(vafReflex_SDSS_Temp,95);
    
    bar(xAxis(i)-0.15,meanVAFIntrinsic_SDSS,0.25,'FaceColor',[0.95,0.95,0.95])
    bar(xAxis(i)+0.15,meanVAFIntrinsicSS_SDSS,0.25,'FaceColor',[0.45,0.45,0.45])
    if i == 1 
        legend('SDSS','SS-SDSS')
    end
    errorbar(xAxis(i)-0.15,meanVAFIntrinsic_SDSS,meanVAFIntrinsic_SDSS-prctile25VAFIntrinsic_SDSS...
        ,prctile975VAFIntrinsic_SDSS-meanVAFIntrinsic_SDSS,'k','lineWidth',2)
    errorbar(xAxis(i)+0.15,meanVAFIntrinsicSS_SDSS,meanVAFIntrinsicSS_SDSS-prctile25VAFIntrinsicSS_SDSS...
        ,prctile975VAFIntrinsicSS_SDSS-meanVAFIntrinsicSS_SDSS,'k','lineWidth',2)
    axis square
    
    subplot(1,2,2)
    bar(xAxis(i)-0.15,meanVAFIntrinsic_SDSS,0.25,'FaceColor',[0.95,0.95,0.95])
    bar(xAxis(i)+0.15,meanVAFIntrinsicSS_SDSS,0.25,'FaceColor',[0.45,0.45,0.45])
    errorbar(xAxis(i)-0.15,meanVAFReflex_SDSS,meanVAFReflex_SDSS-prctile25VAFReflex_SDSS...
        ,prctile975VAFReflex_SDSS-meanVAFReflex_SDSS,'k','lineWidth',2)
    errorbar(xAxis(i)+0.15,meanVAFReflexSS_SDSS,meanVAFReflexSS_SDSS-prctile25VAFReflexSS_SDSS...
        ,prctile975VAFReflexSS_SDSS-meanVAFReflexSS_SDSS,'k','lineWidth',2)
    axis square
end
subplot(1,2,1)
set(gca,'Xtick',1:4,'XTickLabel',{'3', '6', '9', '12'})
set(gca,'Ytick',0:25:100,'YTickLabel',{'0', '25', '50', '75','100'})
xlabel('Number of bins')
ylabel('%VAF Intrinsic')
plot(xAxis,[105,105,105,105],'*','MarkerEdgeColor','k')
ylim([0,110])
title('Intrinsic Pathway Identification')
subplot(1,2,2)
set(gca,'Xtick',1:4,'XTickLabel',{'3', '6', '9', '12'})
set(gca,'Ytick',[],'YTickLabel',[])
xlabel('Number of bins')
ylabel('%VAF Reflex')
plot(xAxis,[105,105,105,105],'*','MarkerEdgeColor','k')
ylim([0,110])
title('Reflex Pathway Identification')
%%
subplot(1,2,2)

for i = 1 : length(schedulingSegmentNumber)
    figure(1)
    subplot(length(schedulingSegmentNumber),1,i)
    boxplot(vafIntrinsic{i})
    if i == 1
        title('VAF Intrinsic')
    end
    figure(2)
    subplot(length(schedulingSegmentNumber),1,i)
    boxplot(vafReflex{i})
    if i == 1
        title('VAF Reflex')
    end
    
end
%%
   
figure
subplot(1,2,1)
positionLevels = [-0.48 -0.4 -0.32 -0.24 -0.16 -0.08 0.0 0.08 0.16 0.24];%from Mirbagheri et al 2000
K = [0.45 0.47 0.48 0.5 0.52 0.55 0.6 0.7 0.8 1];
polyCoeffK = 50 * polyfit(positionLevels,K,5);
posLevel = -0.48:0.01:0.24;
KTrue = polyval(polyCoeffK,posLevel);
for i = 1 : length(schedulingSegmentNumber)
    posAxis = linspace(-0.48,0.24,size(stiffness{i},2));
    errorbar(posAxis,mean(stiffness{i}) + (i-1) * 20,std(stiffness{i})...
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
Gr = [0.0625,0.0938,0.1042,0.1094,0.2813,0.5000,0.6250,0.7000,0.8000,0.8100];%from Mirbagheri et al 2000
Gr = Gr + 0.1;
polyCoeffGr = 40 * polyfit(positionLevels,Gr,5);
posLevel = -0.48:0.01:0.24;
GrTrue = polyval(polyCoeffGr,posLevel);
for i = 1 : length(schedulingSegmentNumber)
    reflexGainTemp = reflexGain{i};
    
    posAxis = linspace(-0.48,0.24,size(reflexGainTemp,2));
    errorbar(posAxis,nanmean(reflexGainTemp) + (i-1) * 10,...
        nanstd(reflexGainTemp),'lineWidth',2,'color','r','lineStyle','--')
    hold on
    plot(posLevel,GrTrue + (i-1) * 10,'lineWidth',2,'color','k')
    if i == 1 
        legend('Estimate','True')
    end

end
xlabel('Position (rad)')
ylabel('Reflex gain (Nms/rad)')
set(gca,'Ytick',0:10:35,'YTickLabel',{'0', '10', '20', '30'})
title('Reflex Gain')
box off