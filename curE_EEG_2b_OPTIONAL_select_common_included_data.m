%% Select only data included for both ERP types ("ERN" and "FRN")
%
% /!\ Always set up the flags at the top of script before running:
%   - erptype: here we need two ERP types for comparison (we want to only
%   include trials where segments for both types of ERP have been deemed
%   clean which we call common trials; set as string array ["ERN", "FRN"]
%   - visit: whether we're looking at visit 1, 2 or 3
%
% If you already have run this script for the current visit and erptype
% and have data saved in your folder, this script will prompt you to
% confirm whether you want to proceed and overwrite the data (y), stop the
% process (q), save the new data in new files in the same folder as the old
% ones (n -- not recommended, several files for the same participant will
% coexist).
%

%% Define the main parameters
erptypes     = ["ERN" "FRN"];
visit        = 1;

%% Set things up
addpath("src")
fSetUpFieldtripAndParallelPool(flagParallel=false,flagFT=true)
pathData         = filesep + fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d', visit), erptypes);
dirDataMatIn     = "2_matIncluded";
dirDataCommonOut = dirDataMatIn + "Common";
arrayfun(@util.fMkDirSafe, fullfile(pathData, dirDataCommonOut));   % make the folders, or prompt to empty the folder if files are detected in
matnames = arrayfun(@(x)string({dir(fullfile(x, dirDataMatIn, "*.mat")).name}), pathData, UniformOutput=false);
visit_char = char('a' + visit - 1);

% Assumes a string of type curXNNN where X is supposed to be a letter (eg curE) and NNN a 3-digit number (can have leading zeros e.g., 003)
ids = cellfun(@(m)string(regexp(m, ['cur\w(\d\d\d)' visit_char], 'tokens','once')), matnames, UniformOutput=false);
[ids_common, ids_index] = fGetCommon_(ids);
nSubj = numel(ids_common);
tblMetadataAll = cell(nSubj,2);

%% Loop through subjects and save for each of them trials that are included in both erp types
for iSubj=1:nSubj
    % get the data & the trial numbers for each erp
    for iERP=2:-1:1
        temp(iERP) = load(fullfile(pathData(iERP), dirDataMatIn, matnames{iERP}(ids_index{iERP}(iSubj))), 'data', 'tblMetadata');
        trialno{iERP} = temp(iERP).data.trialinfo.trialno;
    end
    % compute the common trial numbers & indices
    [trialno_common, trialno_index] = fGetCommon_(trialno);
    % extract and save the common trials
    for iERP=2:-1:1
        temp(iERP).data.cfg.trials = trialno_index{iERP};
        data = ft_selectdata(struct(trials=trialno_index{iERP}), temp(iERP).data);
        tblMetadata = temp(iERP).tblMetadata;
        tblMetadata = tblMetadata(trialno_index{iERP}, :);
        save(fullfile(pathData(iERP), dirDataCommonOut, matnames{iERP}(ids_index{iERP}(iSubj))), 'data', 'tblMetadata')
        tblMetadataAll{iSubj, iERP} = tblMetadata;
    end
end
for k=1:2
    writetable(cat(1, tblMetadataAll{:,k}), fullfile(pathData(k), "tblMetadataCommon" + erptypes(k) + ".csv"));
end
beep

% Useful function to get common ids, trials etc in a 1x2 cell array of 2 array lists
function [common_, index_] = fGetCommon_(cellIn)
    arguments
        cellIn (1,2) cell
    end
    [common_, idx1, idx2] = intersect(cellIn{1}, cellIn{2},'stable');
    index_ = {idx1, idx2};
end