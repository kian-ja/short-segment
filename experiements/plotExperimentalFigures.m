load results/quasiStationaryExperimentResults
load results/positionSample
mCIteration = 100;
%First dimension is contraction direction:
%   1) DF
%   2)REST
%   3)PF
%Second dimension is segment length
% 500, 600, 700, 800, 900, 1000 ms
%Third dimension is the number of MC iteration 1:100
%Fourth dimension is the results:
%   1)intrinsic system
%   1)reflex system
%   1)VAF
%%
%First collapse all the VAF total to generate a box whisker plot
%To show that SS-SDSS is significantly better than SDSS
VAF_SDSS = zeros(3,6,mCIteration);
VAF_SS_SDSS = zeros(3,6,mCIteration);
for i = 1 : 3
    for j = 1 : 6
        for k = 1 : mCIteration
            v = SDSS_System{i,j,k,3};
            VAF_SDSS(i,j,k) = v (1);
            v = SS_SDSS_System{i,j,k,3};
            VAF_SS_SDSS(i,j,k) = v (1);
        end
    end
end
vafs = [VAF_SDSS(:) VAF_SS_SDSS(:)];
pp = pValueSign2Sided(vafs(:,2)',vafs(:,1)');
figure
boxplot(vafs,'Labels',{'SDSS','SS-SDSS'})
ylabel('%VAF_{total}')
ylim([0,100])
box off
%%
%Check for dependency to the segment length
%Collapse across segment length
%To show that the VAF does not change as a function of segment length
VAF_SS_SDSS_SegLength = zeros(300,6);
for i = 1 : 6
    v = VAF_SS_SDSS(:,i,:);
    v = v(:);
    VAF_SS_SDSS_SegLength(:,i) = v;
end
anovaResults = anova1(VAF_SS_SDSS_SegLength);
ax = gca;

ax.XTickLabel = {'0.5','0.6','0.7','0.8','0.9','1'};
title(['P Value : ',num2str(anovaResults(1)*100),'%'])
box off
ylabel('%VAF_{total}')
xlabel('segment length (s)')
%%
%plot the system for the three contraction directions
%Now collapse across contraction direction
%%
[intrinsic,reflexNL,reflexSS] = extractIntrinsicReflex(SS_SDSS_System);
intrinsicDF = cell(6*mCIteration,1);
incr = 1 ;
for i = 1 : 6
    for j = 1 : mCIteration
        intrinsicDF{incr} = intrinsic{1,i,j};
        incr = incr + 1;
    end
end
figure
subplot(2,3,1)
[intrinsicFRFIDMeanDF,intrinsicFRFID25DF,intrinsicFRFID975DF,frequencyAxis] = intrinsicFRF_MonteCarlo(intrinsicDF,position);
ciplot(intrinsicFRFID25DF,intrinsicFRFID975DF,log10(frequencyAxis),[190 190 190]/255)
hold on
plot(log10(frequencyAxis),intrinsicFRFIDMeanDF,'r','lineWidth',2)
ax = gca;
set(ax,'xTick',[log10(0.01),log10(0.1),log10(1),log10(10)])
set(ax,'XTickLabel',{'0.01','0.1','1','10'})
xlim([log10(0.01),log10(50)])
title('Intrinsic PF')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
ylim([20,60])
subplot(2,3,2)
intrinsicREST = cell(600,1);
incr = 1 ;
for i = 1 : 6
    for j = 1 : mCIteration
        intrinsicREST{incr} = intrinsic{2,i,j};
        incr = incr + 1;
    end
end
[intrinsicFRFIDMeanREST,intrinsicFRFID25REST,intrinsicFRFID975REST,frequencyAxis] = intrinsicFRF_MonteCarlo(intrinsicREST,position);
ciplot(intrinsicFRFID25REST,intrinsicFRFID975REST,log10(frequencyAxis),[190 190 190]/255)
hold on
plot(log10(frequencyAxis),intrinsicFRFIDMeanREST,'r','lineWidth',2)
ax = gca;
set(ax,'xTick',[log10(0.01),log10(0.1),log10(1),log10(10)])
set(ax,'XTickLabel',{'0.01','0.1','1','10'})
xlim([log10(0.01),log10(50)])
title('Intrinsic REST')
xlabel('Frequency (Hz)')
ylim([20,60])
subplot(2,3,3)
intrinsicPF = cell(6*mCIteration,1);
incr = 1 ;
for i = 1 : 6
    for j = 1 : mCIteration
        intrinsicPF{incr} = intrinsic{3,i,j};
        incr = incr + 1;
    end
end
[intrinsicFRFIDMeanPF,intrinsicFRFID25PF,intrinsicFRFID975PF,frequencyAxis] = intrinsicFRF_MonteCarlo(intrinsicPF,position);
ciplot(intrinsicFRFID25PF,intrinsicFRFID975PF,log10(frequencyAxis),[190 190 190]/255)
hold on
plot(log10(frequencyAxis),intrinsicFRFIDMeanPF,'r','lineWidth',2)
ax = gca;
set(ax,'xTick',[log10(0.01),log10(0.1),log10(1),log10(10)])
set(ax,'XTickLabel',{'0.01','0.1','1','10'})
xlim([log10(0.01),log10(50)])
title('Intrinsic PF')
xlabel('Frequency (Hz)')
ylim([10,60])
subplot(2,2,3)
%%
reflexNLPF = [];%cell(mCIteration,1);
incr = 1 ;
for i = 1 : 1
    for j = 1 : mCIteration
         nlTemp = reflexNL{3,i,j};
         if isnan(nlTemp.polyCoef)
         else
             figure(100)
             plot(nlTemp)
             flip = input('Flip?','s');
             if flip == 'y'
                 nlTemp.polyCoef = - nlTemp.polyCoef;
             end
             reflexNLPF{incr} = nlTemp;
             close(100)
             incr = incr + 1;
         end
    end
end
title('Reflex static nonlinearity PF')
[reflexNLMeanPF,reflexNL25PF,reflexNL975PF,xAxis] = reflexNL_MonteCarlo(reflexNLPF);
ciplot(reflexNL25PF,reflexNL975PF,xAxis,[190 190 190]/255)
hold on
plot(xAxis,reflexNLMeanPF,'r','lineWidth',2)
%%
subplot(2,2,4)
reflexSSPF = cell(mCIteration,1);
incr = 1 ;
for i = 1 : 1
    for j = 1 : mCIteration
        reflexSSPF{incr} = reflexSS{3,i,j};
        incr = incr + 1;
    end
end
[reflexSSMeanPF,reflexSS25PF,reflexSS975PF] = reflexSS_MonteCarlo(reflexSSPF,frequencyAxis);

ciplot(reflexSS25PF,reflexSS975PF,log10(frequencyAxis),[190 190 190]/255);
hold on
plot(log10(frequencyAxis),reflexSSMeanPF,'r','lineWidth',2)
ax = gca;
set(ax,'xTick',[log10(0.01),log10(0.1),log10(1),log10(10)])
set(ax,'XTickLabel',{'0.01','0.1','1','10'})
xlim([log10(0.01),log10(50)])
title('Reflex linear dynamics PF')
xlabel('Frequency (Hz)')

title('Reflex linear PF')