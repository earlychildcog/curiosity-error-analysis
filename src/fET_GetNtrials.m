function T = fET_GetNtrials(idx, session, T)

iSession = ismember(T.session,session);
T.Ntr_Test(iSession)   = numel(idx.TestTrials);
T.Ntr_Easy(iSession)   = numel(idx.EasyTrials);
T.Ntr_Medium(iSession) = numel(idx.MediumTrials);
T.Ntr_Hard(iSession)   = numel(idx.HardTrials);
T.Ntr_xHard(iSession)  = numel(idx.xHardTrials);
T.Ntr_Harder(iSession) = numel(idx.HarderTrials);
T.Ntr_Corr(iSession)   = numel(idx.CorrTrials);
T.Ntr_Incorr(iSession) = numel(idx.IncorrTrials);
T.Ntr_OptIn(iSession)  = numel(idx.OptInTrials);
T.accuracy(iSession)   = T.Ntr_Corr(iSession)/T.Ntr_OptIn(iSession);

end
