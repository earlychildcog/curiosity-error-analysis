function T = fET_FindPeriod(T,markers_steps,periodName)
T.period_in_trial(:) = categorical("-");

for iPhase = 1:length(markers_steps)
    if iPhase < length(markers_steps)
        %% trials that went to the next phase
        period_temp = zeros(size(T,1),1);
        period_temp(contains(T.messages, markers_steps(iPhase)) & T.step_reached > iPhase) = 1;        % mark the beginning of the period with 1
        period_temp(contains(T.messages, markers_steps(iPhase+1)) & T.step_reached > iPhase) = -1;     % mark the start of the next period with -1
        ind_period_temp = cumsum(period_temp) == 1;                                             % `cumsum` should put ones if inside the phase, and 0 outside, as outside the phase the 1s and the -1s cancel out, while inside there is one more 1 
        T.period_in_trial(ind_period_temp) = periodName(iPhase);
    end

    %% trials that stopped at this phase -- also for just the final phase
    period_temp = zeros(size(T,1),1);
    period_temp(contains(T.messages, markers_steps(iPhase)) & T.step_reached == iPhase) = 1;   % mark the beginning of the period
    period_temp(contains(T.messages, "::end:") & T.step_reached == iPhase) = -1;               % mark the end of the trial, as no other period after
    ind_period_temp = cumsum(period_temp) == 1;
    T.period_in_trial(ind_period_temp) = periodName(iPhase);
end
endings = contains(T.messages, "::end:");
T.period_in_trial(endings) = T.period_in_trial([endings(2:end); false]);    % the "::end::" final marker was marked in line 17 as "-" which marked the first period


