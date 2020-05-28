function [var, data] = cycle (duration, var, nCycle, wPtr, tt, data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Miniblock Preparation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MiniblockPreparationStart = GetSecs();
var.nCycle = nCycle; % put it in the var structure to compute trigger
namevariable = strcat('Miniblock', num2str(nCycle), 'Preparation');
data.PIT.Durations.(namevariable)(tt,1) = GetSecs - MiniblockPreparationStart;
var.ref_end = var.ref_end + data.PIT.Durations.(namevariable)(tt,1);

for nTrial = 1:var.blockSize % first cycle (miniblock) of three presentation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Miniblock Loop Preparation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    MiniblockLoopPreparationStart = GetSecs();
    CS = imread(var.CSs{var.ordre(nCycle)});
    var.centralImage = CS;
    data.PIT.Cond {tt,(((nCycle-1)*3)+nTrial)} = var.CSsTXT{var.ordre(nCycle)};
    data.PIT.Image {tt,(((nCycle-1)*3)+nTrial)} = var.CSs{var.ordre(nCycle)};
    data.PIT.TriggerOnset(tt,(((nCycle-1)*3)+nTrial)) = CreateTrigger(var);
    data.PIT.Item (tt,(((nCycle-1)*3)+nTrial)) = nTrial (1,:);
    DisplayTermoImage (var, wPtr);
    data.PIT.Durations.MiniblockLoopPreparation(tt, (((nCycle-1)*3)+nTrial)) = GetSecs - MiniblockLoopPreparationStart;
    var.ref_end = var.ref_end + data.PIT.Durations.MiniblockLoopPreparation(tt, (((nCycle-1)*3)+nTrial));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Send Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if var.experimentalSetup
        [timeOnset,timeFunction] = SendTrigger(data.PIT.TriggerOnset(tt, (((nCycle-1)*3)+nTrial)), var);
        data.PIT.Onsets.SendTriggerTrial(tt, (((nCycle-1)*3)+nTrial)) = timeOnset;
        data.PIT.Durations.SendTriggerTrial(tt, (((nCycle-1)*3)+nTrial)) = timeFunction;
        var.ref_end = var.ref_end + data.PIT.Durations.SendTriggerTrial(tt, (((nCycle-1)*3)+nTrial));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Extinction Phase %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TimeStartTrial = GetSecs();
    data.PIT.Onsets.StartTrial(tt, (((nCycle-1)*3)+nTrial)) = GetSecs-var.time_MRI;
    [mobforce,time] = pressingNoRewardExtinction (duration,var,wPtr);
    data.PIT.mobilizedforce(:, (((nCycle-1)*3)+nTrial), tt) = mobforce;
    data.PIT.Time(:, (((nCycle-1)*3)+nTrial), tt) = time;
    data.PIT.Durations.TimeTrial(tt, (((nCycle-1)*3)+nTrial)) = GetSecs()-TimeStartTrial;
    var.ref_end = var.ref_end + data.PIT.Durations.TimeTrial(tt,(((nCycle-1)*3)+nTrial));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ITI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data.PIT.Onsets.ITI (tt,(((nCycle-1)*3)+nTrial)) = GetSecs-var.time_MRI;
    ITI = randsample([7.5;8;8.5],1);
    var.ref_end = var.ref_end + ITI;
    data.PIT.Durations.ITI(tt,(((nCycle-1)*3)+nTrial)) = showInstruction (wPtr, var.cross, var); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data.PIT.Onsets.TrialEnd(tt,(((nCycle-1)*3)+nTrial)) = GetSecs-var.time_MRI;
    SaveTrialStart = GetSecs;
    save(var.resultFile, 'data', '-append');
    data.PIT.Durations.SaveTrial(tt,(((nCycle-1)*3)+nTrial)) = GetSecs-SaveTrialStart;
    var.ref_end = var.ref_end + data.PIT.Durations.SaveTrial(tt,(((nCycle-1)*3)+nTrial));
end
end