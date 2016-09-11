function uniformLPF_Signal = uniform_LPF(inputGaussian,minInput,maxInput)
plotFlag = 0;
inputGaussian = inputGaussian(:);
numSamples = length(inputGaussian);
uniformSignal = rand(numSamples,1) - 0.5;
uniformSignal = uniformSignal * (maxInput - minInput);
uniformSignal = uniformSignal + (maxInput + minInput)/2;
uniformLPF_Signal = uniformSignal;
[~,sortIndexUniform] = sort(uniformLPF_Signal);
[~,sortIndexGaussian] = sort(inputGaussian);
uniformLPF_Signal(sortIndexGaussian) = uniformLPF_Signal(sortIndexUniform);
if plotFlag
    figure
    uniformLPF_Signal = nldat(uniformLPF_Signal- mean (uniformLPF_Signal),'domainIncr',0.001);
    plot(spect(uniformLPF_Signal))
    xlim([0,10])
    uniformLPF_Signal = get(uniformLPF_Signal,'dataSet');
end
end