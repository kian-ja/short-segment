clear
clc
load intrinsicIRF
load experimental_input_subject
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
schedulingVariable = (sin(2*pi*time) - 0.2) *0.3;
sim intrinsicStiffnessLPVModel
plot(intrinsicTorque)