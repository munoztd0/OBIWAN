function [mobforce,time,tPumpClose,tFunction,GustoStartTime,CloseGustoCheck] = pressingNoReward (duration,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps)
tPumpClose = NaN;
tFunction = NaN;

% Prepare the loop
Starttime = GetSecs;
NextSampleTime = Starttime;

mfexp = 0;
mobforce = NaN(duration*var.SamplingRate,1);
time = NaN(duration*var.SamplingRate,1);

while GetSecs-Starttime <= duration
    mfexp = mfexp + 1;
    
    %readtime
    time(mfexp) = GetSecs - var.StartTrial;
    
    %read and record mobilized force
    if var.experimentalSetup
        val = readAD(); % define the number according to the value that is displayed with no force in order to have it at 0
    else
        val = rand([1]);
    end
    mobforce(mfexp) = val;
    
    %to set the maximal value as a value that change randomly
    % between 50% and 70%
    idxv = randperm(numel(var.v));
    var.ValMax = var.v (idxv (1:1));
    
    % compute variable for online feedback and Diplay feedback on the screen
    ft = OnlineFeedback(var,val,wPtr);
    displayFeedback(var,ft,wPtr);

    if CloseGustoCheck == 1 && (GetSecs-GustoStartTime) > 1
        %sound(y3,Fs3);
        DisplayTermoImage (var, wPtr)
        pumpNum=target.stim;
        [tPumpClose, tFunction] = StopTaste(var,pumps,pumpNum);
        CloseGustoCheck = 0;
        GustoStartTime = [];
    end
    NextSampleTime = NextSampleTime + 1/var.SamplingRate;
    while GetSecs < NextSampleTime
    end
end
end