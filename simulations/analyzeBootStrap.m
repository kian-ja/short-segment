clear
load results/LPVSimulationData1Trial
plotFlag = 0;
position = positionMC';
torque = totalTorqueMC';
intrinsicTorque = intrinsicTorqueMC';
reflexTorque = reflexTorqueMC';
position = position - mean(position);
voluntaryTorque = schedulingVariableMC';
torque = torque - mean(torque);
samplingTime = 0.001;
%%
order = 2;
numLevels = [4 7 10];
mcItr = 100;
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
            intrinsicTorqueSeg = segdat(intrinsicTorque,'onsetPointer',jumpStartThisIteration,...
            'segLength',jumpEndThisIteration-jumpStartThisIteration+1,'domainIncr',samplingTime...
            ,'comment','Torque','chanNames','Joint torque (Nm)');
            reflexTorqueSeg = segdat(reflexTorque,'onsetPointer',jumpStartThisIteration,...
            'segLength',jumpEndThisIteration-jumpStartThisIteration+1,'domainIncr',samplingTime...
            ,'comment','Torque','chanNames','Joint torque (Nm)');
            z = cat(2,positionSeg,torqueSeg);
            sysIDTemp{lvlIndex,mcIndex} = pcas_short_segment_exp_new_intrinsic_irf1 (z,8,20,0.05,order,intrinsicTorqueSeg,reflexTorqueSeg);
            z = cat(2,nldat(positionSeg),nldat(torqueSeg));
            sysID_SDSS_Temp{lvlIndex,mcIndex} = sdss(z,8,20,0.03,order);
            segmentsLengthMeanTemp(lvlIndex,mcIndex) = mean(jumpEndThisIteration-jumpStartThisIteration+1);
            segmentsLengthStdTemp(lvlIndex,mcIndex) =  std(jumpEndThisIteration-jumpStartThisIteration+1);
        end
    end
    segmentsLengthMean{numLVLIndex} = segmentsLengthMeanTemp;
    segmentsLengthStd{numLVLIndex} = segmentsLengthStdTemp;
    sysID{numLVLIndex} = sysIDTemp;
    sysID_SDSS{numLVLIndex} = sysID_SDSS_Temp;
end
%%
save results/segmentLengthInfo segmentsLengthMean segmentsLengthStd
save results/systemIDExperiment sysID sysID_SDSS