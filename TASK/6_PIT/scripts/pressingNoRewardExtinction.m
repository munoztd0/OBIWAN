function [mobforce,time] = pressingNoRewardExtinction (duration,var,wPtr)
% Prepare the loop
Starttime = GetSecs;
NextSampleTime = Starttime;

mobforce = NaN(duration*var.SamplingRate,1);
time = NaN(duration*var.SamplingRate,1);
mfexp = 0;
var.StartTrial = GetSecs;

while GetSecs-Starttime <= duration
    mfexp = mfexp + 1;
    
    % readtime
    time(mfexp) = GetSecs - var.StartTrial;
    
    % read and record mobilized force
    if var.experimentalSetup
        val = readAD(); % define the number according to the value that is displayed with no force in order to have it at 0
    else
        val = rand([1]);
    end
    mobforce(mfexp) = val;
    
    % to set the maximal value as a value that change randomly
    % between 50% and 70%
    idxv = randperm(numel(var.v));
    var.ValMax = var.v (idxv (1:1));
    
    % compute variable for online feedback and Diplay feedback on the screen
    ft = OnlineFeedback(var,val,wPtr);
    displayFeedbackExtinction(var,ft,wPtr);
    
    NextSampleTime = NextSampleTime + 1/var.SamplingRate;
    while GetSecs < NextSampleTime
    end
end
Screen(wPtr, 'Flip');
end