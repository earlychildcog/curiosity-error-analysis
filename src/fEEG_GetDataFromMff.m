function [data, tblEventsAll] = fEEG_GetDataFromMff(path_mff, erpkind, visit_str, opts)

arguments
    path_mff string {mustBeFolder}      % mff "files" are directories
    erpkind string {mustBeMember(erpkind, ["ERN" "FRN" "ERNtest" "FRNtest" "unsegmented_EEG"])} = regexp(path_mff, "[EF]RN", 'match')   % get erp kind for free as long as path contains ERN of FRN strings, else please specify
    visit_str (1,1) string {mustBeMember(visit_str, ["a" "b" "c"])} = regexp(path_mff, 'curE\d\d\d(\w)[\w_]+.mff$', 'tokens', 'once')   % get session for free as long as filenames is of the normally used and expected kind in curE, else please specify
    opts.experiment (1,1) string = "curE";
end

% Don't use '~' for this, fieldtrip errors; replace with home directory and hope it works
if startsWith(path_mff, "~") 
    path_mff = regexprep(path_mff, "^~", getenv('HOME'));
end
% Definitions
experiment = opts.experiment;
eventtype = '';
if experiment == "curE"
    if  erpkind == "ERN" || erpkind == "ERNtest"
        eventtype = 'fixB';
        prestim      = 0.298;         % in seconds
        poststim     = 0.548;         % in seconds
    elseif  erpkind == "FRN" || erpkind == "FRNtest"
        eventtype = 'bcfl';
        prestim      = 0.098;         % in seconds
        poststim     = 1.048;         % in seconds
    end
    % old and new key codes; we need to old codes to make sure that the codes are what we expected. 
    % Because of truncation of codes to 4 letters with no warning, we ended up with key codes with the same names
    % Thus we need to be sure that the order is correct so that we put the correct codes in the correct places when we replace
    % visit 2 keys_old is fixed, visit 1 original mffs are not fixed, some may be fixed if manually done, so, we adjust for all cases:
    keys_old = {["tria","diff","tria","objL","objR","objT","resu","del1","del2","tria","accu","sidM","sidC","keyb"],...
                ["tria","diff","tria","objL","objR","objT","resu","dela","dela","tria","accu","side","side","keyb"]};
    keys_new = ["trialtype","diff","trialno","objL","objR","objT","result","delayExp","delayDec","trial_uid","accu","side_correct","side_chosen","keyb"];
end
assert(~isempty(eventtype), "no valid experiment/erpkind etc chosen")

%% Now use FieldTrip to get what we want
% --- Load the data
cfg = [];
cfg.dataset = path_mff;
% Tell FT what kind of file it's dealing with so it can load the right data
% into the right place in the data & cfg structures
% /!\ use single quotes ' or you get weird bugs if you use "
cfg.headerformat = 'egi_mff_v3';
cfg.dataformat   = 'egi_mff_v3';
cfg.eventformat  = 'egi_mff_v3';
events = ft_read_event(char(cfg.dataset), 'headerformat', cfg.headerformat, 'eventformat', cfg.eventformat,'dataformat',cfg.dataformat);
% Read all the events before epoching the data
% Define our events
cfg.trialfun     = "ft_trialfun_general";  % Default trial function
cfg.trialdef.eventtype = eventtype;
cfg.trialdef.prestim   = prestim;
cfg.trialdef.poststim  = poststim;
% --- Load the layout (we're calling select data but not actually selecting 
% data, just using it to load the layout)
cfg.layout       = 'GSN-HydroCel-129.mat';
[layout, cfg]    = ft_prepare_layout(cfg);
cfg  = ft_definetrial(cfg);
data = ft_preprocessing(cfg);

%% Get metadata from events, and print info to screen
coding = events(cellfun(@isempty, {events.type}));
event_main = events(strcmp(eventtype,{events.type}));
assert(numel(event_main) == size(data.trialinfo, 1), "in %s data has %d trials, metadata %d. Something is amiss", path_mff, size(data.trialinfo, 1), numel(event_main));
tblEventsAll        = table;
tblEventsAll.epoch  = cat(1, coding.epoch);
tblEventsAll.status = string({coding.status}');
tblMainEvent = struct2table(event_main);
% Fix key code names (cf reasons + definitions of the codes above)
kvpairs = cellfun(@(x)[x{:}], regexp(tblMainEvent.mffkeys, '(\w+):\s([^,\]]+)', 'tokens'), 'UniformOutput', false);
for iEvent = 1:numel(kvpairs)
    % Check if keys are the kind we expect them to be
    keys_found = string(kvpairs{iEvent}(1:2:end));
    assert(any(cellfun(@(kexpected)all(keys_found == kexpected), keys_old)), "input events do not match; check to make sure input/output events are as expected and fix the script to account for what the events actually are")
    % Replace keys with new version
    kvpairs{iEvent}(1:2:end) = cellstr("mffkey_" + keys_new);
end
fixed_keys = struct2table(cellfun(@(x)struct(x{:}), kvpairs));
tblMainEvent(:, startsWith(tblMainEvent.Properties.VariableNames, "mff")) = [];
tblMainEvent             = [tblMainEvent, fixed_keys];
tblMainEvent.status      = [];
tblMainEvent.mffkey_accu = str2double(tblMainEvent.mffkey_accu);
tblMainEvent.begintime   = datetime(tblMainEvent.begintime, InputFormat="yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ",TimeZone="Europe/Copenhagen");
tblMainEvent             = convertvars(tblMainEvent, varfun(@iscellstr, tblMainEvent, "OutputFormat","uniform"), 'string');
subjId = regexp(path_mff, experiment + "(\d\d\d)" + visit_str + "_", 'tokens','once');
tblMainEvent.id(:) = subjId;
tblMainEvent.trialno = tblMainEvent.mffkey_trialno; % for backwards compatibility with our code
% Fix missing event markers (rare issue with trigger not sent to EEG box;
% fix to match up with FRN for baselining)
% subject 100 FRN epoch 15 lacks ERN counterpart in session a
% subject 58 FRN epoch 3 lacks ERN counterpart in session a
if strcmp(experiment,'curE')
    if subjId == "058" && erpkind == "ERN" && visit_str == "a"
        tblMainEvent.epoch(3:end) = tblMainEvent.epoch(3:end) + 1;
        tblEventsAll.epoch(3:end) = tblEventsAll.epoch(3:end) + 1;
    elseif  subjId == "100" && erpkind == "ERN" && visit_str == "a"
        tblMainEvent.epoch(15:end) = tblMainEvent.epoch(15:end) + 1;
        tblEventsAll.epoch(15:end) = tblEventsAll.epoch(15:end) + 1;
    end
end
tblMainEvent = tblMainEvent(:, [end-1, end, 1:end-2]);
tblEventsAll = join(tblEventsAll, tblMainEvent, 'Keys','epoch');
% Put some trial metadata in data.trialinfo table
data.trialinfo.id      = tblEventsAll.id;
data.trialinfo.trialno = tblEventsAll.trialno;
if ismember('mffkey_accu', tblEventsAll.Properties.VariableNames)
    data.trialinfo.accu    = tblEventsAll.mffkey_accu;
end
data.trialinfo.status  = tblEventsAll.status;

end