function fET_PlotGazeTrials(T, sessions, opts)
arguments
    T table
    sessions categorical = unique(T.session);
    opts.typeplot string {mustBeMember(opts.typeplot, ["scatter" "trace" "swarm"])} = "scatter";
end
screenwidth = 1280;
% sessions = categorical({'curE038a'});
% trials = 36;
nSession  = numel(sessions);
typeplot = opts.typeplot;
if typeplot == "trace"
    hFig = figure('WindowState','maximized');
    ax = axes(hFig);
elseif typeplot == "scatter"
    open("stim/experiment/fullscene_roi.fig")
    hFig = gcf;
    set(hFig,'WindowState','maximized')
    ax = hFig.Children;
elseif typeplot == "swarm"
    hFig = figure('WindowState','maximized');
    ax = axes(hFig);
    img = imresize(imread("stim/experiment/fullscene.png"), [1024 1280]);
    imshow(img, 'Parent',ax)
end
hold(ax,"on");
colours = [[0,0,1];[0.25,0.5,0.75];[1,0,0];[0.75,0.5,0.25]];
for iSession = 1:nSession
    thisSession = sessions(iSession);
    trials = unique(T.trial(T.session == thisSession));
    nTrials = numel(trials);
    for iTrial = 1:nTrials
        thisTrial = trials(iTrial);
        I = T.session == thisSession & T.trial == thisTrial;
        periods = unique(T.period_in_trial(I));
        periods(periods == "-") = [];
        for iPeriod = 1:numel(periods)
            thisPeriod = periods(iPeriod);
            J = I & T.period_in_trial == thisPeriod;
            if typeplot == "trace"
                plot(ax, double(T.time(J))/1000, T.inScreenLx(J),'.','Color',colours(1,:));
                plot(ax, double(T.time(J))/1000, T.inScreenLy(J),'.','Color',colours(2,:));
                plot(ax, double(T.time(J))/1000, T.inScreenRx(J),'.','Color',colours(3,:));
                plot(ax, double(T.time(J))/1000, T.inScreenRy(J),'.','Color',colours(4,:));
                set(ax.Children,'linewidth',2)
                legend(ax, ["Lx", "Ly", "Rx", "Ry"],'FontSize',16);      
            elseif typeplot == "scatter"
                % Also plot all the samples
                x = T.inScreenLx(J);
                y = T.inScreenLy(J);
                nSamples    = length(x);
                colSamples  = jet(nSamples);
                % plotHeatmap(x,y,sigma=1)
                scatter(ax, x*screenwidth, y*screenwidth,'bo'); % xSize*ySize - image size
                % for iSample = 1:nSamples
                %     scatter(ax, x(iSample)*screenwidth, y(iSample)*screenwidth,[],colSamples(iSample,:),'o'); % xSize*ySize - image size
                % end
                x = T.inScreenRx(J);
                y = T.inScreenRy(J);
                nSamples    = length(x);
                colSamples  = jet(nSamples);
                scatter(ax, x*screenwidth, y*screenwidth,'rx'); % xSize*ySize - image size
                % for iSample = 1:nSamples
                %     scatter(ax, x(iSample)*screenwidth, y(iSample)*screenwidth,[],colSamples(iSample,:),'x'); % xSize*ySize - image size
                % end
            elseif typeplot == "swarm"
                img_ = img;
                % left gaze
                x = round(T.inScreenLx(J)*screenwidth);
                y = round(T.inScreenLy(J)*screenwidth);
                missing = isnan(x) | isnan(y);
                x(missing) = [];
                y(missing) = [];
                if ~isempty(x)
                    cm = uint8(jet(3*size(x,1))*255);
                    cmL = cm(1:(end/3+1), :);
                    img_ = plotSwarm(x,y, background_image=img, filled=false, colourmap=cmL);
                end
                % right gaze
                x = round(T.inScreenRx(J)*screenwidth);
                y = round(T.inScreenRy(J)*screenwidth);
                missing = isnan(x) | isnan(y);
                x(missing) = [];
                y(missing) = [];
                if ~isempty(x)
                    cm = uint8(jet(3*size(x,1))*255);
                    cmR = flip(cm(((2*end/3)+1):end, :),1);
                    img_ = plotSwarm(x,y, background_image=img_, filled=false, colourmap=cmR);
                end
                w = 5;
                if ~isempty(cmL)
                    img_(:,1:w,:) = imresize(repmat(reshape(cmL, [size(cmL,1) 1 3]), [1 w 1]), [size(img_,1), w]);
                end
                if ~isempty(cmR)
                    img_(:,(w+1):2*w,:) = imresize(repmat(reshape(cmR, [size(cmR,1) 1 3]), [1 w 1]), [size(img_,1), w]);
                end
                % we can speedup even more by not recreating object but replacing its cdata property
                ax.Children.CData = img_;
            end
            title(sprintf("%s trial %d %s, o:L x:R, logratio l2r std %.2f, missing L%.0f%% R:%.0f%%, L: %s, R: %s", ...
                thisSession, thisTrial, thisPeriod, T.logratio_stdL2R(find(J,1)), T.missingL(find(J,1))*100, T.missingR(find(J,1))*100, T.qualityL(find(J,1)), T.qualityR(find(J,1))), 'Interpreter','none')
            pause(.3); % need time to finish figure before saving it -- .1s and sometimes .2 not enough on Cecile computer, note you might be able to make it shorter or need it longer
            saveas(hFig, fullfile('figures indiv', opts.typeplot, sprintf('%s_trial%02d_%s.png',thisSession,thisTrial,thisPeriod)));
            if typeplot == "scatter"
                delete(ax.Children(1:2));
            elseif typeplot == "trace"
                delete(ax.Children);
            end
            % pause(2);
            % in = input('\npress enter to continue, Q+enter to quit\n','s');
            % if strcmpi(in, 'q')
            %     return
            % end
        end
    end
end
close

end