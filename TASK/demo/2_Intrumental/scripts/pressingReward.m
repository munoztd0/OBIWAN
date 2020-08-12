function [mobforce,time,rewardcount,tPumpStart,tFunction,GustoStartTime,CloseGustoCheck] = pressingReward (rewardcount,target,var,wPtr, pumps, cfg, GustoStartTime, CloseGustoCheck)   % modified on the 22.04.2015
tPumpStart = NaN;
tFunction = NaN;

% Prepare the loop
Starttime = GetSecs;
NextSampleTime = Starttime;
NoMoreRewardThisTrial = 0;

mfexp = 0;
DurationRewardingWindows = 1;
mobforce = NaN(DurationRewardingWindows*var.SamplingRate,1);
time = NaN(DurationRewardingWindows*var.SamplingRate,1);

while GetSecs-Starttime <= DurationRewardingWindows
    mfexp = mfexp + 1;
    
    %readtime
    time(mfexp) = GetSecs - var.StartTrial;
    
    %read and record mobilized force
    if var.experimentalSetup
        val = readAD(); % define the number according to the value that is displayed with no force in order to have it at 0
    else
        val = rand([1]);
    end
    mobforce(mfexp) = val ;
        
    %to set the maximal value as a value that change randomly
    % between 50% and 70%
    idxv = randperm(numel(var.v));
    var.ValMax = var.v (idxv (1:1));
    
    % compute variable for online feedback and Diplay feedback on the screen
    ft = OnlineFeedback(var,val,wPtr);
    displayFeedback(var,ft,wPtr);
    
    if mobforce(mfexp) >= var.ValMax && CloseGustoCheck == 0 && NoMoreRewardThisTrial == 0
        % Update the results variables
        rewardcount = rewardcount + 1;
        % Display reward and Send TASTE
        GustoStartTime = GetSecs;
        pumpNum=target.stim;
        trigger=target.trig;
        quantity=1; % THE ACTUAL STIMULATION WILL BE STOPPED MANUALLY AFTER 2 SECONDS OF STIMULATION
        [tPumpStart, tFunction] = SendTaste (var,pumps,cfg,pumpNum,trigger,quantity);% Odor Release and record time
        fprintf('Sending %f ml from pump %d\n',quantity,target.stim)
        displayReward(var,ft,wPtr);
        CloseGustoCheck = 1;
    end
    NextSampleTime = NextSampleTime + 1/var.SamplingRate;
    while GetSecs < NextSampleTime
    end
end
end