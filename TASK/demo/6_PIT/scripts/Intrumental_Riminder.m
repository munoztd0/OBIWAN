function  [var, data] = Intrumental_Riminder(Trial, var, target, wPtr, pumps, cfg, data)
for nTrial = 1:length(Trial)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inizialize variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LoopPreparationStart = GetSecs();
    trigger = CreateTrigger(var);
    rewardcount = 0;
    GustoStartTime = [];
    CloseGustoCheck = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Prepare windows timings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A = [1;2;3];
    idxa = randperm(numel(A));
    a = A(idxa(1:1));
    B = [2.5;3.5;4.5];
    idxb = randperm(numel(B));
    b = B(idxb(1:1));
    c = (10 - (a+b));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Show Image and Thermo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DisplayTermoImage (var, wPtr)
    
    data.InstruRemind.Durations.LoopPreparation(nTrial,1) = GetSecs() - LoopPreparationStart;
    var.ref_end = var.ref_end + data.InstruRemind.Durations.LoopPreparation(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Send Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if var.experimentalSetup
        [timeOnset,timeFunction] = SendTrigger(trigger, var);
        data.InstruRemind.Onsets.SendTriggerTrial(nTrial,1) = timeOnset;
        data.InstruRemind.Durations.SendTriggerTrial(nTrial,1) = timeFunction;
        var.ref_end = var.ref_end + data.InstruRemind.Durations.SendTriggerTrial(nTrial,1);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Trial Procedure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartTrialProcedure = GetSecs();
    data.InstruRemind.Onsets.StartTrial(nTrial,1) = GetSecs-var.time_MRI;
    var.StartTrial = GetSecs;
    data.InstruRemind.Durations.TimeTrialProcedure(nTrial,1) = GetSecs()-TimeStartTrialProcedure;
    var.ref_end = var.ref_end + data.InstruRemind.Durations.TimeTrialProcedure(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% First Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop1 = GetSecs();
    data.InstruRemind.Onsets.FirstLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce1,time1,~,~,GustoStartTime,CloseGustoCheck] = pressingNoReward (a,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps);
    data.InstruRemind.Durations.TimeLoop1(nTrial,1) = GetSecs()-TimeStartLoop1;
    var.ref_end = var.ref_end + data.InstruRemind.Durations.TimeLoop1(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Second Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop2 = GetSecs();
    data.InstruRemind.Onsets.SecondLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce2,time2,rewardcount,tPumpStartR1,tFunction,GustoStartTime,CloseGustoCheck] = pressingReward (rewardcount,target,var, wPtr, pumps, cfg,GustoStartTime,CloseGustoCheck);
    data.InstruRemind.Onsets.tPumpStartR1(nTrial,1) = tPumpStartR1;
    data.InstruRemind.Durations.tPumpStartR1(nTrial,1) = tFunction;
    data.InstruRemind.Durations.TimeLoop2(nTrial,1) = GetSecs()-TimeStartLoop2;
    var.ref_end = var.ref_end + data.InstruRemind.Durations.TimeLoop2(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Third Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop3 = GetSecs();
    data.InstruRemind.Onsets.ThirdLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce3,time3,tPumpCloseR1,tFunction,GustoStartTime,CloseGustoCheck] = pressingNoReward (b,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps);
    data.InstruRemind.Onsets.tPumpCloseR1(nTrial,1) = tPumpCloseR1;
    data.InstruRemind.Durations.tPumpCloseR1(nTrial,1) = tFunction;
    data.InstruRemind.Durations.TimeLoop3(nTrial,1) = GetSecs()-TimeStartLoop3;
    var.ref_end = var.ref_end + data.InstruRemind.Durations.TimeLoop3(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fourth Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop4 = GetSecs();
    data.InstruRemind.Onsets.FourthLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce4,time4,rewardcount,tPumpStartR2,tFunction,GustoStartTime,CloseGustoCheck] = pressingReward (rewardcount,target,var,wPtr, pumps, cfg,GustoStartTime,CloseGustoCheck);
    data.InstruRemind.Onsets.tPumpStartR2(nTrial,1) = tPumpStartR2;
    data.InstruRemind.Durations.tPumpStartR2(nTrial,1) = tFunction;
    data.InstruRemind.Durations.TimeLoop4(nTrial,1) = GetSecs()-TimeStartLoop4;
    var.ref_end = var.ref_end + data.InstruRemind.Durations.TimeLoop4(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fifth Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop5 = GetSecs();
    data.InstruRemind.Onsets.FifthLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce5,time5,tPumpCloseR2,tFunction,GustoStartTime,CloseGustoCheck] = pressingNoReward (c,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps);
    data.InstruRemind.Onsets.tPumpCloseR2(nTrial,1) = tPumpCloseR2;
    data.InstruRemind.Durations.tPumpCloseR2(nTrial,1) = tFunction;
    data.InstruRemind.Durations.TimeLoop5(nTrial,1) = GetSecs()-TimeStartLoop5;
    var.ref_end = var.ref_end + data.InstruRemind.Durations.TimeLoop5(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Flip %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartFlip = GetSecs();
    Screen(wPtr, 'Flip');
    data.InstruRemind.Durations.Flipping(nTrial,1) = GetSecs()-TimeStartFlip;
    var.ref_end = var.ref_end + data.InstruRemind.Durations.Flipping(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ITI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data.InstruRemind.Onsets.ITI (nTrial,1) = GetSecs - var.time_MRI;
    ITI = randsample([7.5;8;8.5],1);
    var.ref_end = var.ref_end + ITI;
    data.InstruRemind.Durations.ITI(nTrial,1) = showInstruction (wPtr, var.cross, var);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data.InstruRemind.Onsets.TrialEnd(nTrial,1) = GetSecs-var.time_MRI;
    SaveTrialStart = GetSecs;
    Mobilizedforce = [mobforce1;mobforce2;mobforce3;mobforce4;mobforce5];
    Time = [time1;time2;time3;time4;time5];
    data.InstruRemind.mobilizedforce(:,nTrial) = Mobilizedforce;
    data.InstruRemind.Time(:,nTrial) = Time;
    data.InstruRemind.Trial(nTrial) = nTrial (1,:);
    data.InstruRemind.RewardedResponses(nTrial) = rewardcount;
    save(var.resultFile, 'data', '-append');
    data.InstruRemind.Durations.SaveTrial(nTrial,1) = GetSecs-SaveTrialStart;
    var.ref_end = var.ref_end + data.InstruRemind.Durations.SaveTrial(nTrial,1);
end
end