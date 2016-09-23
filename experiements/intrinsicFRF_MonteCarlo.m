function [intrinsicFRFIDMean,intrinsicFRFID25,intrinsicFRFID975,frequencyAxis] = intrinsicFRF_MonteCarlo(intrinsic,position)
intrinsic = intrinsic(:);
intrinsicIRF = intrinsic{1};
intrinsicTorque = nlsim(intrinsicIRF,position);
z = cat(2,position,intrinsicTorque);
intrinsicFRFTemp = fresp(z,'nFFT',600);
intrinsicFRFTemp = intrinsicFRFTemp.dataSet;    
frequencyAxis = linspace(0.01,50,length(intrinsicFRFTemp));
intrinsicFRFID = zeros(size(intrinsic,1),length(frequencyAxis));
for i = 1 : length(intrinsic)
    intrinsicIRF = intrinsic{i};
    intrinsicTorque = nlsim(intrinsicIRF,position);
    z = cat(2,position,intrinsicTorque);
    intrinsicFRFTemp = fresp(z,'nFFT',600);
    intrinsicFRFTemp = intrinsicFRFTemp.dataSet;
    intrinsicFRFID(i,:) = 20*log10(abs(intrinsicFRFTemp(:,1)));
end
intrinsicFRFID25 = prctile(intrinsicFRFID,2.5);
intrinsicFRFID975 = prctile(intrinsicFRFID,97.5);
intrinsicFRFIDMean = mean(intrinsicFRFID);

end