load results/segmentLengthInfo 
lengthMean = zeros(length(segmentsLengthMean),1);
lengthStd = zeros(length(segmentsLengthMean),1);
for i = 1 : length(segmentsLengthMean)
   segmentsLengthMeanTemp = segmentsLengthMean{i};
   segmentsLengthMeanTemp = segmentsLengthMeanTemp(:);
   lengthMean(i) = mean(segmentsLengthMeanTemp);
   segmentsLengthStdTemp = segmentsLengthStd{i};
   segmentsLengthStdTemp = segmentsLengthStdTemp(:);
   lengthStd(i) = mean(segmentsLengthStdTemp);
end
%segmentsLengthMean segmentsLengthStd