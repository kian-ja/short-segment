load results/timeVaryingID_Results
%systemID numSamp
%systemID is a 5x100 variable
%The first dimension is the number of division in scheduling variable
%   1) 4
%   2) 8
%   3) 12
%   4) 16
%   5) 20
schedulingSegmentNumber = 4:4:20;
monteCarloIteration = size(systemID,2);
vafTot = zeros(length(schedulingSegmentNumber),monteCarloIteration);

for i = 1 : length(schedulingSegmentNumber)
    for j = 1 : monteCarloIteration
        vafTot(i,j) = 
    end
end
