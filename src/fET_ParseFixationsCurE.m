%% Parse the fixations for curE experiment based on the different periods in the trials...
% /!\ This uses parallel processing


function [fixParsing, T, Q] = fET_ParseFixationsCurE(nSessions, T, Q, opts)

arguments
    nSessions
    T
    Q
    opts.listPeriods = {'exploration','decision','feedback'};
end

%% Initialise tables first
% Initialise Q
Q = fET_InitQVars(Q);
% Slash the big tables Q & T into pieces for speed
%   (these can go to different cpu threads and in general save computation, 
%   even with 1 thread)
sessions = unique(T.session);
nSessions = size(sessions,1);
T_ = cell(nSessions,1);
Q_ = cell(nSessions,1);
for iSession = 1:nSessions
    T_{iSession} = T(T.session == sessions(iSession),:);
    Q_{iSession} = Q(Q.session == sessions(iSession),:);
end
% Initialise T
T_ = cellfun(@fET_InitTvars, T_, 'UniformOutput',false);
% Check if there are issues
assert(all(cellfun(@(T,Q)(~isempty(Q)) && T.session(1) == Q.session(1), T_,Q_)), "T and Q sessions do not align, have to adjust/investigate manually")
% Clean up workspace
clearvars T Q

%% Now parse
fixParsing = struct();
parfor iSession = 1:nSessions
    session = sessions(iSession);
    T = T_{iSession};
    Q = Q_{iSession};
    disp(session);
    for trial = unique(T.trial)'
        for period_in_trial = unique(T.period_in_trial(T.trial==trial))'
            I = T.trial == trial & T.period_in_trial == period_in_trial;
            currDataQ = Q.trial == trial & Q.period_in_trial == period_in_trial;
            % Save prior trial's difficulty and accuracy values
            if trial > 1
                iTrial = find(T.trial == trial-1, 1, 'first');
                if ~isempty(iTrial)
                    T.priorDiff(I) = T.difficulty(iTrial);
                    T.priorAccu(I) = T.accuracy(iTrial);
                end
            end
            % Add extras: prior values, duration of each period, inclusion
            Q.durStepMs(currDataQ) = sum(I*2);
            Q.priorDiff(currDataQ) = T.priorDiff(find(I,1,'first'));
            Q.priorAccu(currDataQ) = T.priorAccu(find(I,1,'first'));
            Q.inclTrial(currDataQ) = T.qualTrial(find(I,1,'first'));
            Q.sideChosen(currDataQ)= T.sideChosen(find(I,1,'first'));
            Q.sideMatch(currDataQ) = T.sideMatch(find(I,1,'first'));
            % Find fixations, saccades...
            gazeParsed = fET_InitGazeParsed;
            if T.qualTrial(find(I,1)) ~= "reject"
                if Q.priorDiff(currDataQ) ~= Q.difficulty(currDataQ)
                    % counting as chance either if prior trial is fam or is a different difficulty
                    Q.inclTrial(currDataQ) = "change in difficulty";
                elseif isnan(Q.priorAccu)
                    % Also note when prior trial does not have an accuracy value
                    % (NB: optout is marked as 127, correct as 1, incorrect
                    %  as 0 (NaN = somehow not even an opt-out, maybe was a
                    %  Fam, was terminated by experimenter...)
                    Q.inclTrial(currDataQ) = "no prior accuracy value";
                end
                x = T.X_clean(I);
                y = T.Y_clean(I);
                t = T.time(I);
                fixroi = T.fixroi(I);
                [flags,gazeParsed] = fET_FindFixationsSaccades(x,y,t,fixroi);
                gazeParsed.sideChosen = mode(T.sideChosen(I));
                gazeParsed.sideMatch  = mode(T.sideMatch(I));
                T.flagFix(I)         = flags.flagFix;
                T.flagFixNb(I)       = flags.flagFixNb;
                T.flagLook(I)        = flags.flagLook;
                T.flagLookNb(I)      = flags.flagLookNb;
                T.flagSwitchB(I)     = flags.flagSwitchB;
                T.flagSwitchBNb(I)   = flags.flagSwitchBNb;
                T.flagSwitchAll(I)   = flags.flagSwitchAll;
                T.flagSwitchAllNb(I) = flags.flagSwitchAllNb;

                % Add fix Nb
                Q.FixNb(currDataQ)      = gazeParsed.nFixations;
                Q.FixNbInL(currDataQ)   = sum(gazeParsed.fixGoodRoi == 1);
                Q.FixNbInR(currDataQ)   = sum(gazeParsed.fixGoodRoi == 2);
                Q.FixNbInT(currDataQ)   = sum(gazeParsed.fixGoodRoi == 3);
                Q.FixNbNoAOI(currDataQ) = sum(gazeParsed.fixGoodRoi == 0);
                % Also add total durations
                Q.FixTotDurInL(currDataQ)     = sum(fixroi==1 & flags.flagFix=="Fix")*2; % *2 for 1 sample every 2ms -- eventually make this depend on calculated SR
                Q.FixTotDurInR(currDataQ)     = sum(fixroi==2 & flags.flagFix=="Fix")*2;
                Q.FixTotDurInT(currDataQ)     = sum(fixroi==3 & flags.flagFix=="Fix")*2;
                Q.FixTotDurInNoAOI(currDataQ) = sum(fixroi==0 & flags.flagFix=="Fix")*2;

                % Add look Nb
                Q.LookNb(currDataQ)      = gazeParsed.nLooks;
                Q.LookNbInL(currDataQ)   = sum(gazeParsed.lookRoi == 1);
                Q.LookNbInR(currDataQ)   = sum(gazeParsed.lookRoi == 2);
                Q.LookNbInT(currDataQ)   = sum(gazeParsed.lookRoi == 3);
                Q.LookNbNoAOI(currDataQ) = sum(gazeParsed.lookRoi == 0);
                % Also add total durations
                Q.LookTotDurInL(currDataQ) = sum(fixroi==1 & flags.flagLook=="Look")*2; % *2 for 1 sample every 2ms -- eventually make this depend on calculated SR
                Q.LookTotDurInR(currDataQ) = sum(fixroi==2 & flags.flagLook=="Look")*2;
                Q.LookTotDurInT(currDataQ) = sum(fixroi==3 & flags.flagLook=="Look")*2;

                % Now add switches
                Q.NbSwitchesB(currDataQ)   = gazeParsed.nSwitchesB;
                Q.NbSwitchesAll(currDataQ) = gazeParsed.nSwitchesAll;
            else


            end

            % fig1 = fPlotFixationTraces(x,y,t,gazeParsed);
            % title(sprintf('%s, trial %02d, %s - gaze traces',session,trial,period_in_trial));
            % saveas(fig1, [folderIndivFigs,filesep,sprintf('x-y traces %s',period_in_trial),filesep,sprintf('%s_Trial%02d.png',session,trial)]);
            % close fig1;

            period = find(period_in_trial==opts.listPeriods);
            fixParsing(iSession).gazeParsed(trial,period) = gazeParsed;
        end
    end
    T_{iSession} = T;
    Q_{iSession} = Q;
end

%% Done, glue the pieces back and save
T = cat(1, T_{:});
Q = cat(1, Q_{:});

end