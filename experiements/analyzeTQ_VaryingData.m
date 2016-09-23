clear
load results/experimentalTQVaryingData
load results/filterTorque
position = subject1.position;
torque = subject1.torque;
position = position - mean(position);
torque = torque - mean(torque);
voluntaryTorque = nlsim(filterTorque,nldat(torque,'domainIncr',0.001));
voluntaryTorque = voluntaryTorque.dataSet;
voluntaryTorque = smooth(voluntaryTorque,1500);
voluntaryTorqueDiff = ddt(nldat(voluntaryTorque,'domainIncr',0.001));
voluntaryTorqueDiff = voluntaryTorqueDiff.dataSet;
torque = torque - voluntaryTorque;
samplingTime = 0.001;
%%
desiredTorque = 0;
order = 2;
numLevels = 10;
minTQ = prctile(voluntaryTorque,5);
maxTQ = prctile(voluntaryTorque,95);
levels = linspace(minTQ,maxTQ,numLevels);
jumpIndex = cell(numLevels - 1,1);
sysID = cell(numLevels -1,1);
for i = 1 : numLevels - 1
    commandLevels = [levels(i) levels(i+1)];
    [jumpsStart,jumpsEnd] = findSegmentDirection(voluntaryTorque,commandLevels,voluntaryTorqueDiff,500);
    for j = 1 : 2
        jumpStart = jumpsStart{j};
        jumpEnd = jumpsEnd{j};
        plot(torque)
        hold on
        for k = 1 : length(jumpStart)
            plot(jumpStart(k):jumpEnd(k),torque(jumpStart(k):jumpEnd(k)),'r')
        end
        pause
        close all
        positionSeg = segdat(position,'onsetPointer',jumpStart,...
                'segLength',jumpEnd-jumpStart,'domainIncr',samplingTime...
                ,'comment','Position','chanNames','Joint angular position (rad)');
        torqueSeg = segdat(torque,'onsetPointer',jumpStart,...
                'segLength',jumpEnd-jumpStart,'domainIncr',samplingTime...
                ,'comment','Torque','chanNames','Joint torque (Nm)');
            z = cat(2,positionSeg,torqueSeg);
        sysID{i} = pcas_short_segment_exp_new_intrinsic_irf1 (z,'maxordernle',8,'hanklesize',20,'delayinput',0.03,'orderselectmethod','manual','stationarity_check',1);
    end
    
end