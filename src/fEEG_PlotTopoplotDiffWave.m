function fig = fEEG_PlotTopoplotDiffWave(Difference_grandavg, timeWin, channelsROI, BL, erptype, visit, z_lim)

fig = figure;
fig.Position(3) = fig.Position(3)*1.2; % make the figure a bit bigger otherwise label for colorbar doesn't fit

cfg.comment            = 'no';
cfg.colorbar           = 'yes';
cfg.colormap           = colormap(linspecer); % change to a print-friendly, colorblind-friendly colormap
cfg.colorbartext       = 'Ampl. (\muV)'; %string indicating the text next to colorbar
% cfg.layout   = layout; % Optional
cfg.xlim               = timeWin; % Pre-stim window
if ~isempty(z_lim)
    cfg.zlim           = z_lim; % colorscale limits
end
% cfg.marker             = 'labels'; %'on', 'labels', 'numbers', 'off'
cfg.markersymbol       = '.'; %channel marker symbol (default = 'o')
% cfg.markercolor        = ; %channel marker color (default = [0 0 0] (black))
cfg.markersize         = 20; %channel marker size (default = 2)
cfg.highlight          = 'on'; %'off', 'on', 'labels', 'numbers'
cfg.highlightchannel   =  channelsROI; %Nx1 cell-array with selection of channels, or vector containing channel indices see FT_CHANNELSELECTION
% cfg.highlightchannel   =  channelsROI+1; %Nx1 cell-array with selection of channels, or vector containing channel indices see FT_CHANNELSELECTION
% cfg.highlight          = 'labels'; %'off', 'on', 'labels', 'numbers'
cfg.highlight          = 'on'; %'off', 'on', 'labels', 'numbers'
cfg.highlightsymbol    = '.'; %highlight marker symbol (default = 'o')
cfg.highlightcolor     = [.99 .99 .99]; % almost white; 1 1 1 not saving figure anymore for some reason??
% cfg.highlightcolor     = [0 0.4470 0.7410]; %highlight marker color (default = [0 0 0] (black))
cfg.highlightsize      = 35; %highlight marker size (default = 6)
% cfg.highlightfontsize  = ; %highlight marker size (default = 8)
cfg.figure             = 'no'; %we create our own figure before and set its size;


ft_topoplotER(cfg, Difference_grandavg);
fontsize(30,'points');
sgtitle(sprintf('%s topography: %.3f to %.3f s',erptype,cfg.xlim(1),cfg.xlim(2)))

end