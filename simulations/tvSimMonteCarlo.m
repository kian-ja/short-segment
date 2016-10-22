clear
clc
load results/LPVSimulationData
%The foolowings need to be added
% 1- The main pcas_short_segment_exp_new_intrinsic_irf1 function gives the 
% VAFs comapred to true intrinsic and reflex torques,NOT only the noisy one
% 2- The main function gives actual number of samples used at each step (i.e numSamp)
samplingTime = 0.001;
schedulingSegmentNumber = 3:3:12;
plotFlag = 0;
order = 2;
snr = 15;
systemID_SS_SDSS = cell(length(schedulingSegmentNumber),monteCarloIteration);
systemID_SDSS = cell(length(schedulingSegmentNumber),monteCarloIteration);

segmentLengthMean = cell(length(schedulingSegmentNumber),monteCarloIteration);
segmentLengthStd = cell(length(schedulingSegmentNumber),monteCarloIteration);
numSeg = cell(length(schedulingSegmentNumber),monteCarloIteration);


%%
warning off
for mcIndex = 1 : monteCarloIteration
    disp(['Working on Monte-Carlo Identification number, ',num2str(mcIndex)])
    position = positionMC(mcIndex,:)';
    torque = totalTorqueMC(mcIndex,:)';
    intrinsicTorque = intrinsicTorqueMC(mcIndex,:)';
    reflexTorque = reflexTorqueMC(mcIndex,:)';
    noise = noiseMC(mcIndex,:)';
    schedulingVariable = schedulingVariableMC(mcIndex,:)';
    minSchedul = min(schedulingVariable);
    maxSchedul = max(schedulingVariable);
    for segNumIndex = 1 : length(schedulingSegmentNumber)
        segNum = schedulingSegmentNumber(segNumIndex);
        svResolution = (maxSchedul - minSchedul) / segNum;
        sysIDTemp = cell(segNum,1);
        sysID_SDSS_Temp = cell(segNum,1);
        segmentLengthMeanTemp = zeros(segNum,1);
        segmentLengthStdTemp = zeros(segNum,1);
        numSegTemp = zeros(segNum,1);
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
%           power_noise = sum(noise.^2);
%           power_signal = sum((torque).^2);
%           noiseScaled = noise*sqrt((power_signal/(10^(snr/10)))/power_noise);
%           torqueNoisy = torque + noiseScaled; 
%            position = segdat(position,'onsetPointer',segmentStart,...
%              'segLength',segmentEnd - segmentStart + 1,'domainIncr',samplingTime...
%              ,'comment','Position','chanNames','Joint angular position (rad)');
%            torqueNoisy = segdat(torqueNoisy ,'onsetPointer',segmentStart,...
%              'segLength',segmentEnd - segmentStart + 1,'domainIncr',samplingTime...
%              ,'comment','Position','chanNames','Joint angular position (rad)');
%          intrinsicTorque = segdat(intrinsicTorque ,'onsetPointer',segmentStart,...
%              'segLength',segmentEnd - segmentStart + 1,'domainIncr',samplingTime...
%              ,'comment','Position','chanNames','Joint angular position (rad)');
%          reflexTorque = segdat(reflexTorque ,'onsetPointer',segmentStart,...
%              'segLength',segmentEnd - segmentStart + 1,'domainIncr',samplingTime...
%              ,'comment','Position','chanNames','Joint angular position (rad)');
%            z = cat(2,position,torqueNoisy);
%            sysIDTemp{i} = pcas_short_segment_exp_new_intrinsic_irf1 (z,8,20,0.05,order,intrinsicTorque,reflexTorque);
%            z = cat(2,nldat(position),nldat(torqueNoisy));
%            sysID_SDSS_Temp{i} = sdss(z,8,20,0.05,order,nldat(intrinsicTorque),nldat(reflexTorque));
          segmentLengthMeanTemp(i) = mean(segmentEnd - segmentStart + 1);
          segmentLengthStdTemp(i) = std(segmentEnd - segmentStart + 1);
          numSegTemp(i) = length(segmentEnd);
        end
        numSeg{segNumIndex,mcIndex} = numSegTemp;
        segmentLengthMean{segNumIndex,mcIndex} = segmentLengthMeanTemp;
        segmentLengthStd{segNumIndex,mcIndex} = segmentLengthStdTemp;
        systemID_SS_SDSS{segNumIndex,mcIndex} = sysIDTemp;
        systemID_SDSS{segNumIndex,mcIndex} = sysID_SDSS_Temp;
    end
end
save results/segmentLenghtStatistics segmentLengthMean segmentLengthStd numSeg
%save results/timeVaryingID_Results systemID_SS_SDSS systemID_SDSS