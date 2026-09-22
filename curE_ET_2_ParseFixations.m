%% Parse fixations and saccades
% This script has not been adpated for single threading -- parallel
% processing toolbox needed
%

%% Define important variables
clear all
close all

visit        = 1;        % 1/2/3
flagParallel = true;     % false/true --- false won't work here


% Define more things and load data
addpath("src");
addpath(genpath(fullfile("src","libraries")));
% Paths (normally no need to change)
pathData           = [filesep, fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d',visit),'eyetracking')];
pathDataSummaryOut = fullfile(pathData, sprintf('3_whole-group-visit%d',visit));
pathDataStatsOut   = fullfile(pathData, '4_OutputsForStats');
util.fMkDirSafe(pathDataStatsOut);
% Parallel processing
fSetUpFieldtripAndParallelPool(flagParallel=flagParallel);
addpath("src");
% Load the data
fprintf("Loading the big table.... \n");
load(fullfile(pathDataSummaryOut,sprintf('all-visit%d.mat',visit)),"T");


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREP FOR PARSING

%% Clean table up (take out unwanted data e.g., fixation cross...) and check  data quality per eye
fprintf("Now preparing data for parsing fixations and saccades.... \n");
fprintf("Checking data quality.... ");
[T, Q] = fET_CheckQuality(T, visit, flagCleanFirst=true);
Tq=T;
save(fullfile(pathDataSummaryOut,sprintf('all-visit%d-quality.mat',visit)),"Tq","Q",'-v7.3');
clear Tq

%% Slash table into pieces that can go to different cpu threads and in general save computation (even with 1 thread)
% Get unique sessions (participants) and their corresponding numbers
sessions  = unique(T.session);
nSessions = numel(sessions);
T_ = fET_GetTableChunksForThreading(T, visit);
clearvars T

%% Extend gap + Save prior trial's difficulty and prior accuracy values
fprintf("Extending gaps.... ");
gap_length_samples = 15; % take 15 more samples out on each side of gaps in data (30 samples = 60ms)
parfor iSession = 1:nSessions
    session = sessions(iSession);
    T = T_{iSession};
    disp(session);
    for trial = unique(T.trial)'
        I = T.trial == trial;
        T.inScreenLx(I) = fET_ExtendGap(T.inScreenLx(I), gap_length_samples);
        T.inScreenLy(I) = fET_ExtendGap(T.inScreenLy(I), gap_length_samples);
        T.inScreenRx(I) = fET_ExtendGap(T.inScreenRx(I), gap_length_samples);
        T.inScreenRy(I) = fET_ExtendGap(T.inScreenRy(I), gap_length_samples);
    end
    T_{iSession} = T;
end
clearvars gap_length_samples

%% Interpolate
% Need to do this outside of the loop by padding trials with lots of NaNs
% for example (more NaNs than maxSamp)
% fs = 500;
fprintf("Interpolating them.... ");
maxSecs = 0.16; % max 160ms long gaps
maxDist = 0.02; % max distance between in postions 1 & 2 = 2% of the screen
parfor iSession = 1:nSessions
    session = sessions(iSession);
    T = T_{iSession};    disp(session);
    fs = round(1000 / median(diff(T.time)));
    maxSamp = round(maxSecs * fs);
    for trial = unique(T.trial)'
        I = T.trial == trial;
        [T.inScreenLx(I), T.inScreenLy(I)] = fET_InterpolateGaze(T.inScreenLx(I), T.inScreenLy(I), maxDist, maxSamp);
        [T.inScreenRx(I), T.inScreenRy(I)] = fET_InterpolateGaze(T.inScreenRx(I), T.inScreenRy(I), maxDist, maxSamp);
    end
    T_{iSession} = T;
end
clearvars maxSecs maxDist fs maxSamp I


%% Smooth
fprintf("Smoothing data.... ");
smoothing = 10;
parfor iSession = 1:nSessions
    session = sessions(iSession);
    T = T_{iSession};
    disp(session);
    for trial = unique(T.trial(T.session == session))'
        I = T.trial == trial & T.session == session;
        [T.LxSmooth(I), T.LySmooth(I)] = fET_SmoothGaze(T.inScreenLx(I), T.inScreenLy(I), smoothing);
        [T.RxSmooth(I), T.RySmooth(I)] = fET_SmoothGaze(T.inScreenRx(I), T.inScreenRy(I), smoothing);
    end
    T_{iSession} = T;
end
clearvars smoothing I

%% Average eyes where possible/where they are booth good
fprintf("Averaging eyes where possible.... ");
parfor iSession = 1:nSessions
    session = sessions(iSession);
    T_{iSession} = fET_AverageEyesWhenPossible(T_{iSession});
    disp(session);
end

%% Done, reconcatenate and save
fprintf("\n Done! Concatenating and saving for all these steps.... \n");
T = cat(1, T_{:});
save(fullfile(pathDataSummaryOut,sprintf('all-visit%d-ForParsing.mat',visit)),"T",'-v7.3');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DO THE PARSING

% Parse the fixations and save a bunch of stuff
fprintf("Parsing fixations and saccades .... \n");
sessions  = unique(T.session);
nSessions = numel(sessions);
[fixParsing, T, Q] = fET_ParseFixationsCurE(nSessions, T, Q);
fprintf("Done, saving it.... \n");
% Save
save(fullfile(pathDataSummaryOut,sprintf('all-visit%d-Parsed-DetailsInAStructure.mat',visit)),"fixParsing",'-v7.3');
save(fullfile(pathDataSummaryOut,sprintf('all-visit%d-Parsed.mat',visit)),"T",'-v7.3');
save(fullfile(pathDataSummaryOut,sprintf('perPeriod-visit%d-Parsed.mat',visit)),"Q");
writetable(Q,fullfile(pathDataSummaryOut,sprintf('perPeriod-visit%d-Parsed.csv',visit)));

% Reorganise into a table with one value per trial
fprintf("Reorganise into a table with 1 value per trial and not per sample.... \n");
R = fET_ReorganiseTableIntoOneTrialPerRow(Q);
save(fullfile(pathDataSummaryOut, sprintf("perTrial-visit%d.mat",visit,visit)),"R");
writetable(R,fullfile(pathDataSummaryOut, sprintf("perTrial-visit%d.csv",visit,visit)));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REMOVE OUTLIERS

fprintf("Now removing outliers.... \n");
% First load eeg and ctrl variables to save all into 1 big file for stats
[ctrl_vars, eegData, eegETsessions] = fGetCtrlAndEEGVars_curEM(visit, sessions);
% Keep only the participants with EEG & ET and create empty tables to export the data
sessions = eegETsessions;
R = R(ismember(R.session, sessions),:);
T_Stats = fET_InitialiseStatsTable(sessions);
% Now loop through the ppts and remove outliers + calculate stats
for iSession = 1:numel(sessions)
    session = sessions(iSession);
    % Find current participant's relevant data
    idx = fET_GetIndicesTrialTypes(R, session);
    % Outlier removal at participant level -- use MAD for +/- continuous variables, else frequency
    threshMed  = 6; % for nFix and DecLat
    threshFreq = 5; % for  (too discrete for MAD)
    trialTypes = {'PriorCorr', 'PriorIncorr'};
    for trialType = trialTypes
        T_Stats = fET_StatsWithOutlierRemoval(idx, session, R, T_Stats, trialType, threshMed=threshMed, threshFreq=threshFreq);
    end
    % Calculate how many (included) trials there are per condition for each participant
    T_Stats = fET_GetNtrials(idx, session, T_Stats);
end
% Remove outliers at the group level
threshMed  = 6;
prctiles   = [1 99];
trialTypes = {'PriorCorr', 'PriorIncorr'};
groups     = {'R', 'NR'};
[T_Stats, ~] = fET_OutlierRemovalGroupLevel(ctrl_vars, T_Stats, trialTypes, groups, threshMed=threshMed, prctiles=prctiles);
% Export to csvs for stats
T_all = [ctrl_vars, T_Stats(:,2:end), eegData];
T_R   = T_all(strcmp(T_all.mirror,'R'),:);
T_NR  = T_all(strcmp(T_all.mirror,'NR'),:);
writetable(T_all, fullfile(pathDataStatsOut,sprintf('visit%d_AllData_EEGandET_wholeGroup.csv',visit)));
writetable(T_R, fullfile(pathDataStatsOut,sprintf('visit%d_AllData_EEGandET_onlyR.csv',visit)));
writetable(T_NR, fullfile(pathDataStatsOut,sprintf('visit%d_AllData_EEGandET_onlyNR.csv',visit)));

beep