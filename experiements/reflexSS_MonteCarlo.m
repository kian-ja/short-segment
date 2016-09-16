function [reflexFRFMean,reflexFRF25,reflexFRF975] = reflexSS_MonteCarlo(reflexSS,frequencyAxis)
reflexSS = reflexSS(:);
reflexFRFID = zeros(size(reflexSS,1),length(frequencyAxis));
indexNan = [];

for i = 1 : size(reflexSS,1)
    reflexID = reflexSS{i};
    reflexID = ss(reflexID.A,reflexID.B,reflexID.C,reflexID.D,0.01);
    [reflexFRFIDTemp,~] = bode(reflexID,frequencyAxis*2*pi);
    if isempty(reflexID)
        indexNan = [indexNan;i];
    else
        reflexFRFID(i,:) = 20*log10(shiftdim(reflexFRFIDTemp,2));
    end
end
reflexFRFID(i,:) = [];
reflexFRF25 = prctile(reflexFRFID,2.5);
reflexFRF975 = prctile(reflexFRFID,97.5);
reflexFRFMean = mean(reflexFRFID);
end