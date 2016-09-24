function [offset,slope]=slope_fitNoPlot(x,y,threshold)
%CREATEFIT Create plot of data sets and fits
%   CREATEFIT(X,Y)
%   Creates a plot, similar to the plot in the main Curve Fitting Tool,
%   using the data that you provide as input.  You can
%   use this function with the same data you used with CFTOOL
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of data sets:  1
%   Number of fits:  1

% Data from data set "y vs. x":
%     X = x:
%     Y = y:
%     Unweighted

% Auto-generated by MATLAB on 01-Feb-2012 16:31:06

% Set up figure to receive data sets and fits
% Line handles and text for the legend.
legh_ = [];
legt_ = {};
% Limits of the x-axis.
xlim_ = [Inf -Inf];
% Axes for the plot.

% --- Plot data that was originally in data set "y vs. x"
x = x(:);
y = y(:);
xlim_(1) = min(xlim_(1),min(x));
xlim_(2) = max(xlim_(2),max(x));

% Nudge axis limits beyond data limits

% --- Create fit "fit 1"
fo_ = fitoptions('method','NonlinearLeastSquares','Lower',[-Inf -Inf],'Upper',[Inf Inf]);
ok_ = isfinite(x) & isfinite(y);
if ~all( ok_ )
    warning( 'GenerateMFile:IgnoringNansAndInfs',...
        'Ignoring NaNs and Infs in data.' );
end
st_ = [0.8611212241664904  0.046315700554321659 ];
set(fo_,'Startpoint',st_);

 ft_ = fittype(['offset+slope*(x-',num2str(eval('threshold')),'+(x-',num2str(eval('threshold')),').*sign(x-',num2str(eval('threshold')),'))/2'],...
     'dependent',{'y'},'independent',{'x'},...
     'coefficients',{'offset', 'slope'});

%  ft_ = fittype('offset+slope*(x-threshold+(x-threshold).*sign(x-threshold))/2',...
%      'dependent',{'y'},'independent',{'x'},...
%      'coefficients',{'offset', 'slope'});



% Fit this model using new data
cf_ = fit(x(ok_),y(ok_),ft_,fo_);
slope=cf_.slope;
offset=cf_.offset;
% Alternatively uncomment the following lines to use coefficients from the
% original fit. You can use this choice to plot the original fit against new
% data.
%    cv_ = { 5.2002498796617847e-020, 1.0000000000000002, 2.9707996071568887e-010};
%    cf_ = cfit(ft_,cv_{:});
