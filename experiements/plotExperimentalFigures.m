load results/quasiStationaryExperimentResults
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
VAF_SDSS = zeros(3,6,100);
VAF_SS_SDSS = zeros(3,6,100);
incr = 1;
for i = 1 : 3
    for j = 1 : 6
        for k = 1 : 100
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
[intrinsic,reflex] = extractIntrinsicReflex(SS_SDSS_System);

figure
subplot(2,3,1)
[intrinsicFRFIDMean,intrinsicFRFID25,intrinsicFRFID975,frequencyAxis] = intrinsicFRF_MonteCarlo(intrinsic{1,:,:});
ciplot(intrinsicFRFID25,intrinsicFRFID975,log10(frequencyAxis),[190 190 190]/255)
hold on
plot(log10(frequencyAxis),intrinsicFRFIDMean,'r','lineWidth',2)
ax = gca;
set(ax,'xTick',[log10(0.01),log10(0.1),log10(1),log10(10)])
set(ax,'XTickLabel',{'0.01','0.1','1','10'})
xlim([log10(0.01),log10(50)])

title('Intrinsic PF')
subplot(2,3,2)
title('Intrinsic REST')
subplot(2,3,3)
title('Intrinsic DF')
subplot(2,2,3)
title('Reflex NL PF')
subplot(2,2,4)
title('Reflex linear PF')