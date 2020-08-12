function time = howMuchWait(pressed, var, data, nTrial2, Durations)

% Auxiliary function that compute how much time show the CS for having
% all the trials performed in 1 secs.

if (pressed == 0)
    time = 7 - Durations.TrialStageOne(nTrial2,1) - Durations.TrialStageThree(nTrial2,1) - Durations.TrialStageFour(nTrial2,1) - Durations.TrialStageFive(nTrial2,1) - Durations.TrialStageSeven(nTrial2,1) - Durations.TrialStageEight(nTrial2,1) - Durations.TrialStageTen(nTrial2,1) - Durations.TrialStageTwelve(nTrial2,1) - data.csPresentationTime2(nTrial2,1) - var.responseWindow;
else
    time = 7 - Durations.TrialStageOne(nTrial2,1) - Durations.TrialStageThree(nTrial2,1) - Durations.TrialStageFour(nTrial2,1) - Durations.TrialStageFive(nTrial2,1) - Durations.TrialStageSeven(nTrial2,1) - Durations.TrialStageEight(nTrial2,1) - Durations.TrialStageTen(nTrial2,1) - Durations.TrialStageTwelve(nTrial2,1) - data.csPresentationTime2(nTrial2,1) - var.reactionTime;
end
end