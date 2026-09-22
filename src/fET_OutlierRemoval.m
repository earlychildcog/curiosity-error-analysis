function isNotOutlier = fET_OutlierRemoval(idx, T, trialType, opts)

arguments
    idx struct
    T table
    trialType string {mustBeMember(trialType, {'Corr', 'Incorr', 'PriorCorr', 'PriorIncorr', 'Easy', 'Medium', 'Hard', 'xHard', 'Harder'})} % here we could add a condition that deals with multiple trialTypes at once X1_X2
    opts.threshMed double  = 6
    opts.threshFreq double = 5
end

% Find the relevant trials
i_data = idx.(strcat(trialType, 'InclTrials'));
% Figure out wich trials are outliers
if ~isempty(i_data)
    isNotOutlier.nFix  = i_data(~isoutlier(T.nFixB_expl(i_data),"median",ThresholdFactor=opts.threshMed));
    value_counts = tabulate(T.nSwitchesB_expl(i_data));
    isNotOutlier.nSwitch = i_data(~ismember(T.nSwitchesB_expl(i_data), value_counts(value_counts(:,3) < opts.threshFreq, 1))); % <5% frequency
    isNotOutlier.decLat  = i_data(~isoutlier(T.dur_deci(i_data),"median",ThresholdFactor=opts.threshMed));
    isNotOutlier.allVars = intersect(isNotOutlier.nFix,intersect(isNotOutlier.nSwitch,isNotOutlier.decLat));
else
    isNotOutlier.allVars = [];
end

end