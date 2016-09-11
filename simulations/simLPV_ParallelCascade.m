%write a function that simulates the TV system with certain time
clear
clc
load experimental_input_subject
%%

simulationSamplingTime = 0.001;
simulationTime = 600 - simulationSamplingTime; %in samples
numInputCall = floor(simulationTime/60);
simulationTime = numInputCall * 60;
time = 0 : simulationSamplingTime : simulationTime - simulationSamplingTime;
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
[positionInput, velocity] =  prepParamsLPV_Sim(positionSelected);
sim ('stiffnessLPVModel.mdl')
figure
subplot(3,1,1)
plot(intrinsicTorque)
subplot(3,1,2)
plot(reflexTorque)
subplot(3,1,3)
plot(totalTorque)