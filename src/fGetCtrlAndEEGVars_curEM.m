function [ctrl_vars, eegData, eegETsessions] = fGetCtrlAndEEGVars_curEM(visit, sessions, opts)

arguments
    visit (1,1) int8 {mustBeMember(visit, [1 2 3])}
    sessions categorical
    opts.pathDataRoot      = [filesep, fullfile('Users',getenv('USER'),'Data','curE')];
    opts.pathDataEEG       = strcat("FRN", filesep, "4_OutputsForStats");
    opts.eegFileName       = "bothERNandFRN_ValuesinROI_PerSubj_minTwoPeaks_BL-298_-150.csv";
    opts.ctrlVars_filename = 'curio_ctrlVars_curEM.csv';
end
% Load eeg data, keep only relevant stuff and figure out list of subjects
path_DataEEG = fullfile(opts.pathDataRoot, sprintf("Visit%d",visit), opts.pathDataEEG, opts.eegFileName);
eegData = readtable(path_DataEEG);
eegSessions = categorical(eegData{:,1});
eegData = eegData(:,contains(eegData.Properties.VariableNames,'RN')); % only export relevant ERN/FRN variables, not ctrlvars or subjnames again...
eegETsessions = sessions(ismember(sessions,eegSessions));
% Load ctrl variables data, add a variable for whether subjects were included in EEG nalysis at 12m, and save
ctrl_vars = readtable(fullfile(opts.pathDataRoot,opts.ctrlVars_filename));
ctrl_vars.session = categorical(ctrl_vars.session);
ctrl_vars.isInEEGAnalysis12m = ismember(ctrl_vars.session,eegSessions);
writetable(ctrl_vars, fullfile(opts.pathDataRoot,'curio_extraVars_curEM.csv'));
ctrl_vars = ctrl_vars(ismember(ctrl_vars.session,eegETsessions),:);

end