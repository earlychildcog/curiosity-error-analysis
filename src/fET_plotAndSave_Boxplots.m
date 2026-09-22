function fET_plotAndSave_Boxplots(T, pathFiguresPng, pathFiguresSvg, groups, trialTypes, variables, args, opts)

arguments
    T
    pathFiguresPng
    pathFiguresSvg
    groups
    trialTypes
    variables
    args
    opts.yL % if you want an array of limits for different variables
end
idx = fGetSessions(groups, T); % Get participant indices per group
if ~isempty(trialTypes)
    % Loop over _groups and variables_ and plot all _trials types_ in the same plot
    for i_Group = 1:size(groups,2)
        group = groups{i_Group};
        for i_Var = 1:size(variables,2)
            variable = variables{i_Var};
            if ~isempty(opts.yL)
                args.y_lim=[opts.yL{i_Var}];
            end
            data=[];
            for i_trialType = 1:size(trialTypes,2)
                trialType = trialTypes{i_trialType};
                data(:,i_trialType) = T.(strcat(variable, '_', trialType))(idx.(group));
            end
            do_theThing(data, variable, trialTypes, group, pathFiguresPng, pathFiguresSvg, args)
        end
    end
else
    % Loop over _variables_ and plot all _groups_ in the same plot
    for i_Var = 1:size(variables,2)
        variable = variables{i_Var};
        if ~isempty(opts.yL)
            args.y_lim=[opts.yL{i_Var}];
        end
        data=[];
        for i_Group = 1:size(groups,2)
            group = groups{i_Group};
            data{i_Group} = T.(strcat(variable))(idx.(group));
        end
        do_theThing(data, variable, trialTypes, group, pathFiguresPng, pathFiguresSvg, args)
    end
end

% HELPER FUNCTION
    function do_theThing(data, variable, trialTypes, group, pathFiguresPng, pathFiguresSvg, args)
        if strcmp(variable, 'decLat')
            data = data/1000; % plot latencies in s not ms
        end
        fig = figure;
        % Parse the parameters from a structure to a cell array
        varargin = namedargs2cell(args);
        fBoxplotWithDotsAndColors(data, varargin{:});
        % Save big figure to png
        title(sprintf('%s - %s', variable, group))
        saveas(fig,fullfile(pathFiguresPng,sprintf('%s_%s_%s',group, variable,strjoin(trialTypes,'-'))),'png');
        pos=get(gcf,"Position"); fig.Position = [pos(1) pos(2) pos(3)*.35 pos(4)*.9];
        % Save smaller figure to svg
        print(fig,fullfile(pathFiguresSvg,sprintf('%s_%s_%s',group, variable,strjoin(trialTypes,'-'))),'-dsvg');
    end

end
