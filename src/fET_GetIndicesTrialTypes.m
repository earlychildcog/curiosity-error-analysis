% Figure out what are the indices of different types of trials on which we
% will compute the stats
% Based on inclusion criteria, accuracy, prior accuracy, difficulty...
% (Checking a bit extra than necessary if we want to look at other things)
%
% Note: Here we only keep trials that have both exp and dec that is clean
% but note that we could analyse Dec and exp variables on separate sets
% of trials if needed to have more data (but not recommended as each
% variable will be based on different sets of trials)
%

function idx = fET_GetIndicesTrialTypes(T, session)
    iSession = ismember(T.session,session);
    idx.AllTrialsSubj     = find(iSession);
    idx.CleanTrials       = find(iSession & ~strcmp(T.incl_expl,'reject') & ~strcmp(T.incl_deci,'reject'));
    idx.CleanExp          = find(iSession & ~strcmp(T.incl_expl,'reject'));
    idx.CleanDec          = find(iSession & ~strcmp(T.incl_deci,'reject'));
    idx.FamTrials         = find(iSession & strcmp(T.trialType,'Fam'));
    idx.TestTrials        = find(iSession & strcmp(T.trialType,'Test'));
    idx.TestInclTrials    = find(iSession & strcmp(T.trialType,'Test'));
    idx.OptInTrials       = find(iSession & strcmp(T.trialOptInOut,'OptIn'));
    idx.OptOutTrials      = find(iSession & strcmp(T.trialOptInOut,'OptOut'));
    idx.CorrTrials        = find(iSession & T.accuracy==1 & strcmp(T.trialOptInOut,'OptIn'));
    idx.IncorrTrials      = find(iSession & T.accuracy==0 & strcmp(T.trialOptInOut,'OptIn'));
    idx.PriorInclude     = find(iSession & ( strcmp(T.incl_expl,'include') & strcmp(T.incl_deci,'include') ));
    idx.DiffInclude      = find(iSession & ( (strcmp(T.incl_expl,'include') | strcmp(T.incl_expl,'change in difficulty')) & (strcmp(T.incl_deci,'include') | strcmp(T.incl_expl,'change in difficulty')) ));
    idx.AccuInclude      = find(iSession & (~strcmp(T.incl_expl,'reject') & ~strcmp(T.incl_deci,'reject')));
    idx.TrialsSameDiff    = find(iSession & strcmp(T.trialType,'Test') & T.diffStayedSame==1);
    idx.PriorCorrTrials   = find(iSession & T.priorAccu==1);
    idx.PriorIncorrTrials = find(iSession & T.priorAccu==0);
    idx.PriorCorrInclTrials   = intersect(idx.PriorInclude,idx.PriorCorrTrials);
    idx.PriorIncorrInclTrials = intersect(idx.PriorInclude,idx.PriorIncorrTrials);
    idx.CorrInclTrials        = intersect(idx.AccuInclude,idx.CorrTrials);
    idx.IncorrInclTrials      = intersect(idx.AccuInclude,idx.IncorrTrials);
    idx.EasyTrials        = find(iSession & strcmp(T.diff_binary,'Easy'));
    idx.MediumTrials      = find(iSession & strcmp(T.difficulty,'Medium'));
    idx.HardTrials        = find(iSession & strcmp(T.difficulty,'Hard'));
    idx.xHardTrials       = find(iSession & strcmp(T.difficulty,'xHard'));
    idx.HarderTrials      = sort([idx.MediumTrials;idx.HardTrials;idx.xHardTrials]);
    idx.EasyInclTrials   = intersect(idx.DiffInclude,idx.EasyTrials);
    idx.MediumInclTrials = intersect(idx.DiffInclude,idx.MediumTrials);
    idx.HardInclTrials   = intersect(idx.DiffInclude,idx.HardTrials);
    idx.xHardInclTrials  = intersect(idx.DiffInclude,idx.xHardTrials);
    idx.HarderInclTrials = intersect(idx.DiffInclude,idx.HarderTrials);

end