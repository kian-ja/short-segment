function noiseSNR = noiseScaleSNR(signal,noise,snr,option)
if nargin<4
    option = 'ti';
end
if strcmp(option , 'ti')
    powerNoise = sum(noise.^2);
    powerSignal = sum((signal).^2);
elseif strcmp(option , 'tv')
    windowLength = 1000;
    powerNoise = powerMovingAverage(noise,windowLength);
    powerSignal = powerMovingAverage(signal,windowLength);
else
    error('Wrong option; available options are "ti" for time-invariant noise and "tv" for time-varying noise');
end
    noiseSNR = noise.*sqrt((powerSignal/(10^(snr/10)))./powerNoise);

end