%% Make ERP & topography plots
%
% If you already have run this script for the current visit and erptype
% and have figures saved in your folder, this script will prompt you to
% confirm whether you want to proceed and overwrite the files (y), stop the
% process (q), save the new data in new files in the same folder as the old
% ones (n -- not recommended, several files for the same participant will
% coexist).
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
pathDataRoot   = [fullfile('Users',getenv('USER'),'Data','curE')];
pathData       = [filesep, fullfile(pathDataRoot, sprintf('Visit%d', visit), erptype)];
pathDataERN    = [filesep, fullfile(pathDataRoot,sprintf('Visit%d', visit), 'ERN')];
dirDataMatIn = "3_ERPs_AllSubjInOneFile";
dirFiguresPng  = fullfile(pwd, "Figures", sprintf('Visit%d', visit), "EEG");
dirFiguresSvg  = fullfile(dirFiguresPng, "Figures final vectorised");
visitLetterList = {'a','b','c'}; visitLetter = visitLetterList{visit};
difficulties    = {"Easy", "Medium", "Hard", "xHard","Harder"};

addpath("src")
fSetUpFieldtripAndParallelPool(flagParallel=false,flagFT=true)

fprintf("Loading the data -- this will take a while, please wait")

load(fullfile(pathDataERN, dirDataMatIn, 'groups.mat'));
load(fullfile(pathData, dirDataMatIn, sprintf('grandAvg_%s.mat', erptype)));
load(fullfile(pathData, dirDataMatIn, sprintf('CorrIncorrDiff_PerSubj_%s.mat', erptype)));
load(fullfile(pathData, dirDataMatIn, sprintf('CorrIncorrDiff_FT_PerSubj_%s.mat', erptype)));
time = round(grandAvg.difference.time, 3);

fprintf("  ----  Data loaded, now plotting \n")


%% And now plot things
% Create folders for figures if needed (but don't overwrite as ERN & FRN
% write to the same folder one after the other)
util.fMkDirSafe(dirFiguresPng, flagCleanDir="no_clean");
util.fMkDirSafe(dirFiguresSvg, flagCleanDir="no_clean");

%% 1 -- WHOLE GROUP: ERP plots correct vs. incorrect & difference wave
% and do cluster permutation over time points
channelsROI = arrayfun(@(x) sprintf('E%d', x), channelsROI, 'UniformOutput', false);
if visit==1; y_lim = [-10 5.5]; elseif visit==2; y_lim = [-12 5]; elseif visit==3; y_lim = [-13 6]; end
% Plot all
subjList = 1:size(groups,1);
if strcmp(erptype,'FRN')
    dataA  = correct_perSubj(:,time>=0);
    dataB  = incorrect_perSubj(:,time>=0);
    timeAB = time(time>=0);
    timeWindow = [0 1];
else
    dataA  = correct_perSubj;
    dataB  = incorrect_perSubj;
    timeAB = time;
    timeWindow = [];
end
data1       = Correct_allSubj;
data2       = Incorrect_allSubj;
[sig_clusters_all,stat] = fEEG_ClusteringWithFT(data1, data2, channelsROI,latency=timeWindow,tails=1); 
[figAlla, ~] = fEEG_PlotERP(dataA,dataB,...
    sig_clusters_all,timeAB,BL,erptype,subjList,'all',visit,y_lim);
saveas(figAlla,fullfile(dirFiguresPng,sprintf('%s_%s',erptype,'all')),'png');
print(figAlla,fullfile(dirFiguresSvg,sprintf('%s_%s',erptype,'all')),'-dsvg');

%% 2 -- PER GROUP: ERP plots correct vs. incorrect & difference wave
if visit==1; y_lim = [-11 8]; elseif visit==2; y_lim = [-12 5]; end
% --- MIRROR RECOGNISERS
subjList = find(strcmp(groups.mirror,"R"));
data1       = Correct_allSubj(subjList);
data2       = Incorrect_allSubj(subjList);
[figRa, figRb] = fEEG_PlotERP(correct_perSubj,incorrect_perSubj,sig_clusters_all,time,BL,erptype,subjList,'MirrorRecognisers',visit,y_lim);
saveas(figRa,fullfile(dirFiguresPng,sprintf('%s_%s',erptype,'R')),'png');
print(figRa,fullfile(dirFiguresSvg,sprintf('%s_%s',erptype,'R')),'-dsvg');
% --- MIRROR NON-RECOGNISERS
subjList = find(strcmp(groups.mirror,"NR"));
data1       = Correct_allSubj(subjList);
data2       = Incorrect_allSubj(subjList);
[figNRa, ~] = fEEG_PlotERP(correct_perSubj,incorrect_perSubj,sig_clusters_all,time,BL,erptype,subjList,'MirrorNonRecognisers',visit,y_lim);
saveas(figNRa,fullfile(dirFiguresPng,sprintf('%s_%s',erptype,'NR')),'png');
print(figNRa,fullfile(dirFiguresSvg,sprintf('%s_%s',erptype,'NR')),'-dsvg');

%% 3 -- Topoplots for the different time windows (same as extracted earlier)
if visit==1; z_lim = [-5 5]; else; z_lim = []; end
for iWin = 1:size(timeWin,2)
    if ~strcmp(erptype,'FRN') || iWin ~=1
        timeWindow = timeWin(iWin,:);

        %All
        fig1 = fEEG_PlotTopoplotDiffWave(grandAvg.difference, timeWindow, channelsROI, BL, erptype,visit,z_lim);
        saveas(fig1,fullfile(dirFiguresPng,sprintf('topo_%s%d',erptype,iWin)),'png');
        print(fig1,fullfile(dirFiguresSvg,sprintf('topo_%s%d',erptype,iWin)),'-dsvg');
        fig2 = fEEG_PlotTopoplotConditions({grandAvg.correct, grandAvg.incorrect, grandAvg.difference},...
            {'Correct trials','Incorrect trials','Difference'},...
            timeWindow, channelsROI, BL, erptype, visit, 'all', []);
        saveas(fig2,fullfile(dirFiguresPng,sprintf('topo_CorrIncorrDiff_%s%d',erptype,iWin)),'png');
        print(fig2,fullfile(dirFiguresSvg,sprintf('topo_CorrIncorrDiff_%s%d',erptype,iWin)),'-dsvg');
        
        %Rs
        fig1 = fEEG_PlotTopoplotDiffWave(grandAvg.difference_R, timeWindow, channelsROI, BL, erptype,visit,z_lim);
        saveas(fig1,fullfile(dirFiguresPng,sprintf('topo_R_%s%d',erptype,iWin)),'png');
        print(fig1,fullfile(dirFiguresSvg,sprintf('topo_R_%s%d',erptype,iWin)),'-dsvg');
        fig2 = fEEG_PlotTopoplotConditions({grandAvg.correct_R, grandAvg.incorrect_R, grandAvg.difference_R},...
            {'Correct trials','Incorrect trials','Difference'},...
            timeWindow, channelsROI, BL, erptype, visit, 'Rs', []);
        saveas(fig2,fullfile(dirFiguresPng,sprintf('topo_R_CorrIncorrDiff_%s%d',erptype,iWin)),'png');
        print(fig2,fullfile(dirFiguresSvg,sprintf('topo_R_CorrIncorrDiff_%s%d',erptype,iWin)),'-dsvg');
        
        %NRs
        fig1 = fEEG_PlotTopoplotDiffWave(grandAvg.difference_NR, timeWindow, channelsROI, BL, erptype,visit,z_lim);
        saveas(fig1,fullfile(dirFiguresPng,sprintf('topo_NR_%s%d',erptype,iWin)),'png');
        print(fig1,fullfile(dirFiguresSvg,sprintf('topo_NR_%s%d',erptype,iWin)),'-dsvg');
        fig2 = fEEG_PlotTopoplotConditions({grandAvg.correct_NR, grandAvg.incorrect_NR, grandAvg.difference_NR},...
            {'Correct trials','Incorrect trials','Difference'},...
            timeWindow, channelsROI, BL, erptype, visit, 'NRs', []);
        saveas(fig2,fullfile(dirFiguresPng,sprintf('topo_CorrIncorrDiff_NR_%s%d',erptype,iWin)),'png');
        print(fig2,fullfile(dirFiguresSvg,sprintf('topo_CorrIncorrDiff_NR_%s%d',erptype,iWin)),'-dsvg');

    end
end

%% OPTIONAL: Plot Rs and NRs overlayed
% % Plot correct trials
% data1 = correct_perSubj(strcmp(groups.mirror,"R"),:); data2 = correct_perSubj(strcmp(groups.mirror,"NR"),:);
% [figCorr, ~] = fEEG_PlotERP(data1,data2,sig_clusters_corr,time,BL,erptype,[],'Correct',visit,y_lim);
% saveas(figCorr,fullfile(dirFiguresSvg,sprintf('%s_Corr_RvsNR',erptype)),'png');
% print(figCorr,fullfile(dirFiguresSvg,sprintf('%s_Corr_RvsNR',erptype)),'-dsvg');
% % Plot Incorrect trials
% data1 = incorrect_perSubj(strcmp(groups.mirror,"R"),:); data2 = incorrect_perSubj(strcmp(groups.mirror,"NR"),:);
% [figIncorr, ~] = fEEG_PlotERP(data1,data2,sig_clusters_incorr,time,BL,erptype,[],'Incorrect',visit,y_lim);
% saveas(figIncorr,fullfile(dirFiguresSvg,sprintf('%s_Incorr_RvsNR',erptype)),'png');
% print(figIncorr,fullfile(dirFiguresSvg,sprintf('%s_Incorr_RvsNR',erptype)),'-dsvg');

%% OPTIONAL: plot ERPs for each condition, each electrode, whole scalp
% cfg    = [];
% ft_multiplotER(cfg, grandAvg.correct, grandAvg.incorrect)

beep