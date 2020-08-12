function  [var, data] = Intrumental_trials (Trial,var,target,wPtr,pumps, cfg)
for nTrial = 1:length(Trial)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inizialize variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LoopPreparationStart = GetSecs();
    trigger = var.trigTrialStart + target.trig;
    rewardcount = 0;
    GustoStartTime = [];
    CloseGustoCheck = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Prepare windows timings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A = [1;2;3;4;5;6;7;8];
    idxa = randperm(numel(A));
    a = A(idxa(1:1));
    c = (11 - a);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Show Image and Thermo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DisplayTermoImage (var, wPtr)
    
    data.Durations.LoopPreparation(nTrial,1) = GetSecs() - LoopPreparationStart;
    var.ref_end = var.ref_end + data.Durations.LoopPreparation(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Send Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if var.experimentalSetup
        [timeOnset,timeFunction] = SendTrigger(trigger, var);
        data.Onsets.SendTriggerTrial(nTrial,1) = timeOnset;
        data.Durations.SendTriggerTrial(nTrial,1) = timeFunction;
        var.ref_end = var.ref_end + data.Durations.SendTriggerTrial(nTrial,1);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Trial Procedure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartTrialProcedure = GetSecs();
    data.Onsets.StartTrial(nTrial,1) = GetSecs-var.time_MRI;
    var.StartTrial = GetSecs;
    data.Durations.TimeTrialProcedure(nTrial,1) = GetSecs()-TimeStartTrialProcedure;
    var.ref_end = var.ref_end + data.Durations.TimeTrialProcedure(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% First Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop1 = GetSecs();
    data.Onsets.FirstLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce1,time1,~,~,GustoStartTime,CloseGustoCheck] = pressingNoReward (a,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps);
    data.Durations.TimeLoop1(nTrial,1) = GetSecs()-TimeStartLoop1;
    var.ref_end = var.ref_end + data.Durations.TimeLoop1(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Second Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop2 = GetSecs();
    data.Onsets.SecondLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce2,time2,rewardcount,tPumpStartR1,tFunction,GustoStartTime,CloseGustoCheck] = pressingReward (rewardcount,target,var, wPtr, pumps, cfg,GustoStartTime,CloseGustoCheck);
    data.Onsets.tPumpStartR1(nTrial,1) = tPumpStartR1;
    data.Durations.tPumpStartR1(nTrial,1) = tFunction;
    data.Durations.TimeLoop2(nTrial,1) = GetSecs()-TimeStartLoop2;
    var.ref_end = var.ref_end + data.Durations.TimeLoop2(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Third Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop3 = GetSecs();
    data.Onsets.ThirdLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce3,time3,tPumpCloseR1,tFunction,GustoStartTime,CloseGustoCheck] = pressingNoReward (c,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps);
    data.Onsets.tPumpCloseR1(nTrial,1) = tPumpCloseR1;
    data.Durations.tPumpCloseR1(nTrial,1) = tFunction;
    data.Durations.TimeLoop3(nTrial,1) = GetSecs()-TimeStartLoop3;
    var.ref_end = var.ref_end + data.Durations.TimeLoop3(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Flip %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartFlip = GetSecs();
    Screen(wPtr, 'Flip');
    data.Durations.Flipping(nTrial,1) = GetSecs()-TimeStartFlip;
    var.ref_end = var.ref_end + data.Durations.Flipping(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Rinse release %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pumpNum=var.Rinse.stim;
    trigger=var.Rinse.trig;
    quantity=1;
    [timeOnset, timeFunction] = SendTaste (var,pumps,cfg,pumpNum,trigger,quantity);
    data.Onsets.RinseStart(nTrial,1) = timeOnset;
    data.Durations.SendRinse(nTrial,1) = timeFunction;
    var.ref_end = var.ref_end + timeFunction;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% 1 seconds of rinse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    var.ref_end = var.ref_end + 1;
    data.Durations.asterix3(nTrial,1) = showInstruction (wPtr,'+',var);
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Close rinse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [timeOnset, timeFunction] = StopTaste(var,pumps,pumpNum);
    data.Onsets.RinseStop(nTrial,1) = timeOnset;
    data.Durations.StopRinse(nTrial,1) = timeFunction;
    var.ref_end = var.ref_end + timeFunction;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% ITI: jitter [3;3.5;4] %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data.Onsets.ITI (nTrial,1) = GetSecs - var.time_MRI;
    ITI = randsample([3;3.5;4;4.5;5;5.5;6;6.5;7;7.5;8;8.5;9;9.5;10;10.5;11],1);
    var.ref_end = var.ref_end + ITI;
    data.Durations.ITI(nTrial,1) = showInstruction (wPtr, var.cross, var);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data.Onsets.TrialEnd(nTrial,1) = GetSecs-var.time_MRI;
    SaveTrialStart = GetSecs;
    Mobilizedforce = [mobforce1;mobforce2;mobforce3];
    Time = [time1;time2;time3];
    data.mobilizedforce(:,nTrial) = Mobilizedforce;
    data.Time(:,nTrial) = Time;
    data.Trial(nTrial) = nTrial (1,:);
    data.RewardedResponses(nTrial) = rewardcount;
    save(var.resultFile, 'data', '-append');
    data.Durations.SaveTrial(nTrial,1) = GetSecs-SaveTrialStart;
    var.ref_end = var.ref_end + data.Durations.SaveTrial(nTrial,1);
end
end