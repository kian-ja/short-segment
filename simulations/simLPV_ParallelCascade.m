%write a function that simulates the TV system with certain time
clear
clc
load results/experimental_input_subject
load results/noiseScaled
load results/intrinsicIRFModelNormal
%%
sv = 'torque';
snr = 15;
plotFlag = 1;
monteCarloIteration = 1;
simulationSamplingTime = 0.001;
simulationTime = 2400;
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
totalTorqueNoisyMC = zeros(monteCarloIteration,length(time));
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
    %[b,a] = butter(4,normalizedCutOffFreq);
    %inputGaussianLPF = randn(size(positionSelected,1),1);
    %inputGaussianLPF = filter(b,a,inputGaussianLPF);
    %schedulingVariable = uniform_LPF(inputGaussianLPF,-0.48,0.24);
    schedulingVariable = 10 * (sin(2*pi*0.1*time)/2 - 0.5);
    %schedulingVariable = -0.12+0.72/2*sin(2*pi*time);
    [positionPertInput,velocityInput,accelerationInput] =  prepParamsLPV_Sim(positionSelected);
    if strcmp(sv , 'pos')
        positionInput = positionPertInput + schedulingVariable;
    else
        positionInput = positionPertInput;
    end
    
    %positionInput = positionSelected;
    sim ('stiffnessLPVModel.mdl')
    if strcmp(sv , 'torque')
        totalTorque = -totalTorque + schedulingVariable;
    end
    if plotFlag
        figure(100)
        subplot(4,1,1)
        plot(schedulingVariable)
        subplot(4,1,2)
        plot(intrinsicTorque)
        subplot(4,1,3)
        plot(reflexTorque)
        subplot(4,1,4)
        plot(totalTorque)
        ylim([-25,20])
        xAxisPanZoom
        
        pause
        close(100)
    end
    pos = nldat(positionSelected,'domainIncr',0.001);
    %intrinsicTorque = nlsim(irfModel,pos);
    intrinsicTorque = lpvIrfSim(irfModel,positionSelected,schedulingVariable);
    totalTorquePert = intrinsicTorque + reflexTorque;
    
    noiseSNR = noiseScaleSNR(totalTorquePert,noiseSelected,snr);
	%totalTorqueNoisy = totalTorque + 1 * noiseSNR;
    totalTorqueNoisy = totalTorquePert + 1 * noiseSNR;
    positionMC(mcIndex,:) = positionSelected;
    velocityMC(mcIndex,:) = velocityInput;
    schedulingVariableMC(mcIndex,:) = schedulingVariable;
    intrinsicTorqueMC(mcIndex,:) = intrinsicTorque;
    reflexTorqueMC(mcIndex,:) = reflexTorque;
    totalTorqueMC(mcIndex,:) = totalTorque;
    totalTorqueNoisyMC(mcIndex,:) = totalTorqueNoisy;
    noiseMC(mcIndex,:) = noiseSNR;
end
save results/LPVSimulationData1Trial2 monteCarloIteration positionMC velocityMC...
    schedulingVariableMC intrinsicTorqueMC reflexTorqueMC totalTorqueMC noiseMC...
totalTorqueNoisyMC totalTorquePert
%tvSimMonteCarlo
analyzeBootStrap