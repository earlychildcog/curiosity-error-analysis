% HOW TO USE THIS SCRIPT
%
% Always run this for ERN first (needed to calculate baseline), then FRN
%
% Make sure to run the first 2(3) scripts first, and to edit the main
% parameters defined in the first lines of the code to select the
% appropriate data.
%
% This script is used for analysing several datasets -- if you want to edit
% it, make sure it remains compatible with the other datasets, and
% important parameters are defined at the top.
%
% Example:
% if visit == 1 && flagCommon
%     dirDataMatIn = dirDataMatIn + "Common";
% end
% if both ERN and FRN data has been cleaned for this visit, use the trials
% common to both; ERN datasets without FRN can still be analysed with
% flagCommon set to false; FRN can't be analysed without ERN (baseline is
% taken from ERN).
%
% You can also add new flags but MAKE SURE THEY ARE DEFINED AT THE TOP OF
% THE SCRIPT so people know to edit it before running another analysis (very
% important, else we always run into bugs after evry small edits. E.g., if
% you want to add a section for a time-freqeuncy analysis, make sure its
% parametersare defined at the top, and the flag for whether to conduct
% that analysis or not is at the top as well (example: flagCommon).
%

clear all
close all

%% DEFINE THE MAIN PARAMETERS -- check that this is what you want
visit                = 1;      % Which visit? (12m/a = 1; 18m/b = 2; 24m/c = 3)
erptype              = 'ERN';  % Which type of ERP? ('ERN' or 'FRN')      /!\ always start with ERN before FRN (need it to calculate BL values)
flagCommon           = 1;      % if both ern and frn data has been cleaned for this visit, use the trials common to both datasets

%% Define and load more things -- no need to change in theory
% -- Electrodes of interest
% We're using this to calculate the ERPs
channelsROI = [4,5,10,11,12,16,18,19];     % FC elec (Goupil)
% channelsROI = [71,72,75,76, 67,74,77,82]; % Occ elec (can be used for data quality checks)

% -- Time windows for the analysis
% We're using this to plot topographies + extract peak values for stats csv
% file (needs 2 time windows, else adapt the script for more flexibility)
% These were identified by the time cluster analysis (done at the end)
if strcmp(erptype,'ERN')
    timeWin = [0.0330    0.1720;     0.3320    0.5470];
elseif strcmp(erptype,'FRN')
    timeWin = [0.0460    0.2980;     0.4570    0.9300];
end
% -- Baseline window
% We always use the ERN window for this: FRN loads the values calculated
% from ERN -> always run ERN before FRN
BL  = [-0.298 -.150];

% -- Other things
visitLetterList = {'a','b','c'}; visitLetter = visitLetterList{visit};
difficulties    = {"Easy", "Medium", "Hard", "xHard","Harder"};

% -- Data folders
% In theory, no need to edit this -- keep the same structure and modify
% your local folder tree for compatibility
pathDataRoot   = fullfile('Users',getenv('USER'),'Data','curE');
pathData       = [filesep, fullfile(pathDataRoot,sprintf('Visit%d', visit), erptype)];
pathDataERN    = [filesep, fullfile(pathDataRoot,sprintf('Visit%d', visit), 'ERN')];
dirDataMatIn   = "2_matIncluded"; % Note: next lines edit it to 'common' if needed
dirDataMatOut1 = "3_ERPs";
dirDataMatOut2 = "3_ERPs_AllSubjInOneFile";
dirDataMatOut3 = "4_OutputsForStats";
dirDataMatOut4 = "5_WholeTimelineForRef";
if flagCommon
    dirDataMatIn = dirDataMatIn + "Common";
end
util.fMkDirSafe(fullfile(pathData, dirDataMatOut1));
util.fMkDirSafe(fullfile(pathData, dirDataMatOut2));
util.fMkDirSafe(fullfile(pathData, dirDataMatOut3));
util.fMkDirSafe(fullfile(pathData, dirDataMatOut4));
if strcmp(erptype,'FRN') & ~isnan(BL(1))
    load(fullfile(pathDataERN, dirDataMatOut2,sprintf("BL_valuesFromERN_%d_%d.mat",BL(1)*1000,BL(2)*1000)));
end
tblGroups   = readtable([filesep, fullfile(pathDataRoot,'curio_groups.csv')]);
filenames_  = string({dir(fullfile(pathData, dirDataMatIn, "*.mat")).name});

% Set things up
addpath("src")
fSetUpFieldtripAndParallelPool(flagParallel=false,flagFT=true)

%% Load data per subject, compute ERPs, save data
for iFile = numel(filenames_):-1:1
    filename = filenames_(iFile);
    subjNum  = str2double(regexp(filename, ['cur\w(\d\d\d)',visitLetter,'_'],'tokens','once'));
    load(fullfile(pathData, dirDataMatIn, filename));
    % Add info about difficulty level and subjID
    data.trialinfo.diff = tblMetadata.mffkey_diff;
    data.subjID         = tblMetadata.id(1);

    % Baseline (if FRN: use the ERN window -> need to run the ERN first)
    if  ~isnan(BL(1))
        if strcmp(erptype,'ERN')
            % Figure out baseline values for FRN (saved at the end)
            BL_idx = [find(data.time{1,1} == BL(1)), find(data.time{1,1} == BL(2))];
            allSubj_avgBLperiod{iFile} = cell2mat(cellfun(@(x) mean(x(:,BL_idx(1):BL_idx(2)),2), data.trial, 'UniformOutput', false));
            cfg                 = struct;
            cfg.demean          = 'yes';
            cfg.baselinewindow  = BL;
            dataBLned           = ft_preprocessing(cfg,data);
        elseif strcmp(erptype,'FRN')
            dataBLned       = data;
            tempBL          = cellfun(@(x, y) x - y, data.trial, num2cell(allSubj_avgBLperiod{iFile}, 1), 'UniformOutput', false);
            dataBLned.trial = tempBL;
        end
    else
        dataBLned = data; % skip BLine
    end

    % Compute within participant averages per condition (whole scalp)
    cfg                  = []; % correct
    cfg.trials           = dataBLned.trialinfo.accu==1;
    corrTrials           = ft_selectdata(cfg, dataBLned);
    correct              = ft_timelockanalysis(cfg, dataBLned);
    cfg                  = []; % incorrect
    cfg.trials           = dataBLned.trialinfo.accu==0;
    incorrTrials         = ft_selectdata(cfg, dataBLned);
    incorrect            = ft_timelockanalysis(cfg, dataBLned);
    cfg                 = []; % difference
    cfg.operation       = 'subtract';
    cfg.parameter       = 'avg';
    difference          = ft_math(cfg, correct, incorrect);
    % cfg             = []; % Optional: plot over whole scalp
    % cfg.interactive = 'yes';
    % cfg.showoutline = 'yes';
    % ft_multiplotER(cfg, correct, incorrect)
    % ft_multiplotER(cfg, difference)

    % Same per difficulty level AND per condition
    byDiff = struct;
    byDiff.difficulties = difficulties; % keep a trace of how we ordered the difficulty levels
    for iDiff = 1:5
        if iDiff==5
            selectTrialsCorr   = dataBLned.trialinfo.accu==1 & dataBLned.trialinfo.diff~="Easy";
            selectTrialsIncorr = dataBLned.trialinfo.accu==0 & dataBLned.trialinfo.diff~="Easy";
        else
            selectTrialsCorr   = dataBLned.trialinfo.accu==1 & dataBLned.trialinfo.diff==difficulties{iDiff};
            selectTrialsIncorr = dataBLned.trialinfo.accu==0 & dataBLned.trialinfo.diff==difficulties{iDiff};
        end
        byDiff.NtrialsCorr(iDiff)   = sum(selectTrialsCorr);
        byDiff.NtrialsIncorr(iDiff) = sum(selectTrialsIncorr);
        if byDiff.NtrialsCorr(iDiff) >= 3 && byDiff.NtrialsIncorr(iDiff) >= 3
            % Compute within participant averages
            cfg                      = []; % correct
            cfg.trials               = selectTrialsCorr;
            diffCorrTrials               = ft_selectdata(cfg, dataBLned);
            byDiff.correct(iDiff)    = ft_timelockanalysis(cfg, dataBLned);
            cfg                      = []; % incorrect
            cfg.trials               = selectTrialsIncorr;
            diffIncorrTrials         = ft_selectdata(cfg, dataBLned);
            byDiff.incorrect(iDiff)  = ft_timelockanalysis(cfg, dataBLned);
            cfg                      = []; % difference
            cfg.operation            = 'subtract';
            cfg.parameter            = 'avg';
            byDiff.difference(iDiff) = ft_math(cfg, byDiff.correct(iDiff), byDiff.incorrect(iDiff));
        else
            byDiff.correct(iDiff+1)    = correct;    byDiff.correct(iDiff+1)    = [];
            byDiff.incorrect(iDiff+1)  = incorrect;  byDiff.incorrect(iDiff+1)  = [];
            byDiff.difference(iDiff+1) = difference; byDiff.difference(iDiff+1) = [];
        end
    end

    % Save avg values per subject in Fieldtrip mat file + other variables
    filenameERP = strsplit(filename,'.mat');
    if length(filenameERP) > 1
        filenameERP(2:end)=[];
    end
    filenameERP=append(filenameERP, "_ERPsCorrIncorr.mat");
    if ~strcmp(getenv('USER'), 'dim-ask')
        save(fullfile(pathData,dirDataMatOut1,filenameERP),"correct","incorrect","difference")
    end

    % Figure out groups
    subjID(iFile,1) = tblMetadata.id(1);
    groups(iFile,1) = subjID(iFile);
    groups(iFile,2) = tblGroups.mirror{tblGroups.subjNb == double(subjID(iFile))};
    if isempty(tblGroups.mirror{tblGroups.subjNb == double(subjID(iFile))})
        groups(iFile,3) = NaN;
    else
        groups(iFile,3) = strcmp(tblGroups.mirror{tblGroups.subjNb == double(subjID(iFile))}, 'R');
    end

    % Also save in a big structure with all the subjects at once for
    % plotting
    Correct_allSubj{1,iFile}    = correct;
    Incorrect_allSubj{1,iFile}  = incorrect;
    Difference_allSubj{1,iFile} = difference;
    for iDiff = 1:5
        byDiff_allSubj.correct{iDiff,iFile}    = byDiff.correct(iDiff);
        byDiff_allSubj.incorrect{iDiff,iFile}  = byDiff.incorrect(iDiff);
        byDiff_allSubj.difference{iDiff,iFile} = byDiff.difference(iDiff);
        byDiff_allSubj.NtrialsCorr{iDiff,iFile}   = byDiff.NtrialsCorr(iDiff);
        byDiff_allSubj.NtrialsIncorr{iDiff,iFile} = byDiff.NtrialsIncorr(iDiff);
    end

    % Export per trial data for the channels OI (optional -- for plotting indiv ERPs)
    Correct_allSubj_allTrials{1,iFile}    = cell2mat(cellfun(@(x) mean(x(channelsROI, :), 1)', corrTrials.trial, 'UniformOutput', false))';
    Incorrect_allSubj_allTrials{1,iFile}  = cell2mat(cellfun(@(x) mean(x(channelsROI, :), 1)', incorrTrials.trial, 'UniformOutput', false))';
end

groups = array2table(groups,'VariableNames',{'subj','mirror','mirrorLogical'});

%% Now compute grand averages (needed for topoplots)
cfg = [];
[grandAvg.correct]    = ft_timelockgrandaverage(cfg, Correct_allSubj{:});
[grandAvg.incorrect]  = ft_timelockgrandaverage(cfg, Incorrect_allSubj{:});
[grandAvg.difference] = ft_timelockgrandaverage(cfg, Difference_allSubj{:});
subjList = find(strcmp(groups.mirror,"R"));
[grandAvg.correct_R]    = ft_timelockgrandaverage(cfg, Correct_allSubj{1,subjList});
[grandAvg.incorrect_R]  = ft_timelockgrandaverage(cfg, Incorrect_allSubj{1,subjList});
[grandAvg.difference_R] = ft_timelockgrandaverage(cfg, Difference_allSubj{1,subjList});
subjList = find(strcmp(groups.mirror,"NR"));
[grandAvg.correct_NR]    = ft_timelockgrandaverage(cfg, Correct_allSubj{1,subjList});
[grandAvg.incorrect_NR]  = ft_timelockgrandaverage(cfg, Incorrect_allSubj{1,subjList});
[grandAvg.difference_NR] = ft_timelockgrandaverage(cfg, Difference_allSubj{1,subjList});

%% Extract some data for stats
time = round(Correct_allSubj{1,1}.time,3);
% Make a matrix with each participant's ERP values
correct_perSubj    = cell2mat(cellfun(@(x) mean(x.avg(channelsROI, :), 1)', Correct_allSubj, 'UniformOutput', false))';
incorrect_perSubj  = cell2mat(cellfun(@(x) mean(x.avg(channelsROI, :), 1)', Incorrect_allSubj, 'UniformOutput', false))';
difference_perSubj = correct_perSubj - incorrect_perSubj; % could also take the grand average but there are small rounding differences
% Same per diff
for iDiff = 5:-1:1
    % Pre-allocate (so empty datasets with too few trials are NaNs and not zeros)
    byDiff_perSubj.correct_perSubj{iDiff} = nan(size(correct_perSubj)); byDiff_perSubj.incorrect_perSubj{iDiff} = nan(size(incorrect_perSubj));
    corr = byDiff_allSubj.correct(iDiff,:); incorr = byDiff_allSubj.incorrect(iDiff,:);
    idxHasData = cellfun(@(x) ~isempty(x.avg) && size(x.avg, 1) >= max(channelsROI), corr);
    byDiff_perSubj.correct_perSubj{iDiff}(idxHasData,:) = cell2mat(cellfun(@(x) mean(x.avg(channelsROI, :), 1)', corr(idxHasData), 'UniformOutput', false))';
    idxHasData = cellfun(@(x) ~isempty(x.avg) && size(x.avg, 1) >= max(channelsROI), incorr);
    byDiff_perSubj.incorrect_perSubj{iDiff}(idxHasData,:) = cell2mat(cellfun(@(x) mean(x.avg(channelsROI, :), 1)', incorr(idxHasData), 'UniformOutput', false))';
    byDiff_perSubj.difference_perSubj{iDiff}  = byDiff_perSubj.correct_perSubj{iDiff}  - byDiff_perSubj.incorrect_perSubj{iDiff} ; % could also take the grand average but there are small rounding differences
end

%% Make tables for stats
% Correct
ERP_perSubj(:,1) = min(correct_perSubj(:,find(time>=timeWin(1,1),1,'first'):find(time<=timeWin(1,2),1,'last')),[],2);
ERP_perSubj(:,2) = min(correct_perSubj(:,find(time>=timeWin(2,1),1,'first'):find(time<=timeWin(2,2),1,'last')),[],2);
% Incorrect
ERP_perSubj(:,3) = min(incorrect_perSubj(:,find(time>=timeWin(1,1),1,'first'):find(time<=timeWin(1,2),1,'last')),[],2);
ERP_perSubj(:,4) = min(incorrect_perSubj(:,find(time>=timeWin(2,1),1,'first'):find(time<=timeWin(2,2),1,'last')),[],2);
% Diff
ERP_perSubj(:,5)  = ERP_perSubj(:,1) - ERP_perSubj(:,3);
ERP_perSubj(:,6) = ERP_perSubj(:,2) - ERP_perSubj(:,4);

% Export into tables used for computing stats in JASP
rowNames = cellfun(@(x) ['curE' x 'a'], subjID, 'UniformOutput', false);
colNames = cellfun(@(x) sprintf('%dms', x), num2cell(time*1000), 'UniformOutput', false);
correct_perSubjT    = [array2table(groups.mirror), ...
    array2table(correct_perSubj, 'RowNames', rowNames, 'VariableNames', colNames)];
incorrect_perSubjT  = [array2table(groups.mirror), ...
    array2table(incorrect_perSubj, 'RowNames', rowNames, 'VariableNames', colNames)];
difference_perSubjT = [array2table(groups.mirror), ...
    array2table(difference_perSubj, 'RowNames', rowNames, 'VariableNames', colNames)];
ERP_perSubjT        = [array2table(groups.mirror), ...
    array2table(ERP_perSubj, 'RowNames', rowNames, 'VariableNames', ...
    {sprintf('Corr_min%dto%dms',timeWin(1,1)*1000,timeWin(1,2)*1000),...
    sprintf('Corr_min%dto%dms',timeWin(2,1)*1000,timeWin(2,2)*1000), ...
    sprintf('Incorr_min%dto%dms',timeWin(1,1)*1000,timeWin(1,2)*1000),...
    sprintf('Incorr_min%dto%dms',timeWin(2,1)*1000,timeWin(2,2)*1000),...
    sprintf('Diff_min%dto%dms',timeWin(1,1)*1000,timeWin(1,2)*1000),...
    sprintf('Diff_min%dto%dms',timeWin(2,1)*1000,timeWin(2,2)*1000)})];

%% Save csv files for JASP stats
writetable(correct_perSubjT, fullfile(pathData, dirDataMatOut4, ...
    sprintf('correct_%s_ValuesinROI_PerSubjEachTimePoint_BL%d_%d.csv', erptype, BL(1)*1000,BL(2)*1000)), 'WriteRowNames', true);
writetable(incorrect_perSubjT, fullfile(pathData, dirDataMatOut4, ...
    sprintf('incorrect_%s_ValuesinROI_PerSubjEachTimePoint_BL%d_%d.csv', erptype, BL(1)*1000,BL(2)*1000)), 'WriteRowNames', true);
writetable(difference_perSubjT, fullfile(pathData, dirDataMatOut4, ...
    sprintf('difference_%s_ValuesinROI_PerSubjEachTimePoint_BL%d_%d.csv', erptype, BL(1)*1000,BL(2)*1000)), 'WriteRowNames', true);
writetable(ERP_perSubjT,fullfile(pathData, dirDataMatOut3, ...
    sprintf('%s_ValuesinROI_PerSubj_minTwoPeaks_BL%d_%d.csv', erptype, BL(1)*1000,BL(2)*1000)), 'WriteRowNames', true);
if strcmp(erptype,'FRN') % Combine ERN & FRN into the same table if available
    ERN_perSubj = readtable(fullfile(pathDataERN, dirDataMatOut3, ...
        sprintf('ERN_ValuesinROI_PerSubj_minTwoPeaks_BL%d_%d.csv', BL(1)*1000, BL(2)*1000)));
    ERN_perSubj = renamevars(ERN_perSubj, ERN_perSubj.Properties.VariableNames, cellfun(@(x) ['ERN_' x], ERN_perSubj.Properties.VariableNames, 'UniformOutput', false));
    FRN_perSubj = renamevars(ERP_perSubjT, ERP_perSubjT.Properties.VariableNames, cellfun(@(x) ['FRN_' x], ERP_perSubjT.Properties.VariableNames, 'UniformOutput', false));
    writetable([ERP_perSubjT(:,1:2),ERN_perSubj(:,4:end), FRN_perSubj(:,3:end)], fullfile(pathData, dirDataMatOut3, ...
        sprintf('bothERNandFRN_ValuesinROI_PerSubj_minTwoPeaks_BL%d_%d.csv', BL(1)*1000,BL(2)*1000)), 'WriteRowNames', true);
elseif ~isnan(BL(1)) % Also save BL values (ONLY FOR ERN) so they can be used for FRN BL
    save(fullfile(pathData, dirDataMatOut2, sprintf('BL_valuesFromERN_%d_%d.mat', BL(1)*1000,BL(2)*1000)), 'allSubj_avgBLperiod');
end
save(fullfile(pathData, dirDataMatOut2, sprintf('allSubj_AllTrials_%s.mat', erptype)), "Correct_allSubj_allTrials", "Incorrect_allSubj_allTrials", '-v7.3');
save(fullfile(pathData, dirDataMatOut2, sprintf('grandAvg_%s.mat', erptype)), "grandAvg");
save(fullfile(pathData, dirDataMatOut2, sprintf('CorrIncorrDiff_PerSubj_%s.mat', erptype)), "correct_perSubj", "incorrect_perSubj", "difference_perSubj");
save(fullfile(pathData, dirDataMatOut2, sprintf('CorrIncorrDiff_FT_PerSubj_%s.mat', erptype)), "Correct_allSubj", "Incorrect_allSubj", "Difference_allSubj");
save(fullfile(pathData, dirDataMatOut2, sprintf('ByDiff_FT_AllSubj_%s.mat', erptype)), "byDiff_allSubj",'-v7.3');
save(fullfile(pathData, dirDataMatOut2, sprintf('ByDiff_FT_PerSubj_%s.mat', erptype)), "byDiff_perSubj");
save(fullfile(pathData, dirDataMatOut2, 'groups.mat'), "groups");

