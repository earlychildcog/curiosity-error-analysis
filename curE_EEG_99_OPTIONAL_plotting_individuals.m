%% Plot ERPs & topographies FOR EACH INDIVIDUAL (for reference)
%
% This is an optional step (when exploring the data and checking individual
% patterns & noise levels)
%

clear all
close all

%% DEFINE THE MAIN PARAMETERS -- check that this is what you want
flag_doPreprocessing = 1;      % REMOVES PAST PREPROCESSED DATA; Preprocess (1) or just load already preprocessed data & plot (0)
visit                = 1;      % Which visit? (12m/a = 1; 18m/b = 2; 24m/c = 3)
erptype              = 'ERN';  % Which type of ERP? ('ERN' or 'FRN')

%% Define more parameters (no need to change)
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
pathData        = [filesep fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d', visit), erptype)];
dirDataMatIn    = "3_ERPs_AllSubjInOneFile";
dirFiguresIndiv = fullfile(pwd, "EEG", "Extra Figures", sprintf('Visit%d', visit), "Per individual");
dirFiguresERPs  = fullfile(dirFiguresIndiv, "ERPs");
dirFiguresTopos = fullfile(dirFiguresIndiv, "Topos");

util.fMkDirSafe(dirFiguresIndiv);
util.fMkDirSafe(dirFiguresERPs);
util.fMkDirSafe(dirFiguresTopos);


visitLetterList = {'a','b','c'}; visitLetter = visitLetterList{visit};
difficulties    = {"Easy", "Medium", "Hard", "xHard","Harder"};

addpath("src")
fSetUpFieldtripAndParallelPool(flagParallel=false,flagFT=true)

fprintf("Loading the data -- this will take a while, please wait")

load(fullfile(pathData, dirDataMatIn, 'groups.mat'));
load(fullfile(pathData, dirDataMatIn, sprintf('allSubj_AllTrials_%s.mat',erptype)));
load(fullfile(pathData, dirDataMatIn, sprintf('CorrIncorrDiff_PerSubj_%s.mat', erptype)));
load(fullfile(pathData, dirDataMatIn, sprintf('CorrIncorrDiff_FT_PerSubj_%s.mat', erptype)));
time = round(Correct_allSubj{1, 1}.time, 3);

fprintf("  ----  Data loaded, now plotting")

plotIndivERPs = 1;
plotIndivTopo = 1;


%% Plot
channelsROI = arrayfun(@(x) sprintf('E%d', x), channelsROI, 'UniformOutput', false);
subjList = 1:size(groups,1);
% subjList = find(strcmp(groups.mirror,"R"))';
% subjList = find(strcmp(groups.mirror,"NR"))';
for iSubj = subjList
    corrERP    = Correct_allSubj_allTrials{1,iSubj};
    incorrERP  = Incorrect_allSubj_allTrials{1,iSubj};
    corrTopo   = Correct_allSubj{1,iSubj};
    incorrTopo = Incorrect_allSubj{1,iSubj};
    diffTopo   = Difference_allSubj{1,iSubj};
    subjName   = ['curE' groups.subj{iSubj} visitLetter];
    if plotIndivERPs
        fig1 = fEEG_PlotERPIndiv(corrERP,incorrERP,time,BL,erptype,subjName,visit);
        saveas(fig1,fullfile(dirFiguresERPs,sprintf('%s_12m_Avg_SEM_CorrIncorr_%d_%d_%s',erptype,BL(1)*1000,BL(2)*1000,subjName)),'png');
    end
    if plotIndivTopo
        if strcmp(erptype,'ERN')
            timeWindow = timeWin(1,:);
        elseif strcmp(erptype,'FRN')
            timeWindow = timeWin(1,:);
        else
            timeWindow = [time(1) time(end)];
        end
        fig = fEEG_PlotTopoplotConditions({corrTopo, incorrTopo, diffTopo},...
            {'Correct trials','Incorrect trials','Difference'},...
            timeWindow, channelsROI, BL, erptype, visit, subjName, []);
        saveas(fig,fullfile(dirFiguresTopos,sprintf('topo_%s_%dm_%d-%dms_%s',erptype,12*visit,timeWindow(1)*1000,timeWindow(2)*1000,subjName)),'png');
    end
end

