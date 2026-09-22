function [x,y] = fET_SmoothGaze(x,y,smoothing_factor)
idx_nan_x = isnan(x);
idx_nan_y = isnan(y);
for i = smoothing_factor+1:length(x)-smoothing_factor
    % Replace with smoothed values (except for the few first/last values)
    x(i)  = nanmean(x(i-smoothing_factor:i+smoothing_factor));
    y(i)  = nanmean(y(i-smoothing_factor:i+smoothing_factor));
end
x(idx_nan_x) = NaN;
y(idx_nan_y) = NaN;