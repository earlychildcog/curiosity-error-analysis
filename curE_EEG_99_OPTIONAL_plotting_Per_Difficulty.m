%% Make ERP & topography plots PER DIFFICULTY LEVEL
%

clear all
close all

% DEFINE THE MAIN PARAMETERS -- check that this is what you want
flag_doPreprocessing = 1;      % REMOVES PAST PREPROCESSED DATA; Preprocess (1) or just load already preprocessed data & plot (0)
visit                = 1;      % Which visit? (12m/a = 1; 18m/b = 2; 24m/c = 3)
erptype              = 'ERN';  % Which type of ERP? ('ERN' or 'FRN')

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

%% Load data

% -- Data folders
% In theory, no need to edit this -- keep the same structure and modify
% your local folder tree for compatibility
pathData       = [filesep fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d', visit), erptype)];
dirDataMatIn = "3_ERPs_AllSubjInOneFile";
dirFiguresPng  = fullfile(pwd, "EEG", "Extra Figures", sprintf('Visit%d', visit), "Per difficulty");
dirFiguresSvg  = fullfile(dirFiguresPng, "Figures final vectorised");
visitLetterList = {'a','b','c'}; visitLetter = visitLetterList{visit};
difficulties    = {"Easy", "Medium", "Hard", "xHard","Harder"};

addpath("src")
fSetUpFieldtripAndParallelPool(flagParallel=false,flagFT=true)

fprintf("Loading the data -- this will take a while, please wait")

load(fullfile(pathData, dirDataMatIn, 'groups.mat'));
load(fullfile(pathData, dirDataMatIn, sprintf('grandAvg_%s.mat', erptype)));
load(fullfile(pathData, dirDataMatIn, sprintf('ByDiff_FT_AllSubj_%s.mat', erptype)));
load(fullfile(pathData, dirDataMatIn, sprintf('ByDiff_FT_PerSubj_%s.mat', erptype)));
time = round(grandAvg.difference.time, 3);

fprintf("  ----  Data loaded, now plotting")


%% And now plot things
% Create folders for figures, or check it's ok to overwrite existing ones 
util.fMkDirSafe(dirFiguresPng);
util.fMkDirSafe(dirFiguresSvg);

%% 1 -- WHOLE GROUP: ERP plots correct vs. incorrect & difference wave
% and do cluster permutation over time points
channelsROI_labels = arrayfun(@(x) sprintf('E%d', x), channelsROI, 'UniformOutput', false);
subjList = 1:size(groups,1);
if visit==1; y_lim = [-10 5.5]; elseif visit==2; y_lim = [-12 5]; elseif visit==3; y_lim = [-13 6]; end
if strcmp(erptype,'FRN')
    timeAB = time(time>=0);
    timeWindow = [0 1];
else
    timeAB = time;
    timeWindow = [];
end

% Plot all PER DIFFICULTY LEVEL
for iDiff = 1:5
    data1 = byDiff_allSubj.correct(iDiff,:);
    data2 = byDiff_allSubj.incorrect(iDiff,:);
    [byDiff.sig_clusters_all{iDiff},byDiff.stat{iDiff}] = fEEG_ClusteringWithFT(data1, data2, channelsROI_labels,latency=timeWindow,tails=1);
    [figAlla, ~] = fEEG_PlotERP(byDiff_perSubj.correct_perSubj{iDiff},byDiff_perSubj.incorrect_perSubj{iDiff},...
        byDiff.sig_clusters_all{iDiff},time,BL,erptype,subjList,sprintf('all - %s', difficulties{iDiff}),visit,y_lim);
    saveas(figAlla,fullfile(dirFiguresPng,sprintf('%s_%s_%s',erptype,difficulties{iDiff},'all')),'png');
    print(figAlla,fullfile(dirFiguresSvg,sprintf('%s_%s_%s',erptype,difficulties{iDiff},'all')),'-dsvg');
end


%% 2 -- PER GROUP: ERP plots correct vs. incorrect & difference wave
% PER DIFFICULTY LEVEL
if visit==1; y_lim = [-11 8]; elseif visit==2; y_lim = [-12 5]; end
for iDiff = 1:5
    % --- MIRROR RECOGNISERS
    subjList = find(strcmp(groups.mirror,"R"));
    data1       = byDiff_allSubj.correct(iDiff,subjList);
    data2       = byDiff_allSubj.incorrect(iDiff,subjList);
    [figAlla, ~] = fEEG_PlotERP(byDiff_perSubj.correct_perSubj{iDiff},byDiff_perSubj.incorrect_perSubj{iDiff},...
        [],time,BL,erptype,subjList,sprintf('MirrorRecognisers - %s', difficulties{iDiff}),visit,y_lim);
    saveas(figAlla,fullfile(dirFiguresPng,sprintf('%s_%s_%s',erptype,difficulties{iDiff},'R')),'png');
    print(figAlla,fullfile(dirFiguresSvg,sprintf('%s_%s_%s',erptype,difficulties{iDiff},'R')),'-dsvg');
    % --- MIRROR NON-RECOGNISERS
    subjList = find(strcmp(groups.mirror,"NR"));
    data1       = byDiff_allSubj.correct(iDiff,subjList);
    data2       = byDiff_allSubj.incorrect(iDiff,subjList);
    [figAlla, ~] = fEEG_PlotERP(byDiff_perSubj.correct_perSubj{iDiff},byDiff_perSubj.incorrect_perSubj{iDiff},...
        [],time,BL,erptype,subjList,sprintf('MirrorNonRecognisers - %s', difficulties{iDiff}),visit,y_lim);
    saveas(figAlla,fullfile(dirFiguresPng,sprintf('%s_%s_%s',erptype,difficulties{iDiff},'NR')),'png');
    print(figAlla,fullfile(dirFiguresSvg,sprintf('%s_%s_%s',erptype,difficulties{iDiff},'NR')),'-dsvg');
end


