function powerSignal = powerMovingAverage(signal,windowLength)
signalSquared = signal.^2;
if mod(windowLength,2) == 0
    windowLength = windowLength + 1;
end
powerSignal = movmean(signalSquared,windowLength);
end