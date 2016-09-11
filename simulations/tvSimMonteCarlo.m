clear
clc
load results/LPVSimulationData
samplingTime = 0.001;
schedulingSegmentNumber = 4:4:20;
plotFlag = 0;
order = 2;
for mcIndex = 1 : monteCarloIteration
    position = positionMC(mcIndex,:)';
    torque = totalTorqueMC(mcIndex,:)';
    schedulingVariable = schedulingVariableMC(mcIndex,:)';
    minSchedul = min(schedulingVariable);
    maxSchedul = max(schedulingVariable);
    for segNumIndex = 1 : length(schedulingSegmentNumber)
        segNum = schedulingSegmentNumber(segNumIndex);
        svResolution = (maxSchedul - minSchedul) / segNum;
        for i = 1 : segNum
          svRangeMin = minSchedul + (i-1) * svResolution; 
          svRangeMax = minSchedul + i * svResolution;
          [segmentStart,segmentEnd] = findSegment(schedulingVariable,[svRangeMin svRangeMax]);
          t = 1 : length(schedulingVariable);
          if plotFlag
              figure(100)
              plot(t,schedulingVariable)
              hold on
              for j = 1 : length(segmentStart)
                  plot(t(segmentStart(j):segmentEnd(j)),schedulingVariable(segmentStart(j):segmentEnd(j)),'or')
              end
              pause
              close(100)
          end
          position = segdat(position,'onsetPointer',segmentStart,...
            'segLength',segmentEnd - segmentStart + 1,'domainIncr',samplingTime...
            ,'comment','Position','chanNames','Joint angular position (rad)');
          torque = segdat(torque,'onsetPointer',segmentStart,...
            'segLength',segmentEnd - segmentStart + 1,'domainIncr',samplingTime...
            ,'comment','Position','chanNames','Joint angular position (rad)');
          z = cat(2,position,torque);
          sysID = pcas_short_segment_exp_new_intrinsic_irf1 (z,...
            'maxordernle',8,'hanklesize',20,'delayinput',0.05...
            ,'orderselectmethod',order);
        end
   end
end