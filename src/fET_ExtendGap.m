function data = fET_ExtendGap(data, edgeCutSamples)
arguments
    data
    edgeCutSamples = 15;
end
% Fucntion to extend gaps in data to remove near edge effects
% edgeCutSamples: how many samples to cut near each edge
%
% check if there are both invalid and valid samples in the data (otherwise nothing is needed)
if any(isnan(data)) && ~all(isnan(data))
    % get the starts and end of gaps in data
    idx_nan_start = find(diff(isnan(data)) == 1);
    idx_nan_end = find(diff(isnan(data)) == -1);
    % correct if there is a single gap spanning just in the beginning or in the end
    if isempty(idx_nan_start)
        idx_nan_start = 1;
    elseif isempty(idx_nan_end)
        idx_nan_end = numel(data);
    end
    % correct if data is starting or ending with nan values
    if idx_nan_start(1) > idx_nan_end(1)
        idx_nan_start = [1; idx_nan_start];
    end
    if idx_nan_start(end) > idx_nan_end(end)
        idx_nan_end = [idx_nan_end; numel(data)];
    end
    % sanity checks
    assert(numel(idx_nan_start) == numel(idx_nan_end), 'not equinumerous starts and ends for gaps in data');
    assert(all(idx_nan_start <= idx_nan_end), 'starts and ends of gaps do not match') % EDIT CECILE 04/06/24: <= instead of < so if missing 1 sample it still works
    % extend the gaps by `edgeCutSamples`
    idx_gap_start_extend = idx_nan_start - edgeCutSamples;
    idx_gap_end_extend = idx_nan_end + edgeCutSamples;
    idx_gap_start_extend(idx_gap_start_extend < 1) = 1;
    idx_gap_end_extend(idx_gap_end_extend > numel(data)) = numel(data);
    % NaNise the data in the extended gaps
    for iGap = 1:numel(idx_gap_start_extend)
        data(idx_gap_start_extend(iGap):idx_gap_end_extend(iGap)) = NaN;
    end
end
end