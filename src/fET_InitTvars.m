%Initialise variables for T table for fixation parsing
function T = fET_InitTvars(T)
T.priorDiff(size(T,1),1)     = ""; T.priorAccu       = nan(size(T,1),1);
T.flagFix(size(T,1),1)       = ""; T.flagFixNb       = nan(size(T,1),1);
T.flagLook(size(T,1),1)      = ""; T.flagLookNb      = nan(size(T,1),1);
T.flagSwitchB(size(T,1),1)   = ""; T.flagSwitchBNb   = nan(size(T,1),1);
T.flagSwitchAll(size(T,1),1) = ""; T.flagSwitchAllNb = nan(size(T,1),1);
end
