function pval = z2p (z,tail)
%input a z-score and a tail: 'right' 'left' or 'both'
if sum([strcmp(tail,'both'),strcmp(tail,'right'),strcmp(tail,'left')])>0;
sigma=1;mu=0;
if strcmp(tail,'both');
cdf=max([(.5*[1+erf((-z-mu)/(sqrt(2*sigma^2)))]),(.5*[1+erf((z-mu)/(sqrt(2*sigma^2)))])]);
pval=2*(1-cdf);
else
if strcmp(tail,'right');z=z;end;
if strcmp(tail,'left');z=-z;end;
cdf=.5*[1+erf((z-mu)/(sqrt(2*sigma^2)))];
pval=1-cdf;
end
end
if sum([strcmp(tail,'both'),strcmp(tail,'right'),strcmp(tail,'left')])==0;
    disp('choose a tail')
end
end %the function
%---------------
% %or make and then integrate your own gaussian from scratch
% example
% z=1.6;
% mu=0;sigma=1;
% set=[-3*z:(6*z)/1000:3*z];
% pdf=(1/(sigma*sqrt(2*pi)))*exp(-((set-mu).^2)/(2*sigma^2));
% cdf=cumsum(abs(pdf))./sum(abs(pdf));
% pval=1-cdf(find(set<z,1,'last'))
%------------------------------------