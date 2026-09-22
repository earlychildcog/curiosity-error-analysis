function [fig1, fig2] = fEEG_PlotERP(correct_perSubj, incorrect_perSubj, sig_clusters, time, BL, erptype, subjList, groupName,visit,y_lim)

% col = linspecer(2); % blue and red
col = linspecer(4); col = [col(3,:); col(2,:)]; % Green and red
font_size = 22;
if strcmp(groupName,'all') || strcmp(groupName,'Correct') || strcmp(groupName,'Incorrect')
    FaceCol=[.2 .2 .2];
else
    FaceCol=[.6 .6 .6];
end

% Figure out how many subjects with data we have
Nsubj = sum(~isnan(correct_perSubj(subjList,1)));
% Calculating group's avg & sem ERP values for the whole time
if ~isempty(subjList)
    corr   = correct_perSubj(subjList,:);
    incorr = incorrect_perSubj(subjList,:);
else
    corr   = correct_perSubj(:,:);
    incorr = incorrect_perSubj(:,:);
end
correct_sem    = std(corr,'omitmissing') / sqrt(size(corr,1));
incorrect_sem  = std(incorr,'omitmissing') / sqrt(size(incorr,1));
correct_avg    = mean(corr,1,'omitmissing');
incorrect_avg  = mean(incorr,1,'omitmissing');
flagPlotDiff = 0;
if size(correct_perSubj,1) == size(incorrect_perSubj,1)
    flagPlotDiff = 1;
    difference_perSubj = correct_perSubj - incorrect_perSubj;
    difference_sem = std(difference_perSubj(subjList,:),'omitmissing') / sqrt(size(difference_perSubj(subjList,:),1));
    difference_avg = mean(difference_perSubj(subjList,:),1,'omitmissing');
end

% Plotting Corr vs. Incorr and saving figure
fig1 = figure;
if strcmp(erptype,'FRN')
    fig1.Position(3) = fig1.Position(3)*1.1765;
else
    fig1.Position(3) = fig1.Position(3)*1;
end
hold on;
shadedErrorBar(time, correct_avg, correct_sem,'lineprops',{'-','color',col(1,:),'linewidth',1.5},'patchSaturation',0.5);
shadedErrorBar(time, incorrect_avg, incorrect_sem,'lineprops',{'-','color',col(2,:),'linewidth',1.5},'patchSaturation',0.5);
xlabel('Time (s)');
ylabel('Amplitude (\muV)');
xline(0, 'k--', 'LineWidth', 2);
yline(0, 'k-', 'LineWidth', 1.5);
% sgtitle(sprintf('%s Correct vs Incorrect ; group: %s',erptype,groupName));
if size(correct_perSubj,1) == size(incorrect_perSubj,1)
    legend('Correct', 'Incorrect',Box='off');
else
    legend('Rs', 'NRs',Box='off');
end
% if ~strcmp(groupName,'all')
if ~isempty(y_lim)
    ylim(y_lim);
end
% else
%     ylim([-15 7]);
% end
lim = axis;
% Now plot the significant time clusters
if ~isempty(sig_clusters)
    % Use this to plot greenish shaded areas all over the sig zone
    % for iCluster = 1:size(sig_clusters,2)
    %     x1 = time(sig_clusters(iCluster).time_points(1));
    %     xW = time(sig_clusters(iCluster).time_points(end))-x1;
    %     rBaseL = rectangle(Position=[x1,-30,xW,60],...
    %         FaceColor=[8/255,50/255,48/255],FaceAlpha=.25,EdgeColor="none");
    % end
    if isstruct(sig_clusters) % if we're using the structure from our custom-made clkustering fucntion (old way)
        % Use this to plot bars at the bottom of the plot along sig zone
        for iCluster = 1:size(sig_clusters,2)
            x1 = time(sig_clusters(iCluster).time_points(1));
            xW = time(sig_clusters(iCluster).time_points(end))-x1;
            y1 = lim(3) + .02*(lim(4)-lim(3));
            % y1 = lim(3) + .005*(lim(4)-lim(3));
            yW = lim(3) + .04*(lim(4)-lim(3)) - y1;
            rectangle(Position=[x1,y1,xW,yW],...
                FaceColor=FaceCol,EdgeColor="none");
        end
    else
        % Use this to plot bars at the bottom of the plot along sig zone
        for iCluster = 1:size(sig_clusters,1)
            x1 = sig_clusters(iCluster,1);
            xW = sig_clusters(iCluster,2)-x1;
            y1 = lim(3) + .02*(lim(4)-lim(3));
            % y1 = lim(3) + .005*(lim(4)-lim(3));
            yW = lim(3) + .04*(lim(4)-lim(3)) - y1;
            rectangle(Position=[x1,y1,xW,yW],...
                FaceColor=FaceCol,EdgeColor="none");
        end
    end
end
% rBaseL = rectangle(Position=[BL(1), BL(2)-BL(1), lim(3)+.02*(lim(4)-lim(3)), lim(3)+.04*(lim(4)-lim(3))-y1],FaceColor=[.5,.5,.5],FaceAlpha=.3,EdgeColor="none");
% ylim([lim(3)-.05*(lim(4)-lim(3)), lim(4)]);
% else
%     ylim([lim(3), lim(4)]);
% end
if strcmp(erptype,'FRN')
    xlim([0 1]);
    if ~isempty(y_lim)
        ylim(y_lim);
    end
    legend('Location','southeast')
else
    xlim([-.3 .55]);
end
title(sprintf('%s - N = %d',groupName,Nsubj));
fontsize(font_size,'points');
lim = axis;
if ~isnan(BL(1))
    rBaseL = rectangle(Position=[BL(1),lim(3),-(BL(1)-BL(2)),lim(4)-lim(3)],FaceColor=[.5,.5,.5],FaceAlpha=.3,EdgeColor="none");
end
hold off;

% Plotting the Difference wave and saving figure
fig2 = figure;
if flagPlotDiff
    if strcmp(erptype,'FRN')
        fig2.Position(3) = fig2.Position(3)*1.35294117648;
    end
    hold on;
    shadedErrorBar(time, difference_avg, difference_sem,'lineprops',{'-b','linewidth',1.5},'patchSaturation',0.33);
    xlabel('Time (s)');
    ylabel('Amplitude (\muV)');
    xline(0, 'k--', 'LineWidth', 2);
    yline(0, 'k-', 'LineWidth', 1.5);
    % sgtitle(sprintf('%s Difference: Corr - Incorr ; group: %s',erptype,groupName));
    legend('Difference',box='off');
    if visit==1
        ylim([-4.5 10]);
    elseif visit==2
        ylim([-8 8]);
    end
    lim = axis;
    % Now plot the significant time clusters
    if ~isempty(sig_clusters)

        % Use this to plot greenish shaded areas all over the sig zone
        % for iCluster = 1:size(sig_clusters,2)
        %     x1 = time(sig_clusters(iCluster).time_points(1));
        %     xW = time(sig_clusters(iCluster).time_points(end))-x1;
        %     rBaseL = rectangle(Position=[x1,-30,xW,60],...
        %         FaceColor=[8/255,70/255,63/255],FaceAlpha=.25,EdgeColor="none");
        % end

        if isstruct(sig_clusters) % if we're using the structure from our custom-made clkustering fucntion (old way)
            % Use this to plot black bars at the bottom of the plot along sig zone
            for iCluster = 1:size(sig_clusters,2)
                x1 = time(sig_clusters(iCluster).time_points(1));
                xW = time(sig_clusters(iCluster).time_points(end))-x1;
                y1 = lim(3) + .02*(lim(4)-lim(3));
                % y1 = lim(3) + .005*(lim(4)-lim(3));
                yW = lim(3) + .04*(lim(4)-lim(3)) - y1;
                rectangle(Position=[x1,y1,xW,yW],...
                    FaceColor=FaceCol,EdgeColor="none");
            end
        else
            % Use this to plot bars at the bottom of the plot along sig zone
            for iCluster = 1:size(sig_clusters,1)
                x1 = sig_clusters(iCluster,1);
                xW = sig_clusters(iCluster,2)-sig_clusters(iCluster,1);
                y1 = lim(3) + .02*(lim(4)-lim(3));
                % y1 = lim(3) + .005*(lim(4)-lim(3));
                yW = lim(3) + .04*(lim(4)-lim(3)) - y1;
                rectangle(Position=[x1,y1,xW,yW],...
                    FaceColor=FaceCol,EdgeColor="none");
            end
        end
        % ylim([lim(3)-.05*(lim(4)-lim(3)), lim(4)]);
        % else
        %     ylim([lim(3), lim(4)]);
        % end
    end
    if strcmp(erptype,'FRN')
        xlim([0 1]);
    else
        xlim([-.3 .55]);
    end
    if visit==1
        ylim([-4.5 10]);
    elseif visit==2
        if strcmp(groupName,'all')
            ylim([-2 2]);
        else
            ylim([-8 8]);
        end
    end
    title(sprintf('%s - N = %d',groupName,Nsubj));
    fontsize(font_size,'points');
    lim = axis;
    if ~isnan(BL(1))
        rBaseL = rectangle(Position=[BL(1),lim(3),-(BL(1)-BL(2)),lim(4)-lim(3)],FaceColor=[.5,.5,.5],FaceAlpha=.3,EdgeColor="none");
    end
    hold off;

end