%% average eyes where possible/where they are booth good

function T = fET_AverageEyesWhenPossible(T)
I_bothgood    = T.qualityL == "good" & T.qualityR == "good";
I_leftgood    = T.qualityL == "good" & T.qualityR ~= "good";
I_rightgood   = T.qualityL ~= "good" & T.qualityR == "good";
I_neithergood = T.qualityL ~= "good" & T.qualityR ~= "good";
T.qualTrial(~I_neithergood) = "include";
T.qualTrial(I_neithergood)  = "reject";
T.qualTrial = categorical(T.qualTrial);

T.X_clean = -ones(size(T,1),1);
T.Y_clean = -ones(size(T,1),1);

T.X_clean(I_bothgood) = mean([T.LxSmooth(I_bothgood),T.RxSmooth(I_bothgood)],2);
T.Y_clean(I_bothgood) = mean([T.LySmooth(I_bothgood),T.RySmooth(I_bothgood)],2);
T.X_clean(I_leftgood) = T.LxSmooth(I_leftgood);
T.Y_clean(I_leftgood) = T.LySmooth(I_leftgood);
T.X_clean(I_rightgood) = T.RxSmooth(I_rightgood);
T.Y_clean(I_rightgood) = T.RySmooth(I_rightgood);
T.X_clean(I_neithergood) = NaN;
T.Y_clean(I_neithergood) = NaN;
end
