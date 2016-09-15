function pValue = pValueSign2Sided(signal1,signal2)
if (size(signal1,2)== size(signal2,2))
    numExperiment = size(signal1,2);
else
    error('number of experiments in 2 signals not consistent')
end
diff1_2 = signal1 > signal2;
pValue = zeros(size(signal1,1),1);
for i = 1 : size(signal1,1)
    pValue(i) = binomial_pval(sum(diff1_2(i,:))/numExperiment,numExperiment,0.5,'right');
end

end
