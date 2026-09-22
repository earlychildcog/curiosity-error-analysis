%% Make plots based on the last analyses (after US trip May 25)

clear all
close all

%% Define important variables
visit        = 1;        % 1/2/3

%% Define more things and load data
addpath("src");
addpath(genpath(fullfile("src","libraries")));
% Paths (normally no need to change)
pathData           = [filesep, fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d',visit),'eyetracking')];
pathDataStatsOut   = fullfile(pathData, '4_OutputsForStats');
pathFiguresPng  = fullfile(pwd, "Figures", sprintf('Visit%d', visit), "eyetracking");
pathFiguresSvg  = fullfile(pathFiguresPng, "Figures final vectorised");
util.fMkDirSafe(pathFiguresPng);
util.fMkDirSafe(pathFiguresSvg);
% Colormap
colors = linspecer(9);
%  Load data
T = readtable(fullfile(pathDataStatsOut,sprintf('visit%d_AllData_EEGandET_wholeGroup.csv',visit)));

%% Plot relevant variables as boxplots or rainclouds or scatter plots for all, R & NR
% --- EYETRACKING VARIABLES BOXPLOTS
% Decide what to plot
groups     = {'R', 'NR'}; % can also use 'all'
trialTypes = {'PriorCorr', 'PriorIncorr'};
variables  = {'nFixExpB', 'nSwitchExpB', 'decLat'};
% And how
yL = {[-2 27], ...
    [-0.2 9.5], ...
    [0 10.6]};
args = [];
args.labels={'Post-Corr.','Post-Incorr.'};
args.colors=[colors(3,:);colors(1,:)];
% Plot
fET_plotAndSave_Boxplots(T, pathFiguresPng, pathFiguresSvg, groups, trialTypes, variables, args, yL=yL);
% --- PERFORMANCE VARIABLE BOXPLOTS
% Decide what to plot
groups     = {'R', 'NR'};
trialTypes = {};
variables  = {'slope_accuracy'};
% And how
yL = {};
args = [];
args.labels = {'R', 'NR'};
% Plot
fET_plotAndSave_Boxplots(T, pathFiguresPng, pathFiguresSvg, groups, trialTypes, variables, args, yL=yL);
% --- PERFORMANCE & ERN REGRESSION
% Decide what to plot
groups = T.mirror;
variables = {'slope_accuracy', 'ERN_Diff_min33to172ms'};
labels = {'Performance', 'ERN (uV)'};
% Plot
fET_plotAndSave_Regressions(T, pathFiguresPng, pathFiguresSvg, groups, variables, labels);