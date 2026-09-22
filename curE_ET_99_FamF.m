%% Process the Fam trials to count flips...
clear all
close all

addpath("src")
visitNo = 1;
letterVisit = {'a','b','c'};
visitLetter = letterVisit{visitNo};

%% Load
screenDimensions = [1280 1024];
parentDir = fileparts(pwd);

load(sprintf("data/eyetracking/Visit%d/all-visit%d.mat",visitNo,visitNo),"T");                %just load the big table
listETSubj = unique(T.session);

% ctrl_vars = readtable(fullfile(parentDir,'curE_EEGAnalysis','data','ForStats','curio_ControlVars_includedSessionsOnly.csv'));
% eegData   = readtable(fullfile(parentDir,'curE_EEGAnalysis','data','ForStats','bothERNandFRN_ValuesinROI_PerSubj_avgAndMinTwoPeaks_BL-298_-150.csv'));
ctrl_vars = readtable(fullfile(pwd,'data','Eyetracking','curio_extraVarsVisits123.csv'));
ctrl_vars.session = cellfun(@(x) ([x, visitLetter]), ctrl_vars.session, 'UniformOutput', false);

if visitNo == 1 || visitNo == 2
    eegData    = readtable(fullfile(parentDir,'curE_EEGAnalysis','data',sprintf('visit%d',visitNo),'ForStats','bothERNandFRN_ValuesinROI_PerSubj_avgAndMinTwoPeaks_BL-298_-150.csv'));
elseif visitNo == 3
    eegData    = readtable(fullfile(parentDir,'curE_EEGAnalysis','data',sprintf('visit%d',visitNo),'ForStats','ERN_ValuesinROI_PerSubj_avgAndMinTwoPeaks_BL-298_-150.csv'));
end
eegData_export = eegData(:,contains(eegData.Properties.VariableNames,'RN')); % only export relevant variables, not ctrlvars or subjnames again...
listEEGSubj = unique(eegData{:,1});
% listEEGSubj = cellfun(@(x) (x(1:end-1)), listEEGSubj, 'UniformOutput', false);
listSubj    = listETSubj(contains(string(listETSubj),listEEGSubj));
ctrl_vars = ctrl_vars(contains(ctrl_vars.session,string(listSubj)),:);
T = T(ismember(T.session,listSubj),:);

% trialID not needed
T.trialID = [];


%% Find events & remove unwanted trials
% keep only FamF trials
T(T.trialtype ~= "FamFlip",:) = [];
T.trialtype = [];

% Could check result var to save some stuff but skipping for now
% FYI -- these are the codes saved as flagResult during data acquision:
%   -21 to -25: video break
%   -10: clicked arrow -- Added by using the EEG script before
%   -9: quit
%   -6: aborted by looking away
%   -5: aborted by max trial duration
%   -4: aborted by not flipping
%   -3: skipped trial
%   -2: pause/video    -- only in pilot trials
%   -1: recalibrate
%    0: nothing
%    6: ended trial, repeating it because not enough cards were flipped (FamFlip trials only)

% NB: can check messages containing '::Pressed' for key presses but arrow
%  presses weren't saved so we don't know when the experimenter flipped
%  themselves with a key... Might be recoverable from the EEG files but not
%  doing this rn


%% Now get values per trial and baby
iLoop = 0;
sessions    = unique(T.session)';
eegsessions = categorical(unique(eegData.Row_1))';
for session = sessions
    disp(session);
    trials = unique(T.trial(T.session == session))';
    nTrials = numel(trials);
    for trial = trials
        iLoop = iLoop +1;
        I  = T.trial == trial & T.session == session;
        T_ = T(I,:);
        index_start     = contains(T_.messages, "::trial start");
        index_cardFlip  = contains(T_.messages, "::flipped card");
        i_cardFlip      = find(index_cardFlip);
        Q1_.session(iLoop,1)             = session;
        Q1_.trial(iLoop,1)               = trial;
        Q1_.nFamFTrials(iLoop,1)         = nTrials;
        Q1_.NCardsFlipped(iLoop,1)       = sum(index_cardFlip);
        Q1_.cardsFlipped{iLoop,1}        = extractBetween(T_.messages(index_cardFlip),17,21); %get card ID from message string (characters 17-21)
        [Q1_.diffCardsFlipped{iLoop,1}, i1stTimeDiffCard] = unique(Q1_.cardsFlipped{iLoop,1}, 'first');
        Q1_.NDiffCardsFlipped(iLoop,1)   = size(Q1_.diffCardsFlipped{iLoop,1},1);
        Q1_.timeForEachFlip{iLoop,1}     = T_.time(index_cardFlip) - T_.time(index_start);
        Q1_.timeForEachDiffFlip{iLoop,1} = T_.time(i_cardFlip(i1stTimeDiffCard)) - T_.time(index_start);
        if length(Q1_.timeForEachFlip{iLoop,1}) > 1
            Q1_.delayForEachFlip{iLoop,1} = Q1_.timeForEachFlip{iLoop} - [0; Q1_.timeForEachFlip{iLoop}(1:end-1)];
        else
            Q1_.delayForEachFlip{iLoop,1} = Q1_.timeForEachFlip{iLoop};
        end
        if length(Q1_.timeForEachDiffFlip{iLoop,1}) > 1
            Q1_.delayForEachDiffFlip{iLoop,1} = Q1_.timeForEachDiffFlip{iLoop} - [0; Q1_.timeForEachDiffFlip{iLoop}(1:end-1)];
        else
            Q1_.delayForEachDiffFlip{iLoop,1} = Q1_.timeForEachDiffFlip{iLoop};
        end
        Q1_.plotThisTrial(iLoop,1)       = 0;
        if Q1_.NDiffCardsFlipped(iLoop,1) >= 3 && T_.result(end) > -15 || (sum(Q1_.plotThisTrial) < 2 && trial == trials(end))
            Q1_.plotThisTrial(iLoop,1)   = 1;
        end
        Q1_.avgDelayForFlip{iLoop,1}     = mean(Q1_.delayForEachFlip{iLoop},'omitmissing');
        Q1_.avgDelayForDiffFlip{iLoop,1} = mean(Q1_.delayForEachDiffFlip{iLoop},'omitmissing');
    end
end
Q1all = struct2table(Q1_);
clearvars Q1_
Q1 = Q1all(ismember(Q1all.session,eegsessions),:);

%% And get the avg values per baby
iLoop = 0;
for session = eegsessions
    iLoop = iLoop +1;
    flip(iLoop).session          = session;
    flip(iLoop).nFamTr           = sum(Q1.session == session);
    flip(iLoop).iFamTr           = find((Q1.session == session & Q1.plotThisTrial == 1));
    flip(iLoop).delaysFlipToPlot = Q1.delayForEachFlip((Q1.session == session & Q1.plotThisTrial == 1));
    Q2_.session(iLoop,1)                = session;
    Q2_.nFamFTrials(iLoop,1)            = mean(Q1.nFamFTrials(Q1.session == session),'omitmissing');
    Q2_.avgDelayToFlip1stCard(iLoop,1)  = mean(cellfun(@(x) subsref([NaN; x(:)], struct('type', '()', 'subs', {{1 + ~isempty(x)}})), Q1.delayForEachFlip(Q1.session == session)),'omitmissing');
    Q2_.avgDelayToFlipAnyCards(iLoop,1) = mean(cellfun(@(x) subsref([NaN; x(:)],struct('type', '()', 'subs', {{1 + ~isempty(x)}})), Q1.avgDelayForFlip(Q1.session == session)),'omitmissing');
    Q2_.avgDelayToFlipDiffCards(iLoop,1) = mean(cellfun(@(x) subsref([NaN; x(:)],struct('type', '()', 'subs', {{1 + ~isempty(x)}})), Q1.avgDelayForDiffFlip(Q1.session == session)),'omitmissing');
    Q2_.avgNCardsFlipped(iLoop,1)       = mean(Q1.NCardsFlipped(Q1.session == session),'omitmissing');
    Q2_.avgNDiffCardsFlipped(iLoop,1)   = mean(Q1.NDiffCardsFlipped(Q1.session == session),'omitmissing');
    Q2_.totNCardsFlipped(iLoop,1)       = sum(Q1.NCardsFlipped(Q1.session == session));
    Q2_.totNDiffCardsFlipped(iLoop,1)   = sum(Q1.NDiffCardsFlipped(Q1.session == session));
    
    if ~isempty(flip(iLoop).iFamTr)
        Q2_.f1DelayToFlip1stCard(iLoop,1)  = mean(cellfun(@(x) subsref([NaN; x(:)],struct('type', '()', 'subs', {{1 + ~isempty(x)}})), Q1.delayForEachFlip(flip(iLoop).iFamTr(1))),'omitmissing');
        Q2_.f1DelayToFlipAnyCards(iLoop,1) = mean(cellfun(@(x) subsref([NaN; x(:)],struct('type', '()', 'subs', {{1 + ~isempty(x)}})), Q1.avgDelayForFlip(flip(iLoop).iFamTr(1))),'omitmissing');
        Q2_.f1DelayToFlipDiffCards(iLoop,1) = mean(cellfun(@(x) subsref([NaN; x(:)],struct('type', '()', 'subs', {{1 + ~isempty(x)}})), Q1.avgDelayForDiffFlip(flip(iLoop).iFamTr(1))),'omitmissing');
        Q2_.f1NCardsFlipped(iLoop,1)       = mean(Q1.NCardsFlipped(flip(iLoop).iFamTr(1)),'omitmissing');
        Q2_.f1NDiffCardsFlipped(iLoop,1)   = mean(Q1.NDiffCardsFlipped(flip(iLoop).iFamTr(1)),'omitmissing');
        Q2_.f1NCardsFlipped(iLoop,1)       = sum(Q1.NCardsFlipped(flip(iLoop).iFamTr(1)));
        Q2_.f1NDiffCardsFlipped(iLoop,1)   = sum(Q1.NDiffCardsFlipped(flip(iLoop).iFamTr(1)));
        if length(flip(iLoop).iFamTr) > 1
            Q2_.f2DelayToFlip1stCard(iLoop,1)  = mean(cellfun(@(x) subsref([NaN; x(:)],struct('type', '()', 'subs', {{1 + ~isempty(x)}})), Q1.delayForEachFlip(flip(iLoop).iFamTr(2))),'omitmissing');
            Q2_.f2DelayToFlipAnyCards(iLoop,1) = mean(cellfun(@(x) subsref([NaN; x(:)],struct('type', '()', 'subs', {{1 + ~isempty(x)}})), Q1.avgDelayForFlip(flip(iLoop).iFamTr(2))),'omitmissing');
            Q2_.f2DelayToFlipDiffCards(iLoop,1) = mean(cellfun(@(x) subsref([NaN; x(:)],struct('type', '()', 'subs', {{1 + ~isempty(x)}})), Q1.avgDelayForDiffFlip(flip(iLoop).iFamTr(2))),'omitmissing');
            Q2_.f2NCardsFlipped(iLoop,1)       = mean(Q1.NCardsFlipped(flip(iLoop).iFamTr(2)),'omitmissing');
            Q2_.f2NDiffCardsFlipped(iLoop,1)   = mean(Q1.NDiffCardsFlipped(flip(iLoop).iFamTr(2)),'omitmissing');
            Q2_.f2NCardsFlipped(iLoop,1)       = sum(Q1.NCardsFlipped(flip(iLoop).iFamTr(2)));
            Q2_.f2NDiffCardsFlipped(iLoop,1)   = sum(Q1.NDiffCardsFlipped(flip(iLoop).iFamTr(2)));
        else
            Q2_.f2DelayToFlip1stCard(iLoop,1)  = NaN;
            Q2_.f2DelayToFlipAnyCards(iLoop,1) = NaN;
            Q2_.f2DelayToFlipDiffCards(iLoop,1) = NaN;
            Q2_.f2NCardsFlipped(iLoop,1)       = NaN;
            Q2_.f2NDiffCardsFlipped(iLoop,1)   = NaN;
            Q2_.f2NCardsFlipped(iLoop,1)       = NaN;
            Q2_.f2NDiffCardsFlipped(iLoop,1)   = NaN;
        end
    else
        Q2_.f1DelayToFlip1stCard(iLoop,1)  = NaN;
        Q2_.f1DelayToFlipAnyCards(iLoop,1) = NaN;
        Q2_.f1DelayToFlipDiffCards(iLoop,1) = NaN;
        Q2_.f1NCardsFlipped(iLoop,1)       = NaN;
        Q2_.f1NDiffCardsFlipped(iLoop,1)   = NaN;
        Q2_.f1NCardsFlipped(iLoop,1)       = NaN;
        Q2_.f1NDiffCardsFlipped(iLoop,1)   = NaN;
        Q2_.f2DelayToFlip1stCard(iLoop,1)  = NaN;
        Q2_.f2DelayToFlipAnyCards(iLoop,1) = NaN;
        Q2_.f2DelayToFlipDiffCards(iLoop,1) = NaN;
        Q2_.f2NCardsFlipped(iLoop,1)       = NaN;
        Q2_.f2NDiffCardsFlipped(iLoop,1)   = NaN;
        Q2_.f2NCardsFlipped(iLoop,1)       = NaN;
        Q2_.f2NDiffCardsFlipped(iLoop,1)   = NaN;
    end
end

Q2 = struct2table(Q2_);
clearvars Q2_

sessions2 = categorical(ctrl_vars.session)';
Q3 = [ctrl_vars Q2(ismember(Q2.session,ctrl_vars.session),2:end)];

% writetable(Q1,sprintf("data/eyetracking/Visit%d/visit%d-FamF-EEG_AllTrials.csv",visitNo,visitNo));
% writetable([Q3 eegData(:,4:end)],sprintf("data/Final data/visit%d-FamF_PerBaby.csv",visitNo));


% NB: WOULD ALSO NEED TO GO TO TESTING LOG AND EXTRACT WHETHER PARENT WAS AKED TO POINT


%% Plot relevant variables as raincloud & scatter plots for R & NR
% Get subj names etc. [only using name? replace else with ~?]
[namesSubjAll,listSubjAll] = unique(Q3.session);
listSubjR   = find(strcmp(Q3.mirror,'R'));
namesSubjR  = Q3.session(listSubjR);
listSubjNR  = find(strcmp(Q3.mirror,'NR'));
namesSubjNR = Q3.session(listSubjNR);

colours = linspecer(length(sessions2));
lineW = 1;

xL = [.5 3.72];

% ----- nFam
data1 = Q3.nFamFTrials(listSubjR); data2 = Q3.nFamFTrials(listSubjNR);
fig = figure; fBoxplotWithDotsAndColors({data1,data2},labels={'R','NR'});%,x_lim=xL);
title(sprintf('Familiarisation trials'))
pos=get(gcf,"Position");
fig.Position = [pos(1) pos(2) pos(3)*.55 pos(4)];
saveas(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo), 'Figures final','nFam'),'png');
print(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo),'Figures final vectorised','fam_nFam'),'-dsvg');

% ----- nFlip
data1 = Q3.avgNCardsFlipped(listSubjR); data2 = Q3.avgNCardsFlipped(listSubjNR);
fig = figure; fBoxplotWithDotsAndColors({data1,data2},labels={'R','NR'});%,x_lim=xL);
title(sprintf('Cards flipped - any'))
pos=get(gcf,"Position");
fig.Position = [pos(1) pos(2) pos(3)*.55 pos(4)];
saveas(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo), 'Figures final','nFlipAny'),'png');
print(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo),'Figures final vectorised','fam_nFlipAny'),'-dsvg');

% ----- nFlipDiff
data1 = Q3.avgNDiffCardsFlipped(listSubjR); data2 = Q3.avgNDiffCardsFlipped(listSubjNR);
fig = figure; fBoxplotWithDotsAndColors({data1,data2},labels={'R','NR'});%,x_lim=xL);
title(sprintf('Cards flipped - different'))
pos=get(gcf,"Position");
fig.Position = [pos(1) pos(2) pos(3)*.55 pos(4)];
saveas(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo), 'Figures final','nFlipDiff'),'png');
print(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo),'Figures final vectorised','fam_nFlipDiff'),'-dsvg');

% ----- delayFlip
data1 = Q3.avgDelayToFlipAnyCards(listSubjR)/1000; data2 = Q3.avgDelayToFlipAnyCards(listSubjNR)/1000;
fig = figure; fBoxplotWithDotsAndColors({data1,data2},labels={'R','NR'});%,y_label={'(s)'});%,x_lim=xL);
title(sprintf('Flip delay - any (s)'))
pos=get(gcf,"Position");
fig.Position = [pos(1) pos(2) pos(3)*.55 pos(4)];
saveas(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo), 'Figures final','delayFlipAny'),'png');
print(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo),'Figures final vectorised','fam_delayFlipAny'),'-dsvg');

% ----- delayFlipDiff
data1 = Q3.avgDelayToFlipDiffCards(listSubjR)/1000; data2 = Q3.avgDelayToFlipDiffCards(listSubjNR)/1000;
fig = figure; fBoxplotWithDotsAndColors({data1,data2},labels={'R','NR'});%,y_label={'(s)'});%,x_lim=xL);
title(sprintf('Flip delay - different (s)'))
pos=get(gcf,"Position");
fig.Position = [pos(1) pos(2) pos(3)*.55 pos(4)];
saveas(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo), 'Figures final','delayFlipDiff'),'png');
print(fig,fullfile(pwd,'Figures',sprintf('Visit%d',visitNo),'Figures final vectorised','fam_delayFlipDiff'),'-dsvg');


% return;

%% Plot indiv stuff
fig = figure(1);
for iSession = 1:length(sessions2)
    session  = sessions2(iSession);
    tiledlayout("vertical")
    for iTrial = 1:size(flip(iSession).delaysFlipToPlot,1)
        nexttile
        plot(1:length(flip(iSession).delaysFlipToPlot{iTrial}), flip(iSession).delaysFlipToPlot{iTrial},'LineWidth',lineW);
        ylim([0 30000]);
        xL = get(gca, 'xlim');
        xticks(0:1:xL(2));
        ylabel("Time to flip any card")
        xlabel("Flip #")
        title(sprintf('%s (%s), FamF trial %d of %d',session,Q3.mirror{iSession},flip(iSession).iFamTr(iTrial),flip(iSession).nFamTr));
    end
    saveas(fig, fullfile('Figures',sprintf('Visit%d',visitNo),'Indiv','FamF trials',sprintf('%s_FamF.png',session)));
    pause(.1);
end

fig2 = figure(2);
tiledlayout("vertical")
for iTrial = 1:2
    nexttile
    hold on
    for iSession = 1:length(sessions2)
        session  = sessions2(iSession);
        if size(flip(iSession).delaysFlipToPlot,1) >= iTrial && strcmp(Q3.mirror{iSession},'R')
            plot(1:length(flip(iSession).delaysFlipToPlot{iTrial}), flip(iSession).delaysFlipToPlot{iTrial},'Color',colours(iSession,:),'LineWidth',lineW);
            ylim([0 30000]);
            xticks(0:1:30);
            ylabel("Time to flip any card")
            xlabel("Flip #")
        end
        title(sprintf('FamF %d trial - Rs',iTrial));
    end
end
saveas(fig2, fullfile('Figures',sprintf('Visit%d',visitNo),'Figures final','R_FamF.png'));

fig3 = figure(3);
tiledlayout("vertical")
for iTrial = 1:2
    nexttile
    hold on
    for iSession = 1:length(sessions2)
        session  = sessions2(iSession);
        if size(flip(iSession).delaysFlipToPlot,1) >= iTrial && strcmp(Q3.mirror{iSession},'NR')
            plot(1:length(flip(iSession).delaysFlipToPlot{iTrial}), flip(iSession).delaysFlipToPlot{iTrial},'Color',colours(iSession,:),'LineWidth',lineW);
            ylim([0 30000]);
            xticks(0:1:30);
            ylabel("Time to flip any card")
            xlabel("Flip #")
        end
        title(sprintf('FamF %d trial - NRs',iTrial));
    end
end
saveas(fig3, fullfile('Figures',sprintf('Visit%d',visitNo),'Figures final','NR_FamF.png'));
