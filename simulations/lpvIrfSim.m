function intrinsicTorque = lpvIrfSim(irfModel,pos,schedulingVariable)
ts = get(irfModel,'domainIncr');
irfModel = irfModel.dataSet;
positionLagged = zeros(length(pos),length(irfModel));
Delta = floor(length(irfModel)/2);
delayVector = -Delta:Delta;
for i = 1 : length(delayVector)
     positionLagged(:,i) = del(pos,delayVector(i));
end
levels = [0 -3 -6 -9 -12 -15 -18 -21 -24];
K = [0.18 0.4 0.5 0.65 0.75 0.81 0.875 0.94 1];
polyCoeffK = polyfit(levels,K,5);
% 
% schedulingVariableRegressor = zeros(length(schedulingVariable),length(polyCoeffK));
% for i = 1 : length(polyCoeffK)
%     schedulingVariableRegressor(:,i) = schedulingVariable.^(i-1);
% end
% regressorIntrinsicExpand = zeros(length(pos),length(polyCoeffK)*length(delayVector));
intrinsicTorque = zeros(size(pos));
for i = 1 : length(pos)
    irfModelThisTime = 50 * irfModel * polyval(polyCoeffK,schedulingVariable(i));
    tempSum = 0;
    for j = 1 : length(delayVector)
        tempSum = tempSum + ts * positionLagged(i,j) * irfModelThisTime(j);
    end
    intrinsicTorque(i) = tempSum;
end
end
