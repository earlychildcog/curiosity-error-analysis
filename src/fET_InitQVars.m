% Create a "quality" table - initialise vars for speed here
% Initialise for Q
function Q = fET_InitQVars(Q)
Q.priorDiff(size(Q,1),1)  = ""; Q.priorAccu = nan(size(Q,1),1); Q.inclTrial(size(Q,1),1) = "";
Q.sideChosen(size(Q,1),1) = ""; Q.sideMatch(size(Q,1),1) = "";
Q.FixNb  = nan(size(Q,1),1); Q.FixNbInL= nan(size(Q,1),1); Q.FixNbInR= nan(size(Q,1),1); Q.FixNbInT= nan(size(Q,1),1); Q.FixNbNoAOI= nan(size(Q,1),1);
Q.FixTotDurInL = nan(size(Q,1),1); Q.FixTotDurInR = nan(size(Q,1),1); Q.FixTotDurInT = nan(size(Q,1),1); Q.FixTotDurInNoAOI = nan(size(Q,1),1);
Q.LookNb = nan(size(Q,1),1); Q.LookNbInL = nan(size(Q,1),1); Q.LookNbInR = nan(size(Q,1),1); Q.LookNbInT = nan(size(Q,1),1); Q.LookNbNoAOI = nan(size(Q,1),1);
Q.LookTotDurInL = nan(size(Q,1),1); Q.LookTotDurInR = nan(size(Q,1),1); Q.LookTotDurInT = nan(size(Q,1),1);
Q.NbSwitchesB   = nan(size(Q,1),1); Q.NbSwitchesAll = nan(size(Q,1),1);
Q.diff_fixAndeegTrig = nan(size(Q,1),1); Q.durTriggeringFix = nan(size(Q,1),1); Q.NbFix_AfterTriggeringFix = nan(size(Q,1),1);
Q.NbSwitchB_AfterTriggeringFix = nan(size(Q,1),1); Q.NbSwitchAll_AfterTriggeringFix = nan(size(Q,1),1);
end