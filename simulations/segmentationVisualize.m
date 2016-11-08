close all
clear
clc
load results/LPVSimulationData1Trial
position = positionMC(1:60000);
torque = totalTorqueNoisyMC(1:60000);
intrinsicTorque = intrinsicTorqueMC(1:60000);
reflexTorque = reflexTorqueMC(1:60000);
sv = schedulingVariableMC(1:60000);
time = 0 : 0.001: 60 - 0.001;
%%
numBins = 6+1;
levels = linspace(min(sv),max(sv),numBins);
colors = distinguishable_colors(numBins);

figure(1)
subplot(5,1,1)
plot(time,sv,'lineWidth',0.2,'Color',colors(1,:))

hold on
subplot(5,1,2)
plot(time,position,'Color',colors(1,:))

hold on
subplot(5,1,3)
plot(time,-intrinsicTorque,'Color',colors(1,:))

hold on
subplot(5,1,4)
plot(time,-reflexTorque,'Color',colors(1,:))

hold on
subplot(5,1,5)
plot(time,-torque,'Color',colors(1,:))
hold on
%figure(2)

for lvlIndex = 1 : numBins - 1
    figure(1)
    commandLevels = [levels(lvlIndex) levels(lvlIndex+1)];
    [jumpStart,jumpEnd] = findSegmentTQVaryingSimulation(sv',commandLevels,500);
    subplot(5,1,1)
    plot([0,60],[commandLevels(1),commandLevels(1)],'--','color','k')
    hold on
    for segNumIndex = 1 : length(jumpStart)
        subplot(5,1,1)
        plot(time(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            sv(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            'Color',colors(lvlIndex+1,:),'lineWidth',2)
        
        %figure(2)
        %plot(time(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
        %    sv(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
        %    'Color',colors(lvlIndex+1,:),'lineWidth',2)
        %hold on
        figure(1)
        subplot(5,1,2)
        plot(time(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            position(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            'Color',colors(lvlIndex+1,:))
        subplot(5,1,3)
        plot(time(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            -intrinsicTorque(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            'Color',colors(lvlIndex+1,:))
        subplot(5,1,4)
        plot(time(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            -reflexTorque(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            'Color',colors(lvlIndex+1,:))
        subplot(5,1,5)
        plot(time(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            -torque(jumpStart(segNumIndex):jumpEnd(segNumIndex)),...
            'Color',colors(lvlIndex+1,:))
    end
end
subplot(5,1,1)
plot([0,60],[commandLevels(2),commandLevels(2)],'--','color','k')

figure(1)
subplot(5,1,1)
title('Position Trajectory')
ylabel('Position (rad)')
set(gca, 'XTick', []);

subplot(5,1,2)
%ylim([-0.05,0.05])
set(gca, 'XTick', []);
title('Position Perturbations')
ylabel('Position (rad)')
subplot(5,1,3)
set(gca, 'XTick', []);
%ylim([-17.5,10])
title('Intrinsic Torque')
ylabel('Torque (Nm)')
subplot(5,1,4)
set(gca, 'XTick', []);
%ylim([-17.5,10])
title('Reflex Torque')
ylabel('Torque (Nm)')
subplot(5,1,5)
ylim([-20,10])
xlabel('Time (s)')
ylabel('Torque (Nm)')
title('Total Torque')
xAxisPanZoom
xlim([48,58])