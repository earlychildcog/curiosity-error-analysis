%% Plot gaze overlayed on image per baby, trial and period
visitNo = 1;
addpath("src");
load(sprintf("data/eyetracking/Visit%d/FORJULIETA_all-visit%d-clean-small-fix.mat",visitNo,visitNo));
fET_PlotGazeTrials(T);