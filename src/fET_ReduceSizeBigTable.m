% Reduce the size of the big whole-group table by saving it into less
% memory heavy variable types

function T = fET_ReduceSizeBigTable(T)
T.run          = [];
T.session      = categorical(T.session);
T.trialtype    = categorical(T.trialtype);
T.difficulty   = categorical(T.difficulty);
T.sideMatch    = categorical(T.sideMatch);
T.sideChosen   = categorical(T.sideChosen);
T.objL         = categorical(T.objL);
T.objR         = categorical(T.objR);
T.objT         = categorical(T.objT);
T.keyboardFlip = logical(T.keyboardFlip);
T.time         = int32(T.time);
T.hdist        = uint16(T.hdist);
T.trial        = uint8(T.trial);
T.trialno      = uint8(T.trialno);
T.trialID      = uint8(T.trialID);
T.result       = int8(T.result);
T.accuracy     = int8(T.accuracy);
T.fixroi       = uint8(T.fixroi);
T.messages     = string(T.messages);

end