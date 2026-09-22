% upsample if data was recorded at less than ~2Hz (that's the case
% for ~1/3rd of visit2 especially between Feb and March 2024, but
% also 1 day in December and some saved as 2015 -- due to other
% researchers changing the default settings of the eyetracker,
% unfrotunately went unoticed for a while and have to correct it
% after the fact)

function thisData = fET_upSampleIfNeeded(thisData,t)

if median(diff(t)) > 2.1
    [~, lx, ly] = fET_GazeUpsample(t, thisData.gaze.L(:,1), thisData.gaze.L(:,2));
    [thisData.gaze.t_ms, rx, ry, extra] = fET_GazeUpsample(t, thisData.gaze.R(:,1), thisData.gaze.R(:,2));
    thisData.gaze.L = [lx, ly];
    thisData.gaze.R = [rx, ry];
    thisData.gaze.hdist = upsample(thisData.gaze.hdist,2);
    thisData.gaze.hdist(2:2:(end-1)) = (thisData.gaze.hdist(1:2:(end-2)) + thisData.gaze.hdist(3:2:end))/2;
    thisData.gaze.hdist(extra) = [];
    msg_id = 1:numel(thisData.gaze.message);
    msg = string(nan(numel(thisData.gaze.message)*2, 1));
    msg(1:2:end) = thisData.gaze.message;
    msg(extra) = [];
    thisData.gaze.message = msg;
    thisData.timestamps_RawData_ms = thisData.gaze.t_ms;
end
% Basically just store data under better variable names
hpupildata_cleanup(thisData);

end
