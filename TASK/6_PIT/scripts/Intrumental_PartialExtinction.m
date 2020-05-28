function Intrumental_PartialExtinction(Trial,var,target,Nloops,wPtr,pumps, cfg) %modified on the 22.04.2015
var.RewardNumber = 1; % partial extinction
var.centralImage = var.GeoImage; % neutral image for instrumental
for nTrial = 1:length(Trial)   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inizialize variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LoopPreparationStart = GetSecs();
    trigger = CreateTrigger(var);
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
    data.PartialExtinction.Onsets.StartTrial(nTrial,1) = GetSecs-var.time_MRI;
    var.StartTrial = GetSecs;
    data.PartialExtinction.Durations.TimeTrialProcedure(nTrial,1) = GetSecs()-TimeStartTrialProcedure;
    var.ref_end = var.ref_end + data.PartialExtinction.Durations.TimeTrialProcedure(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% First Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop1 = GetSecs();
    data.PartialExtinction.Onsets.FirstLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce1,time1,~,~,GustoStartTime,CloseGustoCheck] = pressingNoReward (a,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps);
    data.PartialExtinction.Durations.TimeLoop1(nTrial,1) = GetSecs()-TimeStartLoop1;
    var.ref_end = var.ref_end + data.PartialExtinction.Durations.TimeLoop1(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Second Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop2 = GetSecs();
    data.PartialExtinction.Onsets.SecondLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce2,time2,rewardcount,tPumpStartR1,tFunction,GustoStartTime,CloseGustoCheck] = pressingReward (rewardcount,target,var, wPtr, pumps, cfg,GustoStartTime,CloseGustoCheck);
    data.PartialExtinction.Onsets.tPumpStartR1(nTrial,1) = tPumpStartR1;
    data.PartialExtinction.Durations.tPumpStartR1(nTrial,1) = tFunction;
    data.PartialExtinction.Durations.TimeLoop2(nTrial,1) = GetSecs()-TimeStartLoop2;
    var.ref_end = var.ref_end + data.PartialExtinction.Durations.TimeLoop2(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Third Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartLoop3 = GetSecs();
    data.PartialExtinction.Onsets.ThirdLoop(nTrial,1) = GetSecs-var.time_MRI;
    [mobforce3,time3,tPumpCloseR1,tFunction,GustoStartTime,CloseGustoCheck] = pressingNoReward (c,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps);
    data.PartialExtinction.Onsets.tPumpCloseR1(nTrial,1) = tPumpCloseR1;
    data.PartialExtinction.Durations.tPumpCloseR1(nTrial,1) = tFunction;
    data.PartialExtinction.Durations.TimeLoop3(nTrial,1) = GetSecs()-TimeStartLoop3;
    var.ref_end = var.ref_end + data.PartialExtinction.Durations.TimeLoop3(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Flip %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartFlip = GetSecs();
    Screen(wPtr, 'Flip');
    data.PartialExtinction.Durations.Flipping(nTrial,1) = GetSecs()-TimeStartFlip;
    var.ref_end = var.ref_end + data.PartialExtinction.Durations.Flipping(nTrial,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ITI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data.PartialExtinction.Onsets.ITI (nTrial,1) = GetSecs - var.time_MRI;
    ITI = randsample([7.5;8;8.5],1);
    var.ref_end = var.ref_end + ITI;
    data.PartialExtinction.Durations.ITI(nTrial,1) = showInstruction (wPtr, var.cross, var);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data.PartialExtinction.Onsets.TrialEnd(nTrial,1) = GetSecs-var.time_MRI;
    SaveTrialStart = GetSecs;
    Mobilizedforce = [mobforce1;mobforce2;mobforce3;mobforce4;mobforce5];
    Time = [time1;time2;time3;time4;time5];
    data.PartialExtinction.mobilizedforce(:,nTrial) = Mobilizedforce;
    data.PartialExtinction.Time(:,nTrial) = Time;
    data.PartialExtinction.Trial(nTrial) = nTrial (1,:);
    data.PartialExtinction.RewardedResponses(nTrial) = rewardcount;
    save(var.resultFile, 'data', '-append');
    data.PartialExtinction.Durations.SaveTrial(nTrial,1) = GetSecs-SaveTrialStart;
    var.ref_end = var.ref_end + data.PartialExtinction.Durations.SaveTrial(nTrial,1);
end

end