%% Plot ET data trials by trial

function fig = fET_PlotDataTrialByTrial(x,y,subjName,trialNo,opts)
arguments
    x
    y
    subjName (1,1) string
    trialNo  (1,1) int8
    opts.fileImageTask    = fullfile("stim","frame-fam.png");          % background image to use
    opts.screenDimensions = [1024 1280];
    opts.dirFiguresIndiv  = fullfile(pwd, "ET", "Extra Figures", sprintf('Visit%d', visit), "Per individual");
end
util.fMkDirSafe(dirFiguresIndiv);
fig         = figure(2);
nSamples    = length(x);
colSamples  = jet(nSamples);
% Plot the image in the background
imageTask     = imread(fileImageTask);
xSize         = size(imageTask,2)/screenDimensions(1);
ySize         = size(imageTask,1)/screenDimensions(2);
imshow(imageTask)
hold on
% Also plot all the samples
for iSample = 1:nSamples
    if iSample >= 1
        scatter(x(iSample)*xSize, y(iSample)*ySize,[],colSamples(iSample,:),'o','filled','MarkerFaceAlpha',.5); % xSize*ySize - image size
    else
        scatter(x(iSample)*xSize, y(iSample)*ySize,[],colSamples(iSample,:),'o','LineWidth',1);
    end
end
hold off
title(sprintf('%s, trial %02d | Gaze on stim example; blue -> red',...
    iSubj,iTrial),'FontSize',15);
saveas(fig2, [opts.dirFiguresIndiv,sprintf('Subj%s_Trial%02d.png',subjName,trialNo)]);
close(fig2);

