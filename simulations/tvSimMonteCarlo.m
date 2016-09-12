clear
clc
load results/LPVSimulationData
%The foolowings need to be added
% 1- The main pcas_short_segment_exp_new_intrinsic_irf1 function gives the 
% VAFs comapred to true intrinsic and reflex torques,NOT only the noisy one
% 2- The main function gives actual number of samples used at each step (i.e numSamp)
samplingTime = 0.001;
schedulingSegmentNumber = 4:4:20;
plotFlag = 0;
order = 2;
snr = 15;
systemID = cell(length(schedulingSegmentNumber),monteCarloIteration);
numSamp = cell(length(schedulingSegmentNumber),monteCarloIteration);
for mcIndex = 1 : monteCarloIteration
    position = positionMC(mcIndex,:)';
    torque = totalTorqueMC(mcIndex,:)';
    noise = noiseMC(mcIndex,:)';
    schedulingVariable = schedulingVariableMC(mcIndex,:)';
    minSchedul = min(schedulingVariable);
    maxSchedul = max(schedulingVariable);
    for segNumIndex = 1 : length(schedulingSegmentNumber)
        segNum = schedulingSegmentNumber(segNumIndex);
        svResolution = (maxSchedul - minSchedul) / segNum;
        sysIDTemp = cell(segNum,1);
        numSampTemp = zeros(segNum,1);
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
          power_noise = sum(noise.^2);
          power_signal = sum((torque).^2);
          noiseScaled = noise*sqrt((power_signal/(10^(snr/10)))/power_noise);
          torqueNoisy = torque + noiseScaled; 
          position = segdat(position,'onsetPointer',segmentStart,...
            'segLength',segmentEnd - segmentStart + 1,'domainIncr',samplingTime...
            ,'comment','Position','chanNames','Joint angular position (rad)');
          torqueNoisy = segdat(torqueNoisy ,'onsetPointer',segmentStart,...
            'segLength',segmentEnd - segmentStart + 1,'domainIncr',samplingTime...
            ,'comment','Position','chanNames','Joint angular position (rad)');
          z = cat(2,position,torqueNoisy);
          sysIDTemp{i} = pcas_short_segment_exp_new_intrinsic_irf1 (z,...
            'maxordernle',8,'hanklesize',20,'delayinput',0.05...
            ,'orderselectmethod',order);
        end
    end
   systemID{segNumIndex,mcIndex} = sysIDTemp;
   numSamp{segNumIndex,mcIndex} = numSampTemp;
end
%%
save timeVaryingID_Results systemID numSamp