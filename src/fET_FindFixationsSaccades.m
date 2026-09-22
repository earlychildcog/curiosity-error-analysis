%% Find fixations and saccades + compute mean location and start-end times
%
% Use the first derivative (velocity) of x-y location values to identify
% saccades = big changes in location values according to a high threshold
% (velo. > .5 std of velo.); the start/end of the saccades is further
% identified with a lower threshold (velo. > .3 std of velo). Bouts of at
% least 50ms between those changes are identified as fixations, and their
% number, start+end timings, and mean x-y location values are saved. Bouts
% with >50% data loss, or <50ms are rejected.
%

function [flags, gazeParsed] = fET_FindFixationsSaccades(x, y, t, fixroi, opts)

arguments
    x double
    y double  
    t double
    fixroi double
    opts.highThresh (1,1) double = 0.5
    opts.lowThresh (1,1) double = 0.3
    opts.minFixDuration (1,1) double = 50  % minimum fixation duration in samples
    opts.minFixDurationShort (1,1) double = 10  % very short fixation threshold
    opts.maxDataLossRatio (1,1) double = 0.5  % maximum ratio of NaN values allowed
    opts.outOfRangeLimit (1,1) double = 2000  % values above this are considered out of range
end

% Input validation
if length(x) ~= length(y) || length(x) ~= length(t) || length(x) ~= length(fixroi)
    error('All input vectors must have the same length');
end
if length(x) < 2
    error('Need at least 2 samples for analysis');
end

nSamples = length(x);

% Initialize output flags structure
flags                 = struct();
flags.flagFix         = categorical(repmat("", nSamples, 1));
flags.flagFixNb       = zeros(nSamples, 1, 'int16');
flags.flagLook        = categorical(repmat("", nSamples, 1));
flags.flagLookNb      = zeros(nSamples, 1, 'int16');
flags.flagSwitchB     = zeros(nSamples, 1, 'int16');
flags.flagSwitchBNb   = zeros(nSamples, 1, 'int16');
flags.flagSwitchAll   = zeros(nSamples, 1, 'int16');
flags.flagSwitchAllNb = zeros(nSamples, 1, 'int16');

%% A. Compute velocity and thresholds
% Handle NaN values properly for velocity calculation
validIdx = ~isnan(x) & ~isnan(y);
if sum(validIdx) < 2
    warning('Less than 2 valid samples - cannot compute velocity');
    gazeParsed = struct();
    return;
end

% Compute velocity only on valid samples
veloX    = zeros(nSamples-1, 1);
veloY    = zeros(nSamples-1, 1);
velocity = zeros(nSamples-1, 1);

for iFix = 1:nSamples-1
    if validIdx(iFix) && validIdx(iFix+1)
        veloX(iFix) = abs(x(iFix+1) - x(iFix));
        veloY(iFix) = abs(y(iFix+1) - y(iFix));
        velocity(iFix) = veloX(iFix) + veloY(iFix);
    else
        % Mark transitions involving NaN as high velocity (potential saccades)
        velocity(iFix) = inf;
    end
end

% Calculate thresholds based on valid velocity samples only
validVelo = velocity(~isinf(velocity) & velocity > 0);
if isempty(validVelo)
    warning('No valid velocity samples found');
    gazeParsed = struct();
    return;
end

stdVelo = std(validVelo);
hThresh = opts.highThresh * stdVelo;
lThresh = opts.lowThresh * stdVelo;

%% B. Find saccades using the 2-velocity threshold method
saccadeIdx = false(nSamples, 1);  % Track which samples are saccades
saccStart  = [];
saccEnd    = [];
iSacc      = 0;
startSearchIdx = 1;

while startSearchIdx <= length(velocity)
    % Find next high threshold crossing
    highThreshIdx = find(velocity(startSearchIdx:end) >= hThresh, 1);
    if isempty(highThreshIdx)
        break;  % No more saccades
    end
    highThreshIdx = highThreshIdx + startSearchIdx - 1;
    
    iSacc = iSacc + 1;
    
    % Find saccade start (work backwards from high threshold to low threshold)
    lowThreshStartIdx = find(velocity(1:highThreshIdx) < lThresh, 1, 'last');
    if isempty(lowThreshStartIdx)
        saccStart(iSacc) = 1;
    else
        saccStart(iSacc) = lowThreshStartIdx + 1;
    end
    
    % Find saccade end (work forwards from high threshold to low threshold)
    lowThreshEndIdx = find(velocity(highThreshIdx:end) < lThresh, 1);
    if isempty(lowThreshEndIdx)
        saccEnd(iSacc) = length(velocity);
    else
        saccEnd(iSacc) = lowThreshEndIdx + highThreshIdx - 1;
    end
    
    % Mark saccade samples (convert velocity indices to sample indices)
    saccadeIdx(saccStart(iSacc):min(saccEnd(iSacc)+1, nSamples)) = true;
    
    % Continue search after this saccade
    startSearchIdx = saccEnd(iSacc) + 1;
end

%% C. Identify fixations (periods between saccades)
% Find fixation periods
if sum(~saccadeIdx) == 0
    saccadeIdx = ~saccadeIdx; % If there are no saccades, make everything the fixation and not the other way around
    saccStart  = [];
    saccEnd    = [];
end
flags.flagFix(saccadeIdx) = "Saccade";
fixationPeriods = fFindContiguousPeriods(~saccadeIdx);
fixIdxAllStart  = fixationPeriods(:,1);
fixIdxAllEnd    = fixationPeriods(:,2);
fixCount = 0;

for iFix = 1:size(fixationPeriods, 1)
    fixStart = fixationPeriods(iFix, 1);
    fixEnd   = fixationPeriods(iFix, 2);
    duration = fixEnd - fixStart + 1;
    
    % Check data quality in this period
    xSeg = x(fixStart:fixEnd);
    ySeg = y(fixStart:fixEnd);
    
    nanRatio = (sum(isnan(xSeg)) + sum(isnan(ySeg))) / (2 * length(xSeg));
    outOfRangeRatio = (sum(xSeg > opts.outOfRangeLimit) + sum(ySeg > opts.outOfRangeLimit)) / (2 * length(xSeg));
    
    % Classify fixation quality
    fixFlagGood(iFix) = false;
    if nanRatio > opts.maxDataLossRatio || outOfRangeRatio > opts.maxDataLossRatio
        flags.flagFix(fixStart:fixEnd) = "BadFix";
        flags.flagFixNb(fixStart:fixEnd) = 0;
    elseif duration < opts.minFixDurationShort
        flags.flagFix(fixStart:fixEnd) = "10msFix";
        flags.flagFixNb(fixStart:fixEnd) = 0;
    elseif duration < opts.minFixDuration
        flags.flagFix(fixStart:fixEnd) = "50msFix";
        flags.flagFixNb(fixStart:fixEnd) = 0;
    else
        fixCount = fixCount + 1;
        flags.flagFix(fixStart:fixEnd) = "Fix";
        flags.flagFixNb(fixStart:fixEnd) = fixCount;
        fixFlagGood(iFix) = true;
    end
    fixAllRoi(iFix) = mode(fixroi(fixStart:fixEnd));
end
fixIdxGoodStart = fixationPeriods(fixFlagGood,1);
fixIdxGoodEnd   = fixationPeriods(fixFlagGood,2);
fixGoodRoi      = fixAllRoi(fixFlagGood);

%% D. Identify looks (contiguous periods in same ROI during good fixations)
goodFixIdx  = flags.flagFix == "Fix";
lookPeriods = fFindLookPeriods(fixroi, goodFixIdx);
lookCount   = 0;
if ~isempty(lookPeriods)
    % Only count actual ROI looks, not "outside" looks when roi = 0
    lookIdxStart = lookPeriods(lookPeriods(:,3)~=0, 1);
    lookIdxEnd   = lookPeriods(lookPeriods(:,3)~=0, 2);
    lookRoi      = lookPeriods(lookPeriods(:,3)~=0, 3);
    for iLook = 1:size(lookIdxStart, 1)
        lookCount = lookCount + 1;
        flags.flagLook(lookIdxStart(iLook):lookIdxEnd(iLook))   = "Look";
        flags.flagLookNb(lookIdxStart(iLook):lookIdxEnd(iLook)) = lookCount;
    end
else
    lookIdxStart = [];
    lookIdxEnd   = [];
    lookRoi      = [];
end

%% E. Count switches
[flags.flagSwitchB, flags.flagSwitchBNb, switchBIdxStart, switchBIdxEnd] = fCountSwitches(fixroi, goodFixIdx, [1, 2]);
[flags.flagSwitchAll, flags.flagSwitchAllNb, switchAllIdxStart, switchAllIdxEnd] = fCountSwitches(fixroi, goodFixIdx, [1, 2, 3]);

%% F. Prepare output structure
gazeParsed.velocity          = velocity;
gazeParsed.hThresh           = hThresh;
gazeParsed.lThresh           = lThresh;
gazeParsed.saccStart         = saccStart;
gazeParsed.saccEnd           = saccEnd;
gazeParsed.fixIdxAllStart    = fixIdxAllStart;
gazeParsed.fixIdxAllEnd      = fixIdxAllEnd;
gazeParsed.fixAllRoi         = fixAllRoi;
gazeParsed.fixFlagGood       = fixFlagGood;
gazeParsed.fixIdxGoodStart   = fixIdxGoodStart;
gazeParsed.fixIdxGoodEnd     = fixIdxGoodEnd;
gazeParsed.fixGoodRoi        = fixGoodRoi;
gazeParsed.lookIdxStart      = lookIdxStart;
gazeParsed.lookIdxEnd        = lookIdxEnd;
gazeParsed.lookRoi           = lookRoi;
gazeParsed.switchBIdxStart   = switchBIdxStart;
gazeParsed.switchBIdxEnd     = switchBIdxEnd;
gazeParsed.switchAllIdxStart = switchAllIdxStart;
gazeParsed.switchAllIdxEnd   = switchAllIdxEnd;
gazeParsed.nSaccades         = length(saccStart);
gazeParsed.nFixations        = fixCount;
gazeParsed.nLooks            = lookCount;
gazeParsed.nSwitchesB        = max(flags.flagSwitchBNb);
gazeParsed.nSwitchesAll      = max(flags.flagSwitchAllNb);


end



%% Helper Functions

function periods = fFindContiguousPeriods(logicalArray)
    % Find contiguous periods where logicalArray is true
    if isempty(logicalArray) || ~any(logicalArray)
        periods = [];
        return;
    end
    
    % Find start and end points
    diff_array = diff([false; logicalArray(:); false]);
    starts = find(diff_array == 1);
    ends = find(diff_array == -1) - 1;
    
    periods = [starts, ends];
end

function lookPeriods = fFindLookPeriods(fixroi, goodFixIdx)
    % Find contiguous periods where ROI is the same during good fixations
    lookPeriods = [];
    
    if ~any(goodFixIdx)
        return;
    end
    
    % Only consider samples during good fixations
    roiDuringFix = fixroi;
    roiDuringFix(~goodFixIdx) = NaN;
    
    % Find contiguous periods of same ROI
    currentROI = NaN;
    startIdx = 1;
    
    for i = 1:length(roiDuringFix)
        if ~isnan(roiDuringFix(i))
            if isnan(currentROI) || roiDuringFix(i) ~= currentROI
                % Start of new look period
                if ~isnan(currentROI)
                    % End previous period
                    lookPeriods = [lookPeriods; startIdx, i-1, currentROI];
                end
                currentROI = roiDuringFix(i);
                startIdx = i;
            end
        else
            % End current period if we hit a non-fixation
            if ~isnan(currentROI)
                lookPeriods = [lookPeriods; startIdx, i-1, currentROI];
                currentROI = NaN;
            end
        end
    end
    
    % Handle final period
    if ~isnan(currentROI)
        lookPeriods = [lookPeriods; startIdx, length(roiDuringFix), currentROI];
    end
end

function [switchFlags, switchCountFlags, switchIdxStart, switchIdxEnd] = fCountSwitches(fixroi, goodFixIdx, targetROIs)
    % Count switches between target ROIs during good fixations
    % First entry into any target ROI counts as switch #1
    nSamples = length(fixroi);
    switchFlags = zeros(nSamples, 1, 'int16');
    switchCountFlags = zeros(nSamples, 1, 'int16');
    switchIdxStart = [];
    switchIdxEnd = [];
    
    if ~any(goodFixIdx)
        return;
    end
    
    % Get ROI sequence during good fixations only
    roiSequence = fixroi(goodFixIdx);
    goodIdx = find(goodFixIdx);
    
    if isempty(roiSequence)
        return;
    end
    
    % Track switches between target ROIs
    lastTargetROI = NaN;
    switchCount = 0;
    currentSwitchStart = NaN;
    hasSeenTargetROI = false;  % Track if we've seen any target ROI yet
    
    for i = 1:length(roiSequence)
        currentROI = roiSequence(i);
        sampleIdx = goodIdx(i);
        
        if ismember(currentROI, targetROIs)
            % Check if this is first target ROI entry or a switch
            if ~hasSeenTargetROI || (~isnan(lastTargetROI) && currentROI ~= lastTargetROI)
                % This is either the first target ROI entry or a switch!
                
                % End previous switch period if it exists
                if switchCount > 0 && ~isnan(currentSwitchStart)
                    switchIdxEnd = [switchIdxEnd; goodIdx(i-1)];
                end
                
                % Start new switch period
                switchCount = switchCount + 1;
                currentSwitchStart = sampleIdx;
                switchIdxStart = [switchIdxStart; currentSwitchStart];
                hasSeenTargetROI = true;
            end
            
            % Mark current sample as part of switch
            switchFlags(sampleIdx) = 1;
            switchCountFlags(sampleIdx) = switchCount;
            lastTargetROI = currentROI;
        end
        % If currentROI is not in targetROIs (e.g., 0 or 3), we don't update lastTargetROI
        % This means transitions like 1->0->1 or 1->3->1 don't count as switches
    end
    
    % Handle final switch period
    if switchCount > 0 && ~isnan(currentSwitchStart)
        switchIdxEnd = [switchIdxEnd; goodIdx(end)];
    end
    
    % Ensure start and end arrays have same length
    if length(switchIdxStart) > length(switchIdxEnd)
        switchIdxEnd = [switchIdxEnd; goodIdx(end)];
    end
end