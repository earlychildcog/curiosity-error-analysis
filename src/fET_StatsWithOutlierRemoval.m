% Outlier removal -- being mindful of low N trials in some cases
% -> we use the MAD per participant, variable (nFix, nSwitch, decLat) and
% trialType, then remove whole trial if one variable is bad
% /!\ nSwitch is very discrete -> median not appropriate -> use a frequency
% approach (remove very rare alues e.g. happening <5% of the time)

function T_out = fET_StatsWithOutlierRemoval(idx, session, T_in, T_out, trialType, opts)

arguments
    idx   struct
    session categorical
    T_in  table
    T_out table
    trialType string {mustBeMember(trialType, {'Corr', 'Incorr', 'PriorCorr', 'PriorIncorr', 'Easy', 'Medium', 'Hard', 'xHard', 'Harder'})} % here we could add a condition that deals with multiple trialTypes at once X1_X2
    opts.threshMed   double = 6
    opts.threshFreq  double = 5
end

isNotOutlier = fET_OutlierRemoval(idx, T_in, trialType, threshMed=opts.threshMed, threshFreq=opts.threshFreq);

% Calculate mean
% (This returns a NaN for empty arrays, not a zero: ok for later stats)
iSession = find(T_out.session == session);
T_out.(strcat('nFixExpB_', trialType))(iSession)        = mean(T_in.nFixB_expl(isNotOutlier.allVars),'omitmissing');
T_out.(strcat('nSwitchExpB_', trialType))(iSession)     = mean(T_in.nSwitchesB_expl(isNotOutlier.allVars),'omitmissing');
T_out.(strcat('decLat_', trialType))(iSession)          = mean(T_in.dur_deci(isNotOutlier.allVars),'omitmissing');

end