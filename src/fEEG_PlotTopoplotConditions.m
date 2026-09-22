function fig = fEEG_PlotTopoplotConditions(data_cell, data_labels, timeWindow, channelsROI, BL, erptype,visit,subjName,z_lim)

fig = figure;
tl  = tiledlayout(1,numel(data_cell));
fig.Position(3) = fig.Position(3)*1.5; % make the figure a bit bigger otherwise label for colorbar doesn't fit

cfg.comment            = 'no';
cfg.colorbar           = 'yes';
cfg.colormap           = colormap(linspecer); % change to a print-friendly, colorblind-friendly colormap
cfg.colorbartext       = 'Amplitude (\muV)'; %string indicating the text next to colorbar
% cfg.layout   = layout; % Optional
cfg.xlim               = timeWindow; % Pre-stim window
if ~isempty(z_lim)
    cfg.zlim           = z_lim; % Pre-stim window
end
% PROBLEM WITH THE ELECTRODES NAMES -- they are all shifted, it
% should start with E1 (not E0) and end with E0 (not E128)
% I could not figure out how to fix this, just don't trust the
% labels and check for E-1 if you are looking for a particular
% electrode.
% cfg.marker             = 'labels'; %'on', 'labels', 'numbers', 'off'
cfg.markersymbol       = '.'; %channel marker symbol (default = 'o')
% cfg.markercolor        = ; %channel marker color (default = [0 0 0] (black))
cfg.markersize         = 10; %channel marker size (default = 2)
cfg.highlight          = 'on'; %'off', 'on', 'labels', 'numbers'
cfg.highlightchannel   =  channelsROI; %Nx1 cell-array with selection of channels, or vector containing channel indices see FT_CHANNELSELECTION
% cfg.highlightchannel   =  channelsROI+1; %Nx1 cell-array with selection of channels, or vector containing channel indices see FT_CHANNELSELECTION
% cfg.highlight          = 'labels'; %'off', 'on', 'labels', 'numbers'
cfg.highlight          = 'on'; %'off', 'on', 'labels', 'numbers'
cfg.highlightsymbol    = '.'; %highlight marker symbol (default = 'o')
cfg.highlightcolor     = [.99 .99 .99]; % almost white; 1 1 1 not saving figure anymore for some reason??
% cfg.highlightcolor     = [0 0.4470 0.7410]; %highlight marker color (default = [0 0 0] (black))
cfg.highlightsize      = 15; %highlight marker size (default = 6)
% cfg.highlightfontsize  = ; %highlight marker size (default = 8)
% cfg.layout             = 'GSN-HydroCel-129.mat';    % this fixes the layout
cfg.figure             = fig; %we create oru our figure before and set its size;


% fFixElecPos = @(data_)setfields(data_,elec=ft_read_sens('GSN-HydroCel-129.sfp')); % this function fixes the electrode labels
% fig = ft_topoplotER(cfg, fFixElecPos(Difference_grandavg));
for k=1:numel(data_cell)
    nexttile
    ft_topoplotER(cfg, data_cell{k});
    title(data_labels{k});
end
sgtitle(sprintf('%s - %s - %d to %dms',subjName,erptype,timeWindow(1)*1000,timeWindow(2)*1000));
fontsize(15,'points');
% sgtitle(sprintf('%s topography: %.3f to %.3f s',erptype,cfg.xlim(1),cfg.xlim(2)))
% saveas(gcf,fullfile(pwd,'Figures',sprintf('Visit%d',visit),sprintf('%s_Topo_Diff_%d_%d_BL_%d_%d',erptype,cfg.xlim(1)*1000,cfg.xlim(2)*1000,BL(1)*1000,BL(2)*1000)),'png');

end