function T = fET_CleanUp(T,opts)
arguments
    T
    opts.screenDimensions = [1280 1024];
end
fprintf("Cleaning up unwanted data (familiarisation, fixation cross, etc.).... \n");
% ---- Find events & remove unwanted trials (familiarisation...)
T.trialID = []; % trialID not needed
% KEYPRESSES -- Remove trials in which arrow key was pressed
% T(T.keyArrow==1, :) = []; % old way for pilots (based on EEG triggers)
T(T.keyboardFlip==1, :) = []; % for visit 1 (based on eyelink messages)
% FAM -- remove fam trials
T(T.trialtype ~= "Test",:) = [];
T.trialtype = [];
% INCOMPLETE -- remove trials that were terminated early for various reasons
% *for experimenter-related only* = keep -6, -5, -4 (= opt-out trials)
T(T.result <= -9 | T.result == -3 | ...
    T.result == -2 | T.result == -1, :) = [];
% FYI -- these are the codes saved as flagResult during data acquision:
%   -21 to -25: video break
%   -10: clicked arrow -- Added by using the EEG script before (not done
%   anymore??)
%   -9: quit
%   -6: aborted by looking away
%   -5: aborted by max trial duration
%   -4: aborted by not flipping
%   -3: skipped trial
%   -2: pause/video    -- only in pilots
%   -1: recalibrate
%    0: nothing
%    6: ended trial, repeating it because not enough cards were flipped (FamFlip trials only)
% ---- Add trial steps (segments) column
markers_steps = [...
    "bottom cards face up"...       % exploration starts
    "top card faces up"...          % decision starts
    "flipped bottom card"];         % feedback
TblTrial = varfun(@(x)sum(contains(x,markers_steps)), T, "InputVariables","messages","GroupingVariables",["session" "trial" "difficulty"]);
TblTrial.Properties.VariableNames(end) = "step_reached";
TblTrial.GroupCount = [];
TblTrial.step_reached = uint8(TblTrial.step_reached);
% ---- Put it back in the main table
T = join(T, TblTrial);
% ---- Segment into periods
phaseName = ["exploration", "decision", "feedback"];
T = fET_FindPeriod(T,markers_steps,phaseName);
% ---- Accuracy & opt out trials
% DIFFERENT ACCURACY VALUE FOR OPT OUT (used to be 0 but need different from
% incorrect!) NB -- unfortunately sideChosen has a value (left or right) even
% when the trial timed out! Replace with NA)
T.isOptOut = T.step_reached ~= 3;
T.accuracy(T.isOptOut==1)    = 127;
T.sideChosen(T.isOptOut==1)  = 'NA';
% ---- Keep only trial data (remove attget etc)
% X = varfun(@(x)~any(contains(x, "::end:")), T, "InputVariables","messages","GroupingVariables",["session" "trialno" "trial"]);
% X(X.Fun_messages,:)
index_start   = contains(T.messages, "::trial start");
index_end     = contains(T.messages, "::end:");
index_end     = [false; index_end(1:end-1)];           % shift to keep end trial message
index_intrial = cumsum(index_start - index_end);       % 1 if within trial, 0 if outside
assert(all(index_intrial == 0 | index_intrial == 1), "starts and ends of trials do not match :/")
T = T(index_intrial == 1,:);
% ---- Take out data outside of screen
out_of_screenL = T.lx < 0 | T.lx >opts.screenDimensions(1) | T.ly < 0 | T.ly >opts.screenDimensions(2);
out_of_screenR = T.rx < 0 | T.rx >opts.screenDimensions(1) | T.ry < 0 | T.ry >opts.screenDimensions(2);
dimX =opts.screenDimensions(1);
T.inScreenLx = T.lx/dimX; T.inScreenRx = T.rx/dimX; T.inScreenLy = T.ly/dimX; T.inScreenRy = T.ry/dimX;
T.inScreenLx(out_of_screenL) = NaN; T.inScreenRx(out_of_screenR) = NaN;
T.inScreenLy(out_of_screenL) = NaN; T.inScreenRy(out_of_screenR) = NaN;
clear out_of_screenL out_of_screenR
% ---- Clean more
T(T.period_in_trial == "-",:) = []; % we do not need the "cards flying in" period
end