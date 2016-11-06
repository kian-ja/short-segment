function noiseSNR = noiseScaleSNR(signal,noise,snr)
windowLength = 1000;
%power_noise = sum(noise.^2);
%power_signal = sum((totalTorquePert).^2);
powerNoise = powerMovingAverage(noise,windowLength);
powerSignal = powerMovingAverage(signal,windowLength);
noiseSNR = noise.*sqrt((powerSignal/(10^(snr/10)))./powerNoise);
end