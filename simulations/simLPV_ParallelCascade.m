%write a function that simulates the TV system with certain time
clear
clc
load results/experimental_input_subject
load results/noiseScaled

%%
plotFlag = 0;
monteCarloIteration = 100;
simulationSamplingTime = 0.001;
simulationTime = 600;
numInputCall = floor((simulationTime)/60);
simulationTime = numInputCall * 60;
simulationTime = simulationTime - simulationSamplingTime; %in samples
time = 0 : simulationSamplingTime : simulationTime;
time = time';
positionMC = zeros(monteCarloIteration,length(time));
velocityMC = zeros(monteCarloIteration,length(time));
schedulingVariableMC = zeros(monteCarloIteration,length(time));
intrinsicTorqueMC = zeros(monteCarloIteration,length(time));
reflexTorqueMC = zeros(monteCarloIteration,length(time));
totalTorqueMC = zeros(monteCarloIteration,length(time));
noiseMC = zeros(monteCarloIteration,length(time));
for mcIndex = 1 : monteCarloIteration
    inputTrialRandom = randi([1 213],numInputCall,1);
    positionSelected = (position(inputTrialRandom,:));
    positionSelected =  positionSelected';
    positionSelected = positionSelected(:);
    noiseSelected = (noise(inputTrialRandom,:));
    noiseSelected =  noiseSelected';
    noiseSelected = noiseSelected(:);
    cutOffFreq = 0.15;
    normalizedCutOffFreq = cutOffFreq / 500;
    [b,a] = butter(4,normalizedCutOffFreq);
    inputGaussianLPF = randn(size(positionSelected,1),1);
    inputGaussianLPF = filter(b,a,inputGaussianLPF);
    schedulingVariable = uniform_LPF(inputGaussianLPF,-0.48,0.24);
    [positionInput, velocity] =  prepParamsLPV_Sim(positionSelected);
    sim ('stiffnessLPVModel.mdl')
    if plotFlag
        figure(100)
        subplot(3,1,1)
        plot(intrinsicTorque)
        subplot(3,1,2)
        plot(reflexTorque)
        subplot(3,1,3)
        plot(totalTorque)
        pause
        close(100)
    end
    positionMC(mcIndex,:) = positionSelected;
    velocityMC(mcIndex,:) = velocity;
    schedulingVariableMC(mcIndex,:) = schedulingVariable;
    intrinsicTorqueMC(mcIndex,:) = intrinsicTorque;
    reflexTorqueMC(mcIndex,:) = reflexTorque;
    totalTorqueMC(mcIndex,:) = totalTorque;
    noiseMC(mcIndex,:) = noiseSelected;
end
save results/LPVSimulationData monteCarloIteration positionMC velocityMC...
    schedulingVariableMC intrinsicTorqueMC reflexTorqueMC totalTorqueMC noiseMC
tvSimMonteCarlo