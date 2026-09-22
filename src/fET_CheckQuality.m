function [T, Q] = fET_CheckQuality(T, visit, opts)

arguments
    T
    visit
    opts.flagCleanFirst     = true;
end

if opts.flagCleanFirst
    T = fET_CleanUp(T);
end
% -- Quality cleaning: quality flags per subject
T.L = [T.inScreenLx T.inScreenLy];
T.R = [T.inScreenRx T.inScreenRy];
Q = varfun(@(x)[mad(sqrt(diff(x(:,1)).^2 + diff(x(:,2)).^2), 1) mean(isnan(x(:,1)))], T, "InputVariables",["L" "R"], "GroupingVariables",["session" "trial" "period_in_trial" "step_reached" "accuracy" "difficulty"]);
Q.logstdL = log(Q.Fun_L(:,1));
Q.logstdR = log(Q.Fun_R(:,1));
Q.missingL = Q.Fun_L(:,2);
Q.missingR = Q.Fun_R(:,2);
Q.logratio_stdL2R = log(Q.Fun_L(:,1)./Q.Fun_R(:,1));
Q.logratio_missingL2R = log(Q.Fun_L(:,2)./Q.Fun_R(:,2));
Q(:,["Fun_L" "Fun_R" "GroupCount"]) = [];
% -- Quality cleaning: 50% missing values on both eyes
q_thress_missing =[0.5 0.75];
Q.qualityL = (Q.missingL > q_thress_missing(1)) + (Q.missingL > q_thress_missing(2));
Q.qualityR = (Q.missingR > q_thress_missing(1)) + (Q.missingR > q_thress_missing(2));
categories_quality = categorical(["good" "missing_50pc" "missing_75pc"]); % NB 50% will only remain if for both
Q.qualityL = arrayfun(@(x)categories_quality(x+1),Q.qualityL);
Q.qualityR = arrayfun(@(x)categories_quality(x+1),Q.qualityR);
% -- Quality assurance pipeline
% 1/ we removed eye if missing > 75% samples in the last step
% 2/ we remove period of trial if missing > 50% samples in BOTH eyes
Q.qualityL(Q.qualityL == "missing_50pc" & Q.qualityR == "good") = "good";
Q.qualityR(Q.qualityR == "missing_50pc" & Q.qualityL == "good") = "good";
% 3/ we remove eye when abs log ratio mad > threshold (=0.6?) ---> quality relative to the other eye
ratioThreshold = 0.6;
Q.qualityL(Q.qualityL == "good" & Q.qualityR == "good" & Q.logratio_stdL2R > ratioThreshold) = "badratio";
Q.qualityR(Q.qualityR == "good" & Q.qualityL == "good" & Q.logratio_stdL2R < -ratioThreshold) = "badratio";
% --> we average the eyes everywhere else
% -- Back to main table
T = join(T, Q,'Keys',{'session','step_reached','trial','period_in_trial','accuracy','difficulty'});
T.L = [];
T.R = [];
% OPTIONAL plot all sessions/trials/periods
% plot_gaze_trials(T, typeplot="scatter");
% plot_gaze_trials(T, typeplot="trace");
% plot_gaze_trials(T, typeplot="swarm");

end