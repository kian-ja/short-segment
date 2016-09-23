clear
load results/experimentalTQVaryingData
load results/filterTorque
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
%%
desiredTorque = 0;
order = 2;
numLevels = 3:7;
mcItr = 100;
minTQ = prctile(voluntaryTorque,5);
maxTQ = prctile(voluntaryTorque,95);
sysID = cell(length(numLevels),1);
for numLVLIndex = 1 : length(numLevels)
    disp(['# of levels is : ',num2str(numLevels(numLVLIndex))])
    levels = linspace(minTQ,maxTQ,numLevels(numLVLIndex));
    sysIDTemp = cell(numLevels(numLVLIndex)-1,mcItr);
    for lvlIndex = 1 : numLevels(numLVLIndex) - 1
        disp(['Now checking level : ',num2str(lvlIndex),' out of ',num2str(numLevels(numLVLIndex)-1)])
        commandLevels = [levels(lvlIndex) levels(lvlIndex+1)];
        [jumpStart,jumpEnd] = findSegmentTQVaryingExperiment(voluntaryTorque,commandLevels,500);
        for mcIndex = 1 : mcItr
            disp(['Now checking MC trial: ',num2str(mcIndex),' out of',num2str(mcItr)])
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
            sysIDTemp{lvlIndex,mcIndex} = pcas_short_segment_exp_new_intrinsic_irf1 (z,'maxordernle',8,'hanklesize',20,'delayinput',0.03,'orderselectmethod',order,'stationarity_check',1);
        end
    end
    sysID{numLVLIndex} = sysIDTemp;
end