function [reflexNLMean,reflexNL25,reflexNL975,xNonlin] = reflexNL_MonteCarlo(reflexNLPF)
reflexNLPF = reflexNLPF(:);
xNonlin = -2.5:0.01:2.5;

nonLinOutputAll = zeros(length(reflexNLPF),length(xNonlin));
xNonlin = nldat(xNonlin','domainIncr',0.01);
indexNan = [];
for i = 1 : length(reflexNLPF)
    reflexNonlin = reflexNLPF{i};
    nonlinOutput = nlsim(reflexNonlin,xNonlin);
    if isnan(reflexNonlin.polyCoef)
        indexNan = [indexNan;i];
    else
        nonLinOutputAll(i,:) = nonlinOutput.dataSet + 3.5;
    end
    
end
nonLinOutputAll(i,:) = [];
reflexNL25 = prctile(nonLinOutputAll,2.5);
reflexNL975 = prctile(nonLinOutputAll,97.5);
reflexNLMean = mean(nonLinOutputAll);
xNonlin = xNonlin.dataSet;


end