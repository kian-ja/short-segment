function uniformLPF_Signal = uniform_LPF(inputGaussian,minInput,maxInput)
inputGaussian = inputGaussian(:);
numSamples = length(inputGaussian);
uniformSignal = rand(numSamples,1) - 0.5;
uniformSignal = uniformSignal * (maxInput - minInput);
uniformSignal = uniformSignal + (maxInput + minInput)/2;
uniformLPF_Signal = uniformSignal;
%uniformLPF_Signal = sort(uniformLPF_Signal);
[uniformLPF_SignalSorted,sortIndexUniform] = sort(uniformLPF_Signal);
[inputGaussianSorted,sortIndexGaussian] = sort(inputGaussian);
uniformLPF_Signal(sortIndexGaussian) = uniformLPF_Signal(sortIndexUniform);
uniformLPF_Signal = nldat(uniformLPF_Signal- mean (uniformLPF_Signal),'domainIncr',0.001);
plot(spect(uniformLPF_Signal))
end