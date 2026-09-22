function [T_out, participantOutliers] = fET_OutlierRemovalGroupLevel(ctrl_vars, T_out, trialTypes, groups, opts)

arguments
    ctrl_vars table
    T_out table
    trialTypes (1,:) cell {mustBeText, mustBeMember(trialTypes, {'Corr','Incorr','PriorCorr','PriorIncorr','Easy','Medium','Hard','xHard','Harder'})}
    groups (1,:) cell {mustBeText, mustBeMember(groups, {'all', 'R', 'NR'})}
    opts.threshMed double   = 4
    opts.threshFreq double  = 5
    opts.prctiles double    = [1 99]
end

idx = fGetSessions(groups, ctrl_vars);

% Take out participant outliers (per group)
allOutliers = [];
for i_trialType = 1:size(trialTypes,2)
    trialType = trialTypes{i_trialType};
    for i_Group = 1:size(groups,2)
        group = groups{i_Group};
        isOutlier.([trialType '_' group])(:,1) = idx.(group)(isoutlier(T_out.(['nFixExpB_' trialType])(idx.(group)),"median",ThresholdFactor=opts.threshMed) ...
            | isoutlier(T_out.(['nSwitchExpB_' trialType])(idx.(group)),"percentiles",opts.prctiles) ...
            | isoutlier(T_out.(['decLat_' trialType])(idx.(group)),"median",ThresholdFactor=opts.threshMed));
        allOutliers = [allOutliers; isOutlier.([trialType '_' group])];
    end
end
participantOutliers = unique(allOutliers);
if ~isempty(participantOutliers)
    % Replace all variables of interest by NaN, except N trials (kept for ref)
    T_out{participantOutliers,find(strcmp(T_out.Properties.VariableNames,'accuracy')):end} = NaN;
end

end
