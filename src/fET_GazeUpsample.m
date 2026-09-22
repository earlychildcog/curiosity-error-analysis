function [tup, xup, yup, extra] = fET_GazeUpsample(t,x,y,opts)
arguments
    t (:,1) double
    x (:,1) double
    y (:,1) double
    opts.factor = 2
end

assert(numel(t) == numel(x) && numel(t) == numel(y), "t,x,y should have equal length")

tup = upsample(t, opts.factor);
xup = upsample(x, opts.factor);
yup = upsample(y, opts.factor);

tup(2:2:(end-1)) = (tup(1:2:(end-2)) + tup(3:2:end))/2;
xup(2:2:(end-1)) = (xup(1:2:(end-2)) + xup(3:2:end))/2;
yup(2:2:(end-1)) = (yup(1:2:(end-2)) + yup(3:2:end))/2;
assert(opts.factor == 2, "only factor 2 is implemented right now")
% x_(2:2:end) = NaN;
% y_(2:2:end) = NaN;

% [xup,yup,interpFlagX,interpFlagY] = fInterpolateGaze(x_,y_,0.01,100);

% remove the awkward points between trials
extra = diff(tup) > median(diff(tup)) + 0.0001;

if isnan(tup(end))  % should happen, but put if to make sure that we do not delete sth good
    extra(end) = true;
end
tup(extra) = [];
xup(extra) = [];
yup(extra) = [];

end