%% Get N trials per participant

function fET_GetNTrialsPerParticipant(visit, pathDataSummaryOut, T)
S0 = T(T.time == 0 & T.difficulty~='FamEasy' & T.difficulty~='FamFlip', ["session" "trial" "accuracy" "difficulty"]);
S0.difficulty = removecats(S0.difficulty); S0.difficulty = reordercats(S0.difficulty, ["Easy","Medium","Hard","xHard"]);
accu = [0 1 127];

S1 = varfun(@(x)sum(x==accu), S0,"InputVariables","accuracy","GroupingVariables",["session" "difficulty"]);
S1 = splitvars(S1);
S1.Properties.VariableNames(end) = "Ntrials_OptOut"; S1.Properties.VariableNames(end-1) = "Ntrials_Corr";
S1.Properties.VariableNames(end-2) = "Ntrials_Incorr"; S1.Properties.VariableNames(end-3) = "Ntrials";
S1 = unstack(S1,["Ntrials" "Ntrials_OptOut" "Ntrials_Corr" "Ntrials_Incorr"],"difficulty");

S2 = varfun(@(x)sum(x==accu), S0,"InputVariables","accuracy","GroupingVariables","session");
S2 = splitvars(S2);
S2.Properties.VariableNames(end) = "Ntrials_OptOut"; S2.Properties.VariableNames(end-1) = "Ntrials_Corr";
S2.Properties.VariableNames(end-2) = "Ntrials_Incorr"; S2.Properties.VariableNames(end-3) = "Ntrials_Tot";

S = innerjoin(S2,S1);

save(fullfile(pathDataSummaryOut, sprintf("nTrials-visit%d.mat", visit)), "S");
writetable(S, fullfile(pathDataSummaryOut, sprintf("nTrials-visit%d.csv", visit)));
end
