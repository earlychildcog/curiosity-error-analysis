function [x,y,interpFlagX,interpFlagY] = fET_InterpolateGaze(x,y,maxDist,maxSamp)
arguments
    x   (:,1)       % x should be a column vector
    y   (:,1)       % y should be a column vector
    maxDist     = 0.1
    maxSamp     = 140
end
% Compute a linear interpolation of missing data if the segment isn't too
% long i.e. shorter than value of maxMs + the values aren't changing too
% much within missing segment i.e. slope lower than maxSlope
%
% Adapted from Janeth Parson's script
%
% dataGazeSubj = fInterpolateGaze(dataGazeSubj,maxSlope,maxSamp)

%% validations
assert(numel(x) == numel(y), "x and y should have the same number of elements")

%% Do interpolation (function defined later)
[x, x_idx] = doInterp(x);
[y, y_idx] = doInterp(y);

%% Store samples that were interpolated in flag var
interpFlagX(1:size(x,1)) = 0; interpFlagX(x_idx) = 1;
interpFlagY(1:size(y,1)) = 0; interpFlagY(y_idx) = 1;

%% Definition of nested functions
    function [data_out, idx_to_interp] = doInterp(data_in)
        % Find nans
        idx_nan = isnan(data_in);
        % Interpolate - NB: LINEAR INTERPOLATION
        t = 1:numel(data_in);
        if sum(idx_nan) < length(idx_nan) - 2
            data_full_interp = interp1(t(~idx_nan), data_in(~idx_nan), t, 'linear');
        else
            data_full_interp = data_in;
        end
        % Don't keep interpolated data where the number of missing samples
        % is greater than the maximum gap length specified
        idx_to_interp = etInterp_makeIdx(data_full_interp, idx_nan, maxDist, maxSamp)';
        data_out = data_in;
        data_out(idx_to_interp) = data_full_interp(idx_to_interp);
    end

    function idx = etInterp_makeIdx(data_full_interp, idx_nan, maxDist, maxSamp)
        idx = false(1, length(data_full_interp));
        % Find contiguous runs of nans, measure length of each
        tmp = findcontig(idx_nan, 1); % Defined lower
        % if none found, return
        if isempty(tmp)
            return
        else
            % select those runs that are shorter than the maximum length that
            % we'll interpolate for (default is 150ms)
            tmp = tmp(tmp(:, 3) <= maxSamp, :);
            
            % if none found, return empty
            if isempty(tmp), idx = []; end
            
            % otherwise loop through all segments that are short enough to
            % interpolate. Check that the slope of each segment doesn't exceed
            % maxSlope (default .1)
            for iSeg = 1:size(tmp, 1)
                % we need `abs` for the slope
                if abs(data_full_interp(tmp(iSeg, 2)) - data_full_interp(tmp(iSeg, 1))) <= maxDist
                    idx(tmp(iSeg, 1):tmp(iSeg, 2)) = true;
                    disp("interpolated 1 gap")
                end
                
            end
        end
    end

    function [ indices ] = findcontig( search, sought )
        indices=[];
        founds=find(search==sought);
        if isempty(founds)
            % sought value not found in search array
            return
        end
        notfounds=find(search~=sought);
        if isempty(notfounds)
            % search array was full of sought values
            indices=[1,size(search,1), 1];
        end
        curVal=1;
        while curVal < size(founds,1)
            startIdx=founds(curVal);
            endIdx=notfounds(find(notfounds>founds(curVal),1,'first'))-1;
            if isempty(endIdx)
                % sought values continue till end
                endIdx=size(search,1);
                curVal=size(founds,1);
            else
                curVal=find(founds>endIdx,1,'first');
            end
            indices=[indices; startIdx, endIdx, endIdx-startIdx+1];
        end
    end

end %end main function
