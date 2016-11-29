%parpool(2)
warning off
clear
load results/LPVSimulationData1Trial2
%load results/filterTorque
samplingTime = 0.001;
plotFlag = 0;
position = positionMC';
torque = totalTorqueNoisyMC';
intrinsicTorque = intrinsicTorqueMC';
reflexTorque = reflexTorqueMC';
position = position - mean(position);
schedulingVariable = schedulingVariableMC';

%torqueSV = nlsim(filterTorque,nldat(torque,'domainIncr',0.001));
%torqueSV = torqueSV.dataSet;
%torqueSV = smooth(torqueSV,1500);
%torquePert = torque - torqueSV;
%torquePert = torquePert - mean(torquePert);    
%plot(torquePert)
%hold on
totalTorquePert = totalTorquePert - mean(totalTorquePert);
%plot(totalTorquePert)
torquePert = totalTorqueNoisyMC;
torquePert = torquePert - mean(torquePert);    
%%
order = 2;
numLevels = [9];
mcItr = 200;
hankleSize = 15;
minTQ = prctile(schedulingVariable,5);
maxTQ = prctile(schedulingVariable,95);
sysID = cell(length(numLevels),1);
sysID_SDSS = cell(length(numLevels),1);
segmentsLengthMean = cell(length(numLevels),1);
segmentsLengthStd = cell(length(numLevels),1);
minSegmentLength = 10 * 2 * hankleSize;
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
        [jumpStart,jumpEnd] = findSegmentTQVaryingSimulation(schedulingVariable,commandLevels,minSegmentLength);
        for mcIndex = 1 : mcItr
            disp(['Now checking MC trial: ',num2str(mcIndex),' out of',num2str(mcItr)])
            dataLength = 0;
            jumpStartThisIteration =[];
            jumpEndThisIteration =[];
            while (dataLength<45000)
                selectedSegment = randi(length(jumpStart));
                jumpStartThisIteration = [jumpStartThisIteration;jumpStart(selectedSegment)];
                jumpEndThisIteration = [jumpEndThisIteration;jumpEnd(selectedSegment)];
                dataLength = dataLength + jumpEndThisIteration(end) - jumpStartThisIteration(end);
            end
            positionSeg = segdat(position,'onsetPointer',jumpStartThisIteration,...
            'segLength',jumpEndThisIteration-jumpStartThisIteration+1,'domainIncr',samplingTime...
            ,'comment','Position','chanNames','Joint angular position (rad)');
            torqueSeg = segdat(torquePert,'onsetPointer',jumpStartThisIteration,...
            'segLength',jumpEndThisIteration-jumpStartThisIteration+1,'domainIncr',samplingTime...
            ,'comment','Torque','chanNames','Joint torque (Nm)');
            intrinsicTorqueSeg = segdat(intrinsicTorque,'onsetPointer',jumpStartThisIteration,...
            'segLength',jumpEndThisIteration-jumpStartThisIteration+1,'domainIncr',samplingTime...
            ,'comment','Torque','chanNames','Joint torque (Nm)');
            reflexTorqueSeg = segdat(reflexTorque,'onsetPointer',jumpStartThisIteration,...
            'segLength',jumpEndThisIteration-jumpStartThisIteration+1,'domainIncr',samplingTime...
            ,'comment','Torque','chanNames','Joint torque (Nm)');
            z = cat(2,positionSeg,torqueSeg);
            sysIDTemp{lvlIndex,mcIndex} = pcas_short_segment_exp_new_intrinsic_irf1 (z,8,hankleSize,0.05,order,intrinsicTorqueSeg,reflexTorqueSeg);
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
save results/segmentLengthInfo2 segmentsLengthMean segmentsLengthStd 
save results/systemIDExperiment2 sysID sysID_SDSS numLevels
plotSimulationFigures