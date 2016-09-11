function [intrinsicTorque,reflexTorque,totalTorque] =  simulate_LPV_ParallelCascade(pos,schedulingVariable)
pos = pos(:);
schedulingVariable = schedulingVariable(:);
load intrinsicIRF
%load experimental_input_subject
open('stiffnessLPVModel.mdl')
%simulationTime = 59.999;
simulationSamplingTime = 0.001;
simulationTime = size(pos,1) * simulationSamplingTime - simulationSamplingTime;
h = irfModel.dataSet;
set_param('stiffnessLPVModel/irfCoeff','Value',['[',num2str(h'),']']);
positionLevels = [-0.48 -0.4 -0.32 -0.24 -0.16 -0.08 0.0 0.08 0.16 0.24];%from Mirbagheri et al 2000
Gr = [0.0625,0.0938,0.1042,0.1094,0.2813,0.5000,0.6250,0.7000,0.8000,0.8100];%from Mirbagheri et al 2000
K = [0.38 0.36 0.42 0.48 0.52 0.55 0.6 0.7 0.8 1];%from Mirbagheri et al 2000
%omega = [0.5 0.625 0.69 0.625 0.52 0.38 0.379 0.35 0.56 0.52];%from Mirbagheri et al 2000
%zeta = [0.5 0.25 0.36 0.33 0.36 0.33 0.37 0.39 0.58 0.55];%from Mirbagheri et al 2000
polyCoeffK = polyfit(positionLevels,K,5);
set_param('stiffnessLPVModel/elasticPolynomialCoeff','Value',['[',num2str(polyCoeffK),']']);
set_param('stiffnessLPVModel/elasticSubjectNormalizeGain','Gain',num2str(316));%from Mirbagheri et al 2000, subject HB
set_param('stiffnessLPVModel/elasticSubjectNormalizeGain','Gain',num2str(50));%from Mirbagheri et al 2000, subject HB
polyCoeffGr = polyfit(positionLevels,Gr,5);
set_param('stiffnessLPVModel/reflexGainPolynomialCoeff','Value',['[',num2str(polyCoeffGr),']']);
set_param('stiffnessLPVModel/reflexGainSubjectNormalizeGain','Gain',num2str(7.3));%from Mirbagheri et al 2000, subject HB
set_param('stiffnessLPVModel/reflexGainSubjectNormalizeGain','Gain',num2str(30));%from Mirbagheri et al 2000, subject HB
%polyCoeffOmega = polyfit(positionLevels,omega,5);
%set_param('reflexStiffnessLPVModel/reflexOmegaPolynomialCoeff','Value',['[',num2str(polyCoeffOmega),']']);
set_param('stiffnessLPVModel/reflexOmegaSubjectNormalizeGain','Gain',num2str(36));%from Mirbagheri et al 2000, subject HB
%polyCoeffZeta = polyfit(positionLevels,zeta,5);
%set_param('reflexStiffnessLPVModel/reflexZetaPolynomialCoeff','Value',['[',num2str(polyCoeffZeta),']']);
set_param('stiffnessLPVModel/reflexZetaSubjectNormalizeGain','Gain',num2str(1.8));%from Mirbagheri et al 2000, subject HB
posNldat = nldat(pos,'domainIncr',0.001);
velocity = ddt(posNldat);
velocity = get(velocity,'dataSet');
u_i = zeros(size(pos,1),101);
lags_i = (-50:1:50);
for i = 1:101
    u_i(:,i) = del(pos,lags_i(i));
end
positionInput = u_i;
time = 0 : simulationSamplingTime :size(pos,1) * simulationSamplingTime - simulationSamplingTime;
time = time';
sim ('stiffnessLPVModel.mdl')
end