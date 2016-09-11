%write a function that simulates the TV system with certain time
load experimental_input_subject
%%
simulationTime = 600; %in samples
samplingTime = 0.001;
numInputCall = floor(simulationTime/60);
simulationTime = numInputCall * 60;
time = 0 : samplingTime : simulationTime - samplingTime;
time = time';
inputTrialRandom = randi([1 213],numInputCall,1);
positionSelected = (position(inputTrialRandom,:));
positionSelected =  positionSelected';
positionSelected = positionSelected(:);
cutOffFreq = 0.5;
normalizedCutOffFreq = cutOffFreq / 500;
[b,a] = butter(4,normalizedCutOffFreq);
inputGaussianLPF = randn(size(positionSelected,1),1);
inputGaussianLPF = filter(b,a,inputGaussianLPF);
schedulingVariable = uniform_LPF(inputGaussianLPF,-0.48,0.24);
[intrinsicTorque,reflexTorque,totalTorque] =  simulate_LPV_ParallelCascade(positionSelected,schedulingVariable);

