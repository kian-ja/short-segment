clear
clc
load intrinsicIRF
load experimental_input_subject
positionLevels = [-0.48 -0.4 -0.32 -0.24 -0.16 -0.08 0.0 0.08 0.16 0.24];%from Mirbagheri et al 2000
K = [0.0625,0.0938,0.1042,0.1094,0.2813,0.5000,0.6250,0.7000,0.8000,0.8100];%from Mirbagheri et al 2000
omega = [0.5 0.625 0.69 0.625 0.52 0.38 0.379 0.35 0.56 0.52];%from Mirbagheri et al 2000
zeta = [0.5 0.25 0.36 0.33 0.36 0.33 0.37 0.39 0.58 0.55];%from Mirbagheri et al 2000
polyCoeffK = polyfit(positionLevels,K,5);
set_param('intrinsicStiffnessLPVModel/elasticPolynomialCoeff','Value',['[',num2str(polyCoeffK),']']);
set_param('intrinsicStiffnessLPVModel/elasticSubjectNormalizeGain','Gain',num2str(316));%from Mirbagheri et al 2000, subject HB
polyCoeffOmega = polyfit(positionLevels,K,5);
polyCoeffZeta = polyfit(positionLevels,K,5);
pos = position(1,:);
pos = pos';
u_i = zeros(60000,101);
lags_i = (-50:1:50);
for i = 1:101
    u_i(:,i) = del(pos,lags_i(i));
end
inputSignal = u_i;
time = 0 : 0.001:59.999;
time = time';
h = irfModel.dataSet;
schedulingVariable = (sin(2*pi*time*0.1) - 0.2) *0.3;
sim intrinsicStiffnessLPVModel
plot(intrinsicTorque)