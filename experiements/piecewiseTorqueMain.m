%preparePieceWiseTorqueData%Run if data is not saved
clear
clc
close all
%filePath = '/Users/kian/Documents/publication/Jalaleddini-Kearney-Short-Segment/experiment/torque varying/';
load 'results/dataPieceWiseTorque.mat'
%%
samplingTime = 0.001;
data = dataPieceWiseTorque{4};
position = data(:,1);
torque = data(:,2);
command = data(:,8);
    
commandLevels = [0.2 0.4; -0.1 0.1; -0.4 -0.2];
%commandLevels = [0.35 0.45; 0.045 0.055; -0.01 0.01; -0.055 -0.045 ; -0.45 -0.35];
jumpIndex = cell(size(commandLevels,1),1);

for i = 1 : size(commandLevels,1)
    [jumpStart,jumpEnd] = findSegment(command,commandLevels(i,:));
    f = find( jumpEnd < jumpStart + 2000);
    jumpStart(f) = [];
    jumpEnd(f) = [];
    jumpIndex{i} = [jumpStart jumpEnd];
    plot(command)
    hold on
    plot(jumpStart,command(jumpStart),'o')
    plot(jumpEnd,command(jumpEnd),'go')
    pause
    close all
end
%%
%clc
warning off
order = 2;
h = waitbar(0,'Running Monte-Carlo Experiment');
monteCarloIteration = 100;
SDSS_System = cell(3,6,monteCarloIteration,3);
SS_SDSS_System = cell(3,6,monteCarloIteration,3);
step = 0;
for contractionConditionIndex = 1 : 3
    disp(['Testing Contraction Condition = ', num2str(contractionConditionIndex),' out of 3'])
    segmentOnsetEnd = jumpIndex{contractionConditionIndex};
    segmentLength = 5000;
    segmentOnsetEnd(:,1) = segmentOnsetEnd(:,2) - 5000;
    if (contractionConditionIndex == 3)
        order = 2;
    else
        order = 0;
    end
    segmentLengthMCIndex = 0;
    for segmentLengthMC = 500:100:1000
        segmentLengthMCIndex = segmentLengthMCIndex + 1;
        disp(['Testing segment Length = ', num2str(segmentLengthMC)])
        segmentNumMC = floor(60/segmentLengthMC*1000);
        for mcIndex = 1 : monteCarloIteration
            step = step + 1;
            waitbar(step / monteCarloIteration / 6 / 3);
            disp(['Iteration = ', num2str(mcIndex),' out of ',num2str(monteCarloIteration)])
            selectedSegment = randi([1 size(segmentOnsetEnd,1)],segmentNumMC,1);
            selectedSegmentOnset = randi([1 segmentLength-segmentLengthMC],segmentNumMC,1);
            onsetPointer = segmentOnsetEnd(selectedSegment,1) + selectedSegmentOnset;
            position = segdat(position,'onsetPointer',onsetPointer,...
            'segLength',ones(length(onsetPointer),1)*segmentLengthMC,'domainIncr',samplingTime...
            ,'comment','Position','chanNames','Joint angular position (rad)');
            torque = segdat(torque,'onsetPointer',onsetPointer,...
            'segLength',ones(length(onsetPointer),1)*segmentLengthMC,'domainIncr',samplingTime...
            ,'comment','Torque','chanNames','Joint torque (Nm)');
            z = cat(2,position,torque);
            sysID = pcas_short_segment_exp_new_intrinsic_irf1 (z,'maxordernle',8,'hanklesize',20,'delayinput',0.05,'orderselectmethod',order);
            SS_SDSS_System{contractionConditionIndex,segmentLengthMCIndex,mcIndex,1} = sysID{1};
            SS_SDSS_System{contractionConditionIndex,segmentLengthMCIndex,mcIndex,2} = sysID{2};
            SS_SDSS_System{contractionConditionIndex,segmentLengthMCIndex,mcIndex,3} = sysID{3};
            [intrinsic, reflex, tqI, tqR, tqT] = SDSS_stiffnessID (nldat(z),'orderselectmethod',order,'delay',0.05);
            tqMeasured = decimate(z(:,2),10);
            tqMeasured = tqMeasured.dataSet;
            tqI = tqI.dataSet;
            tqR = tqR.dataSet;
            tqT = tqT.dataSet;
            vi = vaf(tqMeasured,tqI);
            vR = vaf(tqMeasured,tqR);
            vT = vaf(tqMeasured,tqT);
            SDSS_System{contractionConditionIndex,segmentLengthMCIndex,mcIndex,1} = intrinsic;
            SDSS_System{contractionConditionIndex,segmentLengthMCIndex,mcIndex,2} = reflex;
            SDSS_System{contractionConditionIndex,segmentLengthMCIndex,mcIndex,3} = [vi;vR;vT];
        end
    end
end
close(h) 

save results/quasiStationaryExperimentResults SDSS_System SS_SDSS_System