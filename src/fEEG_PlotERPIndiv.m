function [fig1] = fEEG_PlotERPIndiv(correct_perTrial, incorrect_perTrial, time, BL, erptype, subjName, visit)


% Calculating group's avg & sem ERP values for the whole time
correct_sem    = std(correct_perTrial) ./ sqrt(size(correct_perTrial,1));
incorrect_sem  = std(incorrect_perTrial) ./ sqrt(size(incorrect_perTrial,1));
correct_avg    = mean(correct_perTrial,1);
incorrect_avg  = mean(incorrect_perTrial,1);

% Plotting Corr vs. Incorr and saving figure
fig1 = figure;
hold on;
shadedErrorBar(time, correct_avg, correct_sem,'lineprops','-b','patchSaturation',0.33);
shadedErrorBar(time, incorrect_avg, incorrect_sem,'lineprops','-r','patchSaturation',0.33);
xlabel('Time (ms)');
ylabel('Amplitude (\muV)');
xline(0, 'k--', 'LineWidth', 2);
yline(0, 'k-', 'LineWidth', 1.5);
title(sprintf('%s - %s (baseline: %d to %d ms)',subjName,erptype,BL(1)*1000,BL(2)*1000));
legend('Correct', 'Incorrect');
lim = axis;
rBaseL = rectangle(Position=[BL(1),lim(3),-(BL(1)-BL(2)),lim(4)-lim(3)],FaceColor=[.5,.5,.5],FaceAlpha=.3,EdgeColor="none");
if strcmp(erptype,'FRN')
    xlim([0 1]);
end
hold off;

end