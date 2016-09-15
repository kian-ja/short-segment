

function pval=binomial_pval(p,N,po,tail)
% pval=binomial_pval(p,N,po,tail)
% binomial test based on normal distribution
% pval=binomial_pval(p,N) Default test for
% H1: p > 0.5  (p0=0.5 tail='right')
% otherwise
% Ho: p=po
% H1  p<>po tail='both'
% H1  p<po  tail='left'
% H1  p>po  tail='right'
%
% p observed proportion
% po proportion under Ho (to compare with p)
% N sample size where p was observed
%uses z2p function
% rgpm 16-06-2005 new z test added by cml 2-17-2012

if nargin<3,
    po=0.5;
    tail='right';
end
tail=lower(tail);


switch tail,
    case 'both'
        Z=abs( (p-po)/sqrt(po*(1-po)/N) );
    otherwise
        Z=(p-po)/sqrt(po*(1-po)/N);
end

%[Z,p,po, p-po]

pval=z2p(Z,tail);

