function [sig_clusters_all,stat] = fEEG_ClusteringWithFT(data1, data2, varargin)

% THIS FUNCTION USES FieldTrip CORE FUNCTION ft_timelockstatistics

%% Input parsing/setting default values when no input exists
% input parsing settings
p = inputParser;
p.CaseSensitive = true;
p.Parameters;
p.Results;
p.KeepUnmatched = true;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);

% set the desired and optional input arguments
addRequired(p, 'data1', @iscell);
addRequired(p, 'data2', @iscell);
addRequired(p, 'channelsROI', @iscellstr);          % electrodes can also be chosen by index (not recommended), here we force selection by name
addOptional(p, 'latency', [], @isnumeric);          % default: whole epoch
addOptional(p, 'numberOfPerms', 10000, @isnumeric); % 2,000 for testing things; 5,000-10,000 for final result -- max = 2^Nsubj possible permutations
addOptional(p, 'tails', 0, @isnumeric);             % -1 for negative effects (cond1<cond2), 1 for positive effects, 0 for two-tailed
addOptional(p, 'alphaThresh', .025, @isnumeric);    % use 0.025 (automatically doubled later if one-tailed)

% parse the input
parse(p,data1,data2,varargin{:});
% then set/get all the inputs out of this structure
data1               = p.Results.data1;
data2               = p.Results.data2;
channelsROI         = p.Results.channelsROI;
latency             = p.Results.latency;
numberOfPerms       = p.Results.numberOfPerms;
tails               = p.Results.tails;
alphaThresh         = p.Results.alphaThresh * (1 + abs(tails));   % one-tailed: use 0.05; two-tailed: use 0.025


%% Run the stats

% For using mutliple electrodes:
% 
% 1/ either create neighbours based on the EGI layout if using the channels separately(use this for TCFE):
% /!\ This won't work if some of the inputed data is empty (subj has missing data)
% cfg_neighb = [];
% cfg_neighb.method = 'distance';
% cfg_neighb.neighbourdist = 4; % adjust between 3-5 cm as needed
% neighbours = ft_prepare_neighbours(cfg_neighb, data1{1});
% % Then set up these parameters for clustering
% cfg = [];
% cfg.neighbours = neighbours; % only used if more than one channel selected
% % cfg.layout = 'GSN-HydroCel-129.mat';
% cfg.channel          = channelsROI; % or 'all'


% 2/ or for each subject and condition, average across the channels of interest
for iSubj = length(data1):-1:1
    if ~isempty(data1{iSubj}.avg)
        cfg = [];
        cfg.channel = channelsROI; % or 'all'
        cfg.avgoverchan = 'yes';
        data1_avg{iSubj}   = ft_selectdata(cfg, data1{iSubj});
        data2_avg{iSubj} = ft_selectdata(cfg, data2{iSubj});
    end
end

% Now Select only the non-empty datasets (using the same selection for both
% so we keep the same subjects -- currently, this is redundant but keeping
% it here as well for safety)
data1 = data1_avg(~cellfun(@isempty, data1_avg) & ~cellfun(@isempty, data2_avg));
data2 = data2_avg(~cellfun(@isempty, data2_avg) & ~cellfun(@isempty, data1_avg));
% Then set up these parameters for clustering
cfg = [];

% 3/ then set the rest of the parameters
if ~isempty(latency)
    cfg.latency          = latency;% time window of interest (default: whole epoch; if sat to longer than window: cuts at end of window)
end
cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.numrandomization = numberOfPerms;
cfg.tail             = tails;
cfg.alpha            = alphaThresh;    
cfg.correctm         = 'cluster';  % Use this and the next line for a typical way of calculating the stats
cfg.clusterstatistic = 'maxsum';   % or 'maxsize'
% cfg.correctm         = 'tfce';   % Comment out the last two lines and use this + next 2 lines for a fancier way (not helpful in the end for our data a visit 2)
% cfg.tfce_H           = 2;        % default setting: 2;  decrease to make peak height less important (for noisy peaks)
% cfg.tfce_E           = .75;      % default setting: .5; increase to make time extent more important (for broader peaks)
% Design matrix (for within-subjects)
nsubj = size(data1, 2); % number of subjects
cfg.design = [ones(1,nsubj) ones(1,nsubj)*2; 1:nsubj 1:nsubj];
cfg.ivar   = 1; % row of design matrix with independent variable
cfg.uvar   = 2; % row of design matrix with subject identifier


% 4/ Run the test
[stat] = ft_timelockstatistics(cfg, data1{:}, data2{:});


%% 5/ Figure out the result
% Find contiguous significant time periods
sig_mask = stat.mask; % for single channel, this is 1 x timepoints
% Label connected components (clusters)
% clusters = bwlabel(sig_mask); % requires Image Processing Toolbox
% OR manual approach without toolbox:
diff_mask = diff([0, sig_mask, 0]);
cluster_starts = find(diff_mask == 1);
cluster_ends   = find(diff_mask == -1) - 1;

% Export the clusters to the stat variable
sig_clusters_all = [stat.time(cluster_starts)',stat.time(cluster_ends)'];

n_clusters = length(cluster_starts);
fprintf('Found %d significant cluster(s)\n', n_clusters);

% Extract info for each cluster
for iCluster = 1:n_clusters
    cluster_times = stat.time(cluster_starts(iCluster):cluster_ends(iCluster));
    cluster_stats = stat.stat(cluster_starts(iCluster):cluster_ends(iCluster));
    cluster_prob  = stat.prob(cluster_starts(iCluster):cluster_ends(iCluster));
    
    fprintf('\nCluster %d:\n', iCluster);
    fprintf('  Time range: %.3f to %.3f s (duration: %.0f ms)\n', ...
            min(cluster_times), max(cluster_times), ...
            (max(cluster_times) - min(cluster_times)) * 1000);
    
    % Find peak within this cluster
    [peak_val, peak_idx] = max(cluster_stats); % or max for positive
    p_val     = mean(cluster_prob); % sig level but /!\ not reportable that way for TFCE
    peak_time = cluster_times(peak_idx);
    fprintf('  Peak at %.3f stat = %.2f; p = %.3f)\n', peak_time, peak_val,p_val);
    
    % Store for later analysis
    cluster_info(iCluster).time_range = [min(cluster_times), max(cluster_times)];
    cluster_info(iCluster).peak_time = peak_time;
    cluster_info(iCluster).peak_tfce = peak_val;
end
% Plot TFCE statistic with clusters
figure;
hold on;
% Stats first
plot(stat.time, stat.stat, 'k-', 'LineWidth', 1.5);
% Highlight each cluster in different color
colors = lines(n_clusters);
for iCluster = 1:n_clusters
    cluster_idx = cluster_starts(iCluster):cluster_ends(iCluster); % DOESN'T WORK RIGHT NOW -- to fix, no time for now
    % if stat.time(cluster_idx(2)) - stat.time(cluster_idx(1)) >= 0.05
    %     clusColor = colors(iclus,:);
    % else % clusters under 50ms are excluded -- still plot them but in grey
    %     clusColor = [50 50 50];
    % end
    plot(stat.time(cluster_idx), stat.stat(cluster_idx), '.', ...
         'Color', colors(iCluster,:), 'MarkerSize', 15);
    xline(stat.time(cluster_starts(iCluster)), '--', ...
          sprintf('Cluster %d start', iCluster), 'Color', colors(iCluster,:));
    xline(stat.time(cluster_ends(iCluster)), '--', ...
          sprintf('Cluster %d end', iCluster), 'Color', colors(iCluster,:));
end
xlabel('Time (s)');
ylabel('stat');
title(sprintf('clustering results: %d significant cluster(s)', n_clusters));
legend('test stat', 'Location', 'best');
grid on;


end