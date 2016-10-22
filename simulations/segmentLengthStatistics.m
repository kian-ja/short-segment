clear
load results/segmentLenghtStatistics
lengthMean = zeros(4,1);
lengthStd = zeros(4,1);

numSegMean = zeros(4,1);
numSegStd = zeros(4,1);
for i = 1 : 4
    lengthMeanTemp = [];
    lengthStdTemp = [];
    numSegTemp = [];
    for j = 1 : 100
        temp = segmentLengthMean{i,j};
        temp = temp(:);
        lengthMeanTemp = [lengthMeanTemp;temp];
        
        temp = segmentLengthStd{i,j};
        temp = temp(:);
        lengthStdTemp = [lengthStdTemp;temp];
        
        temp = numSeg{i,j};
        temp = temp(:);
        numSegTemp = [numSegTemp;temp];
    end
    numSegMean(i) = mean(numSegTemp);
    numSegStd(i) = std(numSegTemp);
    
    lengthMean(i) = mean(lengthMeanTemp);
    lengthStd(i) = mean(lengthStdTemp);
end