clear
clc
load results/LPVSimulationData
minSchedul = min(schedulingVariable);
maxSchedul = max(schedulingVariable);
schedulingSegmentNumber = 4:4:20;

for segNumIndex = 1 : length(schedulingSegmentNumber)
    segNum = schedulingSegmentNumber(segNumIndex);
    svResolution = (maxSchedul - minSchedul) / segNum;
    for i = 1 : segNum
      svRangeMin = minSchedul + (i-1) * svResolution; 
      svRangeMax = minSchedul + i * svResolution;
      [segmentStart,segmentEnd] = findSegment(schedulingVariable,[svRangeMin svRangeMax]);
      t = 1 : length(schedulingVariable);
      figure(100)
      plot(t,schedulingVariable)
      hold on
      for j = 1 : length(segmentStart)
          plot(t(segmentStart(j):segmentEnd(j)),schedulingVariable(segmentStart(j):segmentEnd(j)),'or')
      end
      pause
      close(100)
    end
    for mcIndex = 1 : monteCarloIteration
        
    end
end