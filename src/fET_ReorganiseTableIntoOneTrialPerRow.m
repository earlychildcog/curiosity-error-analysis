%% Reorganise table so that there is one value per trial
% Also add some extra things


function R = fET_ReorganiseTableIntoOneTrialPerRow(Q)

Qraw = Q;
Q.period_in_trial = categorical(Q.period_in_trial);
Q.session = categorical(Q.session);
sessions = unique(Q.session)';
% Reorganise data so that we have one value per trial
nRowsTable = size(Q,1);
% Create a "quality" table - initialise vars for speed here with defaults
% values for missing trials/periods
R = table(repmat("", nRowsTable, 1),'VariableNames',{'session'});
R.trial = nan(nRowsTable,1); R.stepReached = nan(nRowsTable,1);
R.sideChosen(nRowsTable,1) = "";  R.sideMatch(nRowsTable,1) = "";
R.accuracy = nan(nRowsTable,1);   R.priorAccu = nan(nRowsTable,1);
R.difficulty(nRowsTable,1)  = ""; R.diff_binary(nRowsTable,1) = "";
R.priorDiff(nRowsTable,1)   = ""; R.diffStayedSame = nan(nRowsTable,1);
newStrings = {'qualityL', 'qualityR', 'incl'};
newNaNs    = {'dur', 'nFixB', 'nFixAll', 'nSwitchesB', 'nSwitchesAll'};
expNaNs    = {'diff_fixAndeegTrig' 'dur_TrigFix', 'nFixAnywhere_AfterTrigFix', 'nSwitchesB_AfterTrigFix', 'nSwitchesAll_AfterTrigFix'};
for period = unique(Q.period_in_trial)'
    per = char(period);
    per(5:end) = []; % get suffix
    R = addvars(R, repmat("", height(R), 1), repmat("", height(R), 1), repmat("", height(R), 1), ...
        'NewVariableNames', strcat(newStrings,['_',per]));
    R = addvars(R, nan(height(R),1), nan(height(R), 1), nan(height(R), 1),...
        nan(height(R), 1), nan(height(R), 1), ...
        'NewVariableNames', strcat(newNaNs,['_',per]));
    if period == "decision"
        R = addvars(R, nan(height(R),1), nan(height(R), 1), nan(height(R), 1),...
            nan(height(R), 1), nan(height(R), 1), ...
            'NewVariableNames', strcat(expNaNs,['_',per]));
    end
end
% Now create the table and save relevant data only
iRow = 0;
for session = sessions
    nTrials = max(Q.trial(Q.session == session));
    for trial = 1:max(nTrials)
        iRow = iRow + 1;
        R.session(iRow) = session;
        R.trial(iRow)   = trial;
        if sum(Q.session == session & Q.trial == trial) ~= 0
            I = Q(Q.session == session & Q.trial == trial,:);
            % Add variables for all periods
            R.stepReached(iRow) = I.step_reached(1);
            R.sideChosen(iRow)  = I.sideChosen(1);
            R.sideMatch(iRow)   = I.sideMatch(1);
            R.accuracy(iRow)    = I.accuracy(1);
            R.priorAccu(iRow)   = I.priorAccu(1);
            R.difficulty(iRow)  = I.difficulty(1);
            R.diff_binary(iRow) = I.difficulty(1);
            if I.difficulty(1) ~= "Easy"
                R.diff_binary(iRow) = "Harder";
            end
            R.priorDiff(iRow)      = I.priorDiff(1);
            R.diffStayedSame(iRow) = R.priorDiff(iRow) == R.difficulty(iRow);
            % Add variables per period
            for period = unique(I.period_in_trial)'
                per = char(period);
                per(5:end) = []; % get suffix
                R{iRow,strcmp(R.Properties.VariableNames,['qualityL','_',per])}     = I.qualityL(I.period_in_trial == period);
                R{iRow,strcmp(R.Properties.VariableNames,['qualityR','_',per])}     = I.qualityR(I.period_in_trial == period);
                R{iRow,strcmp(R.Properties.VariableNames,['incl','_',per])}         = I.inclTrial(I.period_in_trial == period);
                R{iRow,strcmp(R.Properties.VariableNames,['dur','_',per])}          = I.durStepMs(I.period_in_trial == period);
                R{iRow,strcmp(R.Properties.VariableNames,['nFixB','_',per])}        = I.FixNbInL(I.period_in_trial == period) + I.FixNbInR(I.period_in_trial == period);
                R{iRow,strcmp(R.Properties.VariableNames,['nFixAll','_',per])}      = I.FixNbInL(I.period_in_trial == period) + I.FixNbInR(I.period_in_trial == period) + I.FixNbInT(I.period_in_trial == period);
                R{iRow,strcmp(R.Properties.VariableNames,['nSwitchesB','_',per])}   = I.NbSwitchesB(I.period_in_trial == period);
                R{iRow,strcmp(R.Properties.VariableNames,['nSwitchesAll','_',per])} = I.NbSwitchesAll(I.period_in_trial == period);
                if period == "decision" && R.stepReached(iRow)== 3
                    R{iRow,strcmp(R.Properties.VariableNames,['diff_fixAndeegTrig','_',per])}  = I.durTriggeringFix(I.period_in_trial == period);
                    R{iRow,strcmp(R.Properties.VariableNames,['dur_TrigFix','_',per])}         = I.durTriggeringFix(I.period_in_trial == period);
                    R{iRow,strcmp(R.Properties.VariableNames,['nFixAnywhere_AfterTrigFix','_',per])}  = I.NbFix_AfterTriggeringFix(I.period_in_trial == period);
                    R{iRow,strcmp(R.Properties.VariableNames,['nSwitchesB_AfterTrigFix','_',per])}    = I.NbSwitchB_AfterTriggeringFix(I.period_in_trial == period);
                    R{iRow,strcmp(R.Properties.VariableNames,['nSwitchesAll_AfterTrigFix','_',per])}  = I.NbSwitchAll_AfterTriggeringFix(I.period_in_trial == period);
                end
            end
        end
    end
end
% Was easier to create extra empty rows to start with -> deleting them now
R(iRow+1:end,:) = [];
% Add vars:
% - trialType ('test'/'' -> rest should be Fam)
% - testTrialNb (for visit 1, max = 58; >50 because of opt outs recycling)
% - trialOptInOut: optIn, optOut, Fam
% - trialDataQual
% Create empty string var to input into table for new vars
emptyStrVar = cell(length(R.session),1); emptyStrVar(:) = {''};
% Create trialType varRT = addvars(T,emptyStrVar,'After',"trial",'NewVariableNames',"trialType");
R.trialType(~isnan(R.stepReached)) = {'Test'};
R.trialType(isnan(R.stepReached))  = {'Fam'};
% Create trialOptInOut var
R = addvars(R,emptyStrVar,'After',"trialType",'NewVariableNames',"trialOptInOut");
R.trialOptInOut(ismissing(R.trialType)) = {'Fam'};
R.trialOptInOut(strcmp(R.trialType,'Test') & R.stepReached~=3) = {'OptOut'};
R.trialOptInOut(strcmp(R.trialType,'Test') & R.stepReached==3) = {'OptIn'};
% Create trialDataQual var
R = addvars(R,R.trialOptInOut,'After',"trialOptInOut",'NewVariableNames',"trialDataQual");
R.trialDataQual(strcmp(R.trialType,'Test') & R.stepReached==3 & (~strcmp(R.incl_expl,'include') | ~strcmp(R.incl_deci,'include'))) = {'OptInBad'};
R.trialDataQual(strcmp(R.trialType,'Test') & R.stepReached==3 & strcmp(R.incl_expl,'include') & strcmp(R.incl_deci,'include')) = {'OptInClean'};
% Create testTrialNb var
R = addvars(R,R.trial,'After',"trial",'NewVariableNames',"testTrialNb");
R.testTrialNb(:) = NaN;
for session = sessions
    iTest = strcmp(R.session,session) & strcmp(R.trialType,'Test');
    R.testTrialNb(iTest) = 1:sum(iTest);
end
R.session = categorical(R.session);

end