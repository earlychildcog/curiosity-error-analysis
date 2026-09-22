%% Combine the ET and EEG triggers (one cn be missing info from the other)
% 1. Load all the eyelink messages -> save into an event file
% 2. Load all the egi triggers -> save into an event file
% 3. realign the time stamps and save a combination of both
%

%% Define important variables

visit = 3;

% Paths (normally no need to change)
dataPath        = [filesep,fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d',visit),'eyetracking')];
eyetrackingFile = fullfile(dataPath,sprintf('all-visit%d.mat',visit));
eegFile         = fullfile(dataPath,sprintf('all-visit%d-mff-events.mat',visit));
pathERN         = fullfile(strrep(dataPath, 'eyetracking', 'ERN'),'1_matFiles');
pathFRN         = fullfile(strrep(pathERN, 'ERN', 'FRN'));

% ET events and their EEG codes correspondence
events_eye = ["::trial start", "::bottom cards face up", "::flipped bottom card", "::start move up", "::start reward", "::start bad", "::cards start flying out", "::end:", "::flipped card ("];
codes_eeg  = ["strt",          "bcfu",                   "bcfl",                  "movu",            "rew0",           "bad0",        "cfly",                     "endT",               "f1fl"];
% extra events that do not match with events in the edf files; to be treated separately after a main merged table has been constructed
codes_eeg_extra = ["fixT", "fixB", "f1lo"];


%% Load the eyetracking data (big table) and save the ET events to a csv
load(eyetrackingFile,"T");

% keep only trial data (remove attget etc)
index_start   = contains(T.messages, "::trial start");
index_end     = contains(T.messages, "::end:");
index_end     = [false; index_end(1:end-1)];        % shift to keep end trial message
index_intrial = cumsum(index_start - index_end);    % 1 if within trial, 0 if outside
assert(all(index_intrial == 0 | index_intrial == 1), "starts and ends of trials do not match :/")
T = T(index_intrial == 1,:);

% normalise time at zero (now, trial starts after the attention getter ended)
timeStarts = varfun(@(x)x(1), T, InputVariables="time", GroupingVariables=["session" "trial"]); timeStarts.GroupCount = [];
T = join(T, timeStarts); T.time = T.time - T.Fun_time; T.Fun_time = [];

% fix the trial number to account for all the trials we just deleted
tblTrials = varfun(@(x)cumsum(x == 0), T, InputVariables="time", GroupingVariables="session");
T.trial_fixed = tblTrials.Fun_time;
clear tblTrials

% construct the event table for the eyetracking
GroupingVariables=["session" "trial_fixed" "trialno" "trialID" "trial" "time" "difficulty" "objL" "objR" "objT" "result" "delayFirstFixT" "delayFirstFixB" "accuracy" "sideMatch" "sideChosen" "keyboardFlip" "messages"];
I = contains(T.messages, events_eye);
tblEventsEye = T(I, GroupingVariables);
tblEventsEye.event_eye = events_eye(sum(cell2mat(arrayfun(@(x)contains(tblEventsEye.messages, x), events_eye, UniformOutput=false)).*(1:numel(events_eye)), 2))';
tblEventsEye.code_eeg  = codes_eeg(sum(cell2mat(arrayfun(@(x)contains(tblEventsEye.messages, x), events_eye, UniformOutput=false)).*(1:numel(events_eye)), 2))';

% save it
writetable(tblEventsEye, fullfile(dataPath,sprintf('all-visit%d-events-ET.csv',visit)));

return;

%% load the eeg data and merge the EEG ERN & FRN codes into one big table

% [tblJoined, tblERN, tblFRN] = fEEGmergeERNandFRNMetadata(pathERN, pathFRN, verbose=true);

%% simplify the EEG table

% tblEventsEye = readtable("data/eyetracking/Visit1/events_eyelink.csv", TextType="string");
% tblEventsEEG = readtable("data/EEG/mff-visit1-events.csv", TextType="string");

% remove events that we do not care about from the eeg
tblEventsEEG(~ismember(tblEventsEEG.code, codes_eeg_extended), :) = [];
% create latency (time) columns per subject and per trial that start from 0
fNormTime = @(x)(x-x(1))/10;
tblLat                     = varfun(fNormTime, tblEventsEEG, InputVariables="latency", GroupingVariables="session");
tblEventsEEG.latency_norm  = tblLat.Fun_latency;
tblLat                     = varfun(fNormTime, tblEventsEEG, InputVariables="latency", GroupingVariables=["session" "trial"]);
tblEventsEEG.latency_trial = tblLat.Fun_latency;
tblEventsEEG               = sortrows(tblEventsEEG, ["session" "trial" "latency_trial"]);

%% join the two tables

tblMixed = innerjoin(tblEventsEye, tblEventsEEG, LeftKeys=["session" "trial_fixed" "code_eeg"], RightKeys=["session" "trial" "code"]);
% tblMixed = tblMixed(tblMixed.code_eeg == "strt" | tblMixed.code_eeg == "endT", :);
tblMixed = sortrows(tblMixed, ["session" "latency"]);
tblMixed = sortrows(tblMixed, ["session" "trial_fixed" "latency_trial"]);
% inner join creates some duplicate rows, not sure why? Anyway we can just delete them
tblMixed(diff(tblMixed.latency) == 0, :) = [];

%% add the extra EEG events (that do not match with ET ones)

tblEventsEEGextra = tblEventsEEG(ismember(tblEventsEEG.code, codes_eeg_extra), :);
% outer join just to create the right table structure (columns etc), lazy way
tblEventsEEGextra = outerjoin(tblEventsEEGextra, tblEventsEye, LeftKeys=["session" "trial" "code"], RightKeys=["session" "trial_fixed" "code_eeg"], MergeKeys=true);
% delete the rows that correspond to the eyelink events, we do not need those, because we only care about merging the extra eeg events here
tblEventsEEGextra(ismissing(tblEventsEEGextra.mffkey_diff), :) = [];
% rename variable names to fit the mixed table
tblEventsEEGextra.Properties.VariableNames([2 4]) = ["trial_fixed" "code_eeg"];
tblEventsEEGextra.Properties.VariableNames(strcmp(tblEventsEEGextra.Properties.VariableNames, "trial_tblEventsEye")) = "trial";
tblEventsEEGextra = tblEventsEEGextra(:, string(tblMixed.Properties.VariableNames));
% add the two tables together
tblMixedExtended = cat(1, tblMixed, tblEventsEEGextra);

tblMixedExtended = sortrows(tblMixedExtended, ["session" "latency"]);
% measure how aligned eeg and eyetracking events are
tblMixedExtended.timediff = tblMixedExtended.time - tblMixedExtended.latency_trial;
% create corresponding times for merging in the big eyetracking table; assume perfect alignment between eeg and eyetracking (data showed alignment was good)
tblMixedExtended.time(isnan(tblMixedExtended.time)) = tblMixedExtended.latency_trial(isnan(tblMixedExtended.time));
% eyelink times are even numbers, so we floor the odd ones to the closest even
tblMixedExtended.time = tblMixedExtended.time - mod(tblMixedExtended.time, 2);

%% merge eeg events to the big table
% prepare the eeg events for adding to the big eyetracking table
tblEEG_aligned = tblMixedExtended(:, ["session" "trial_fixed" "time" "code_eeg"]);
tblEEG_aligned.session = categorical(tblEEG_aligned.session);
tblEEG_aligned.Properties.VariableNames(end) = "code_eeg_aligned";
tblEEG_aligned.code_eeg_aligned = categorical(tblEEG_aligned.code_eeg_aligned);
% we need this to align events
T.id = uint32((1:size(T,1)))';
% merge to a smaller table (only the times that exists in the eeg aligned table)
S = innerjoin(T, tblEEG_aligned, Keys=["session" "trial_fixed" "time"]);
% again delete duplicate rows that innerjoin mysteriously makes
S(diff(S.id) == 0, :) = [];
% set a default for the new column and embed the small table inside the big one
T.code_eeg_aligned = categorical(nan(size(T,1),1));
T(ismember(T.id, S.id), :) = S;
% save the new table
save(sprintf("data/eyetracking/Visit%d/all-visit%d-weeg_codes.mat",visit,visit),"T","-v7.3");    %save the big table%%


%%
T = table2struct(T);
save(sprintf("data/eyetracking/Visit%d/all-visit%d-weeg_codes-separate.mat",visit,visit), "-struct", "T");    %save the big table%%
