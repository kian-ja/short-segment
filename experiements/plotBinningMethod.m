clear
load results/experimentalTQVaryingData
load results/filterTorque
%%
position = subject1.position;
torque = subject1.torque;
emg = subject1.emg;
voluntaryTorque = subject1.voluntaryTorque;
nBins = 8;
colors = distinguishable_colors(nBins);

onsetPlotTime = 5;
finalPlotTime = 25;
%time = 0:0.001:(finalPlotTime-onsetPlotTime+1)/1000-0.001;
time = 0:0.001:length(position)/1000-0.001;
%%
minTQ = prctile(voluntaryTorque,5);
maxTQ = prctile(voluntaryTorque,95);
voluntaryTorque = voluntaryTorque - maxTQ;
torque = torque - maxTQ;
minTQ = minTQ - maxTQ;
maxTQ = 0;

levels = linspace(minTQ,maxTQ,nBins + 1);
figure
subplot(4,1,1)
plot(time(1:60000),position(1:60000),'color','k')
ylabel('Position (rad)')
title('Joint Position')
box off
set(gca,'XTick',[])

subplot(4,1,2)
plot(time(1:60000),voluntaryTorque(1:60000),'color',[192,192,192]/255)
hold on
for i = 1 : length(levels) - 1
    commandLevels = [levels(i) levels(i+1)];
    [jumpStart,jumpEnd] = findSegmentTQVaryingExperiment(voluntaryTorque,commandLevels,200);%segmentMinLength);
    for j = 1 : length(jumpStart)
        if (40000<jumpStart(j))&&(jumpStart(j)<51000)
            plot(time(jumpStart(j):jumpEnd(j)),voluntaryTorque(jumpStart(j):jumpEnd(j))...
                ,'Color',colors(i,:),'lineWidth',2)
        end
    end
    plot([time(1),time(60000)],[levels(i),levels(i)],'--','Color','k')
end
plot([time(1),time(60000)],[levels(i+1),levels(i+1)],'--','Color','k')
ylim([-10,1])
ylabel('Torque (Nm)')
title('Voluntary Torque')
box off
set(gca,'XTick',[])
subplot(4,1,3)
plot(time(1:60000),torque(1:60000),'color',[192,192,192]/255)
hold on
for i = 1 : length(levels) - 1
    commandLevels = [levels(i) levels(i+1)];
    [jumpStart,jumpEnd] = findSegmentTQVaryingExperiment(voluntaryTorque,commandLevels,200);%segmentMinLength);
    for j = 1 : length(jumpStart)
        if (40000<jumpStart(j))&&(jumpStart(j)<51000)
            plot(time(jumpStart(j):jumpEnd(j)),torque...
                (jumpStart(j):jumpEnd(j)),'Color',colors(i,:),'lineWidth',2)
        end
    end
end
%hold on
%plot(time,voluntaryTorque,'--k')
ylim([-20,10])
ylabel('Torque (Nm)')
title('Total Torque')
box off
set(gca,'XTick',[])
subplot(4,1,4)
plot(time(1:60000),emg(1:60000),'color','k')
xAxisPanZoom
xlim([41,51])
ylabel('Torque (Nm)')
title('EMG (v)')
box off
%%
clear
load results/experimentalTQVaryingData
load results/filterTorque
warning off
plotFlag = 0;
position = subject1.position;
torque = subject1.torque;
position = position - mean(position);
voluntaryTorque = subject1.voluntaryTorque;
torque = torque - mean(torque);
%voluntaryTorque = nlsim(filterTorque,nldat(torque,'domainIncr',0.001));
%voluntaryTorque = voluntaryTorque.dataSet;
%voluntaryTorque = smooth(voluntaryTorque,1500);
voluntaryTorqueDiff = ddt(nldat(voluntaryTorque,'domainIncr',0.001));
voluntaryTorqueDiff = voluntaryTorqueDiff.dataSet;
torque = torque - voluntaryTorque;
samplingTime = 0.001;
hankleSize = 15;
segmentMinLength = 10 * (2 * hankleSize - 1);
%%
desiredTorque = 0;
order = 2;
numLevels = [9];
mcItr = 1;
minTQ = prctile(voluntaryTorque,5);
maxTQ = prctile(voluntaryTorque,95);
sysID = cell(length(numLevels),1);
sysID_SDSS = cell(length(numLevels),1);
segmentsLengthMean = cell(length(numLevels),1);
segmentsLengthStd = cell(length(numLevels),1);
for numLVLIndex = 1 : length(numLevels)
    disp(['# of levels is : ',num2str(numLevels(numLVLIndex))])
    levels = linspace(minTQ,maxTQ,numLevels(numLVLIndex));
    sysIDTemp = cell(numLevels(numLVLIndex)-1,mcItr);
    sysID_SDSS_Temp = cell(numLevels(numLVLIndex)-1,mcItr);
    segmentsLengthMeanTemp = zeros(numLevels(numLVLIndex)-1,mcItr);
    segmentsLengthStdTemp = zeros(numLevels(numLVLIndex)-1,mcItr);
    for lvlIndex = 1 : numLevels(numLVLIndex) - 1
        disp(['Now checking level : ',num2str(lvlIndex),' out of ',num2str(numLevels(numLVLIndex)-1)])
        commandLevels = [levels(lvlIndex) levels(lvlIndex+1)];
        [jumpStart,jumpEnd] = findSegmentTQVaryingExperiment(voluntaryTorque,commandLevels,200);%segmentMinLength);
        for mcIndex = 1 : mcItr
            dataLength = 0;
            jumpStartThisIteration =[];
            jumpEndThisIteration =[];
            while (dataLength<60000)
                selectedSegment = randi(length(jumpStart));
                jumpStartThisIteration = [jumpStartThisIteration;jumpStart(selectedSegment)];
                jumpEndThisIteration = [jumpEndThisIteration;jumpEnd(selectedSegment)];
                dataLength = dataLength + jumpEndThisIteration(end) - jumpStartThisIteration(end);
            end
            positionSeg = segdat(position,'onsetPointer',jumpStartThisIteration,...
            'segLength',jumpEndThisIteration-jumpStartThisIteration+1,'domainIncr',samplingTime...
            ,'comment','Position','chanNames','Joint angular position (rad)');
            torqueSeg = segdat(torque,'onsetPointer',jumpStartThisIteration,...
            'segLength',jumpEndThisIteration-jumpStartThisIteration+1,'domainIncr',samplingTime...
            ,'comment','Torque','chanNames','Joint torque (Nm)');
            z = cat(2,positionSeg,torqueSeg);
            
            sys = pcas_short_segment_exp_new_intrinsic_irf1 (z,'maxordernle',12,'hanklesize',15,'delayinput',0.04,'orderselectmethod',order,'stationarity_check',1,'plot_mode',0);
           
            subplot(2,1,1)
            plot(sys{1})
            pos = nldat(position,'domainIncr',0.001);

            posd = decimate(pos,10);
            intrinsicTorque = nlsim(sys{1},posd);
            z = cat(2,posd,intrinsicTorque);
            intrinsicFRF = fresp(z,'nFFT',600);
            intrinsicFRF = intrinsicFRF.dataSet;
            intrinsicFRF = 20*log10(abs(intrinsicFRF(:,1)));
            frequencyAxis = linspace(0.01,50,length(intrinsicFRF));
            plot(log10(frequencyAxis),intrinsicFRF,'k','lineWidth',2)
            ax = gca;
            set(ax,'xTick',[log10(0.01),log10(0.1),log10(1),log10(10)])
            set(ax,'XTickLabel',{'0.01','0.1','1','10'})
            xlim([log10(0.01),log10(50)])

            axis square
            xlabel('Frequency (Hz)')
            ylabel('Gain (dB)')
            title('Intrinsic Dynamics')
            reflex = sys{2};
            subplot(2,2,3)
            nonlin = reflex{1};
            x = -2:0.01:2.5;
            if isnan(nonlin.polyCoef)
                y = 0 * x;
            else
                y = nlsim(nonlin,nldat(x','domainIncr',0.01));
                y = y.dataSet;
            end
            plot(x,y,'lineWidth',2,'Color','k')
            axis square
            xlim([-2,2.5])
            xlabel('Input (rad/s)')
            ylabel('Output (rad/s)')
            title('Reflex Static Nonlinearity')
            subplot(2,2,4)
            %plot(reflex{2})
            reflexLinear = reflex{2};
            if isempty(reflexLinear.A)
                mag = frequencyAxis * 0;
                mag = 20* log10(mag);
            else
                
                [mag,~] = bode(ss(reflexLinear.A,reflexLinear.B,reflexLinear.C,reflexLinear.D,0.01),frequencyAxis*2*pi);
                mag = 20*log10(shiftdim(mag,2));
            end
            plot(log10(frequencyAxis),mag,'k','lineWidth',2)
            ax = gca;
            set(ax,'xTick',[log10(0.01),log10(0.1),log10(1),log10(10)])
            set(ax,'XTickLabel',{'0.01','0.1','1','10'})
            xlim([log10(0.01),log10(50)])
            xlabel('Frequency (Hz)')
            ylabel('Gain (dB)')
            title('Reflex Linear Dynamics')
            axis square
            %%
            pause
        end
    end
end