function  Intrumental_Training(Trial,var,target,wPtr,pumps, cfg) %% % modified on the 28.04.2015 by Eva

% This function is only for explanatory proposes it does not recored any value

var.RewardNumber = 2; % this could be 2 for riminder 1 for partial extinvtion and 0 for extinction

for nTrial = 1:length(Trial)
    
    %%%%%%%%%%%%%%%% Variable initialization %%%%%%%%%%%%%%%%%%%%%%
    rewardcount = 0;% variable to count rewarded responses
    GustoStartTime = [];
    CloseGustoCheck = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Prepare windows timings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A = [1;2;3;4;5;6;7;8];
    idxa = randperm(numel(A));
    a = A(idxa(1:1));
    c = (11 - a);
    
    % ShowTermoImage
    DisplayTermoImage (var, wPtr)
    
    %%%%%%%%%%%%%%%%%     TRAINING PROCEDURE     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    var.StartTrial = GetSecs;
    %%% FIRST LOOP
    drift1 = GetSecs();
    [~,~,~,~,GustoStartTime,CloseGustoCheck] = pressingNoReward (a,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps);
    var.drift = GetSecs - drift1;
    
    %%% SECOND LOOP: special 1 s window during which the response is rewarded
    [~,~,rewardcount,~,~,GustoStartTime,CloseGustoCheck] = pressingReward (rewardcount,target,var, wPtr, pumps, cfg,GustoStartTime,CloseGustoCheck);

    %%% THIRD LOOP
    drift1 = GetSecs();
    [~,~,~,~,GustoStartTime,CloseGustoCheck] = pressingNoReward (c,target,var,wPtr,GustoStartTime,CloseGustoCheck,pumps);
    var.drift = (GetSecs - drift1) + var.drift;

    % Preparation new stimuli
    Screen(wPtr, 'Flip');
    
    % Rinse
    pumpNum=var.Rinse.stim;
    trigger=var.Rinse.trig;
    quantity=1;
    [timeOnset, timeFunction] = SendTaste (var,pumps,cfg,pumpNum,trigger,quantity);
    showInstructionSimple (wPtr, '+');
    WaitSecs(1);
    StopTaste(var,pumps,pumpNum);
    
    % ITI
    showInstructionSimple (wPtr, '+');
    ITI = var.ITI(nTrial);
    WaitSecs(ITI);
end
end