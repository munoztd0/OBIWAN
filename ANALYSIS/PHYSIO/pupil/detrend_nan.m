function detrended = detrend_nan(A,t)
%DETRENDNAN3 Detrends a matrix with (or without) NaNs into the third dimension using linear least squares.
%
%   Input Arguments:
%       - A: NxMxK matrix (double)
%       - t: Optional 1xK time vector (double) indicating the measurement
%               time of each slice. If not given, the slices are assumed
%               to be evenly spaced.
%

%% Default time and data formatting

% create default t if not given
if nargin<2
    t = 1:size(A,3);
end
% time to same format as A and same NaN positions
t = bsxfun(@times,permute(t,[3 1 2]),ones(size(A)));
t(isnan(A)) = NaN;

%% Calculation

% mean of time
xm = nanmean(t,3);
% mean of A
ym = nanmean(A,3);
% calculate slope using least squares
a = nansum(bsxfun(@times,bsxfun(@minus,t,xm),bsxfun(@minus,A,ym)),3)./nansum(bsxfun(@minus,t,xm).^2,3);
% calculate intercept
b = ym - a.*xm;
% calculate trend
trend = bsxfun(@plus,b,bsxfun(@times,a,t));
% remove trend
detrended = A-trend;
end
