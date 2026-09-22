%% Select included data based on manual rejection in EGI
%
% /!\ Always set up the flags at the top of script before running:
%   - erptype: whether we're looking at the ERN or the FRN segments
%   - visit: whether we're looking at visit 1, 2 or 3
%   - flagParallel: whether we're using parallel processing for speed;
%   requires Matlab's parallel processing toolbox installed.
%   - flagFT: whether we start up FieldTrip or not (if you have already
%   done that elsewhere e.g., by running the 1st script in the same Matlab
%   session, then set to false; else, set to True.
%   - min_N_trials_per_condition: how many good trials are required for the
%   participant to be included through the automatised participant
%   rejection (note you can also exclude participants using a csv file, see
%   step 3).
%
% If you already have run this script for the current visit and erptype
% and have data saved in your folder, this script will prompt you to
% confirm whether you want to proceed and overwrite the files (y), stop the
% process (q), save the new data in new files in the same folder as the old
% ones (n -- not recommended, several files for the same participant will
% coexist).
%
 

%% Define important stuff
erpType      = "ERN";
visit        = 1;
flagParallel = false; % here we didn't parallelise anyway
flagFT       = true;
min_N_trials_per_condition = 6;


%% Define more stuff
addpath("src")
fSetUpFieldtripAndParallelPool(flagParallel=flagParallel,flagFT=flagFT)
pathVisit      = fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d', visit));
pathData       = filesep + fullfile(pathVisit, erpType);
dirDataMatIn   = "1_matFiles";
dirDataInclOut = "2_matIncluded";
util.fMkDirSafe(fullfile(pathData, dirDataInclOut)); % make the folder, or prompt to empty the folder if files are detected in
% fSetUpFieldtrip

matnames       = string({dir(fullfile(pathData, dirDataMatIn, "*.mat")).name});
nSubj          = numel(matnames);
dataAll        = cell(nSubj, 1);
tblMetadataAll = cell(nSubj, 1);
visit_char     = char('a' + visit - 1);


%% 1. Select trials flagged as good (from manual cleaning in EGI)
for iSubj = 1:numel(matnames)
    thisMatIn = matnames(iSubj);
    load(fullfile(pathData, dirDataMatIn, thisMatIn), 'data', 'tblMetadata')
    idxInclTrials = tblMetadata.status == "unedited";       % these are the good trials
    cfg=[];
    cfg.trials = idxInclTrials;
    dataAll{iSubj} = ft_selectdata(cfg, data);
    tblMetadataAll{iSubj} = tblMetadata(idxInclTrials, :);
end
dataAll = cat(1, dataAll{:});
tblMetadataAll = cat(1, tblMetadataAll{:});


%% 2. Select participants based on min. number of trials per condition (accuracy)
tblIncl = varfun(@sum, tblMetadataAll, GroupingVariables="id", InputVariables="mffkey_accu");
tblIncl.Properties.VariableNames(2:3) = ["N_total" "N_correct"];
tblIncl.N_incorrect = tblIncl.N_total - tblIncl.N_correct;
tblIncl.inclMinTrials = tblIncl.N_incorrect >= min_N_trials_per_condition & tblIncl.N_correct >= min_N_trials_per_condition;


%% 3. OPTIONAL: select participants included in manual cleaning based on csv file
table_path = filesep + fullfile(pathVisit,sprintf("curE%c_EEGInclusion.csv", visit_char));
if isfile(table_path)
    tblInclMan = readtable(table_path, TextType="string");
    tblInclMan.id         = extractBetween(tblInclMan.subjID, "curE", visit_char);
    tblInclMan.inclManual = tblInclMan.Decision == "Include";
    tblIncl = innerjoin(tblIncl, tblInclMan(:, ["id" "inclManual"]));
    assert(size(tblIncl,1) == nSubj, "subject missing from manual inclusion table");
    % look for disrepancies
    if any(tblIncl.inclMinTrials ~= tblIncl.inclManual)
        dictDisrepancy = dictionary('0',sprintf('excluded (by both EGI manual & Matlab auto. [min. %d trials] rejection)', min_N_trials_per_condition),...
            '1',sprintf('included (by Matlab auto. [min. %d trials] but not EGI manual rejection)', min_N_trials_per_condition),...
            '2',sprintf('included (EGI manual but not Matlab auto. [min. %d trials] rejection)', min_N_trials_per_condition),...
            '3',sprintf('included (by both EGI manual & Matlab auto. [min. %d trials] rejection)', min_N_trials_per_condition));
        tblIncl.disrepancy = dictDisrepancy(tblIncl.inclMinTrials + 2*tblIncl.inclManual);
        warning("discrepency between EGI manual & Matlab auto. inclusions in %d subjects (manual rejection takes precedence):", sum(tblIncl.inclMinTrials ~= tblIncl.inclManual));
        disp(tblIncl(tblIncl.inclMinTrials ~= tblIncl.inclManual, :))
    end
    ids_included = tblIncl.id(tblIncl.inclMinTrials & tblIncl.inclManual);
else
    warning("NOTE: no valid csv file for combined manual and automatised exclusion of participants provided; using fully automatised rejection")
    ids_included = tblIncl.id(tblIncl.inclMinTrials);
end


%% 4. Last step: export to a new folder
ids = cellfun(@(x)x.id(1), {dataAll.trialinfo})';
for iSubj = 1:numel(matnames)
    thisMatIn = matnames(iSubj);
    id_ = regexp(thisMatIn, ['^[a-zA-Z]+(\d+)' visit_char], 'tokens', 'once');
    if any(ids_included == id_)    % check if included
        data = dataAll(iSubj);
        tblMetadata = tblMetadataAll(tblMetadataAll.id == id_, :);
        save(fullfile(pathData, dirDataInclOut, thisMatIn), 'data', 'tblMetadata')
    end
end
% Save the metadata table with all the included subjects
writetable(tblMetadataAll(ismember(tblMetadataAll.id, ids_included), :), fullfile(pathData, 'tblMetadata.csv'))

beep