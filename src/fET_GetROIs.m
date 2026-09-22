function ROI = fET_GetROIs(opts)

arguments
opts.screenDimensions = [1024 1280];
opts.back_imag        = fullfile("stim","mock-frame.png");          % background image to use
opts.paddingScale     = 1/30; % Set padding, if we want some (else set padding=0) -- using the same padding as during data acquisition: 1/30
opts.YB               = 7.5/10;
opts.YT               = 2.5/10;
opts.CardRadius       = 1/6;
end

% Define ROI size like Psychtoolbox wants it
W  = opts.screenDimensions(2);
H  = opts.screenDimensions(1);
rectCard   = round(repmat([1/4 opts.YB; 3/4 opts.YB; 1/2 opts.YT]', 2, 1).*[W H W H]' + [-1 -1 1 1]'*H*(opts.CardRadius));
% Calculating W and H because Matlab calls rectangles in a different way than psychtoolbox
rectCard(3,:) = rectCard(3,:) - rectCard(1,:);    % height
rectCard(4,:) = rectCard(4,:) - rectCard(2,:);    % width
% Pad the rects
paddingPix    = ceil(opts.paddingScale * opts.screenDimensions(1));
padding_array = [-paddingPix, -paddingPix, 2*paddingPix, 2*paddingPix]; %extend ROIs
rectCard = rectCard + padding_array';
% Define ROI size like Matlab wants it
ROI = ROIclass(rectCard',opts.back_imag, ["L" ;"R"; "T"]);

end
