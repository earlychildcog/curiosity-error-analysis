% Initialize a gazeParsed struct with all 26 expected fields (empty)

function gazeParsed = fET_InitGazeParsed()

    gazeParsed = struct();

    % --- Numeric double fields ([] placeholder) ---
    gazeParsed.velocity        = [];   % normally Nsamples*1 double
    gazeParsed.hThresh         = [];   % scalar double
    gazeParsed.lThresh         = [];   % scalar double
    gazeParsed.saccStart       = [];   % normally 1*NSacc double
    gazeParsed.saccEnd         = [];   % normally 1*NSacc double
    gazeParsed.fixIdxAllStart  = [];   % normally NFix*1 double
    gazeParsed.fixIdxAllEnd    = [];   % normally NFix*1 double
    gazeParsed.fixAllRoi       = [];   % normally NFix*1 double
    gazeParsed.fixIdxGoodStart = [];   % normally NFix*1 double
    gazeParsed.fixIdxGoodEnd   = [];   % normally NFix*1 double
    gazeParsed.fixGoodRoi      = [];   % normally NFix*1 double
    gazeParsed.lookIdxStart    = [];   % normally NLook*1 double
    gazeParsed.lookIdxEnd      = [];   % normally NLook*1 double
    gazeParsed.lookRoi         = [];   % normally NLook*1 double
    gazeParsed.switchBIdxStart = [];   % normally NSwitch*1 double
    gazeParsed.switchBIdxEnd   = [];   % normally NSwitch*1 double
    gazeParsed.switchAllIdxStart = []; % normally NSwitch*1 double
    gazeParsed.switchAllIdxEnd   = []; % normally NSwitch*1 double
    gazeParsed.nSaccades       = [];   % scalar double
    gazeParsed.nFixations      = [];   % scalar double
    gazeParsed.nLooks          = [];   % scalar double
    gazeParsed.nSwitchesB      = [];   % scalar double
    gazeParsed.nSwitchesAll    = [];   % scalar double

    % --- Logical field ---
    gazeParsed.fixFlagGood     = logical.empty;

    % --- Categorical fields (undefined/missing category) ---
    gazeParsed.sideChosen      = categorical(missing);
    gazeParsed.sideMatch       = categorical(missing);

end