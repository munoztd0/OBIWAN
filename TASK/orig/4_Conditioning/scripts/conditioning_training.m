function conditioning_training(var, wPtr, rect, pumps, cfg)

% Declare the variables responseTimes and keysPressed as global, because of the 'passage
% par référence' that is used in matlab.
global responseTimes;
global keysPressed;
%
% Create the arrays for storing results  yaa
resultArraysLength = length(var.PavCSs)*1*3; % Multiply the CSs' length by 18 because every CS is presented 18 times
[dataPav.csNames, keysPressed] = deal(cell(1, resultArraysLength).'); % Transposing for having a resultArraysLengthx1 cell vector
[dataPav.rounds, responseTimes] = deal(zeros(1, resultArraysLength).'); % Initialize the arrays with zeros + transposing to having a vertical vector.
% Prevents MATLAB from reprinting the source code when the program runs
echo off all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRAINING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.training
    var.time_MRI = GetSecs();
    var.ref_end = 0;
    % Show the warning for the training
    showInstructionSimple(wPtr, var.TextTraining);
    WaitSecs(0.4);
    KbWait(-1);
    
    % Perform the training
    for i = 1:length(var.PavCSs)
        for times = 1:1 % Perform every trial 3 times.
            var = trial(var.PavCSs{i}, 0, var.PavStim{i}, wPtr, rect, 1, var, pumps, cfg);
        end
        showBaselineTraining(wPtr, rect, var);% Trial performed 3 times, show the baseline
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Rinse release %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pumpNum=var.Rinse.stim;
        trigger=var.Rinse.trig;
        quantity=1;
        [~, tFunction] = SendTaste (var,pumps,cfg,pumpNum,trigger,quantity);
        var.ref_end = var.ref_end + tFunction;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Rinse release 1 sec %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        var.ref_end = var.ref_end + 1;
        tFunction = WaitABit(var)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Close rinse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [~, tFunction] = StopTaste(var,pumps,cfg,pumpNum);
        var.ref_end = var.ref_end + tFunction;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Show baseline 11 seconds %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        var.ref_end = var.ref_end + 11;
        tFunction = WaitABit(var)
    end
    
    responseTimes = zeros(size(responseTimes)); % Set to zero all the index of the response time,
end

end

function var = trial(cs, trigger, stim, wPtr, rect, nTrial2, var, pumps, cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage1: prepare trial %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageOne(nTrial2,1) = GetSecs-var.time_MRI;
TrialStageOneStart = GetSecs();
global responseTimes;
global keysPressed;
csTexture = createTextures(wPtr,cs);
thermoTexture = createTextures(wPtr,var.thermoImage);
asterisk = ('*');
csRect = [0 0 200 200]; % Sizes of the CS(m) image (automatically re-sized later), we want the image to be 200x200 pixel
csDstRect = CenterRect(csRect , rect);
Durations.TrialStageOne(nTrial2,1) = GetSecs()-TrialStageOneStart;
var.ref_end = var.ref_end + Durations.TrialStageOne(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage2: show CS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageTwo(nTrial2,1) = GetSecs-var.time_MRI;
csPresentationTime1(nTrial2,1) = 4;
var.ref_end = var.ref_end + csPresentationTime1(nTrial2,1);
[timeFunction] = ShowCS(wPtr, csTexture, thermoTexture, csDstRect, var);
Durations.TrialStageTwo(nTrial2,1) = timeFunction;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage3: show CS + * %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageThree(nTrial2,1) = GetSecs-var.time_MRI;
[timeFunction] = ShowCSandAsterisk(wPtr, csTexture, thermoTexture, asterisk, csDstRect, var);
Durations.TrialStageThree(nTrial2,1) = timeFunction;
var.ref_end = var.ref_end + Durations.TrialStageThree(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage4: flushing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageFour(nTrial2,1) = GetSecs-var.time_MRI;
TrialStageFourStart = GetSecs;
FlushEvents();
Durations.TrialStageFour(nTrial2,1) = GetSecs-TrialStageFourStart;
var.ref_end = var.ref_end + Durations.TrialStageFour(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage5: prepare subject answer %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageFive(nTrial2,1) = GetSecs-var.time_MRI;
TrialStageFiveStart = GetSecs();
asterixIsThere = GetSecs;
t2 = GetSecs;
var.responseWindow = 1;
pressed = 0;
Durations.TrialStageFive(nTrial2,1) = GetSecs()-TrialStageFiveStart;
var.ref_end = var.ref_end + Durations.TrialStageFive(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage6: record subject answer %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageSix(nTrial2,1) = GetSecs-var.time_MRI;
TrialStageSixStart = GetSecs();
while (t2-asterixIsThere <= var.responseWindow)
    [keyPressed, ~, keyCode]= KbCheck;
    keysPressed{nTrial2} = KbName(keyCode);
    if ((keyPressed == 1) && (keyCode(KbName('3#')) == 1))
        pressed = 1;
        var.reactionTime = GetSecs()-asterixIsThere;
        responseTimes(nTrial2)=var.reactionTime;
        break;
    end
    t2 = GetSecs;
end
if (pressed == 0)
    responseTimes(nTrial2) = var.responseWindow; % Once again strange trick, but it works.
end
Durations.TrialStageSix(nTrial2,1) = GetSecs()-TrialStageSixStart;
var.ref_end = var.ref_end + Durations.TrialStageSix(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage7: show CS + * %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageSeven(nTrial2,1) = GetSecs-var.time_MRI;
[timeFunction] = ShowCSandAsterisk(wPtr, csTexture, thermoTexture, asterisk, csDstRect, var);
Durations.TrialStageSeven(nTrial2,1) = timeFunction;
var.ref_end = var.ref_end + Durations.TrialStageSeven(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage8: deliver UCS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageEight(nTrial2,1) = GetSecs-var.time_MRI;
if var.experimentalSetup
    quantity=1; %Taste release is also manually stopped later
    [timeOnset, timeFunction] = SendTaste (var,pumps,cfg,stim,trigger,quantity);
    Onsets.PumpStart (nTrial2,1) = timeOnset;
    Durations.TrialStageEight(nTrial2,1) = timeFunction;
    var.ref_end = var.ref_end + Durations.TrialStageEight(nTrial2,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage9: Wait 1 seconds %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageNine(nTrial2,1) = GetSecs-var.time_MRI;
var.ref_end = var.ref_end + 1;
timeFunction = WaitABit(var);
Durations.TrialStageNine(nTrial2,1) = timeFunction;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage10: Stop the Pump %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageTen(nTrial2,1) = GetSecs-var.time_MRI;
if var.experimentalSetup
    [timeOnset, timeFunction] = StopTaste (var,pumps,cfg,stim);
    Onsets.PumpStop (nTrial2,1) = timeOnset;
    Durations.TrialStageTen(nTrial2,1) = timeFunction;
    var.ref_end = var.ref_end + Durations.TrialStageTen(nTrial2,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage11: Show CS again %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageEleven(nTrial2,1) = GetSecs-var.time_MRI;
trashdata.csPresentationTime2(nTrial2,1) = randsample([2;2.5;3],1);
var.ref_end = var.ref_end + trashdata.csPresentationTime2(nTrial2,1);
[timeFunction] = ShowCSandAsteriskAndWait(wPtr, csTexture, thermoTexture, asterisk, csDstRect, var);
Durations.TrialStageEleven(nTrial2,1) = timeFunction;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage12: Close Textures %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageTwelve(nTrial2,1) = GetSecs-var.time_MRI;
StageTwelveStart = GetSecs();
Screen('Close', csTexture);
Screen('Close', thermoTexture);
Durations.TrialStageTwelve(nTrial2,1) = GetSecs() - StageTwelveStart;
var.ref_end = var.ref_end + Durations.TrialStageTwelve(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage13: Swallow Please! %%%%%%%%%%%%%%%%%%%%%%%%%%%%
Onsets.StageThirten(nTrial2,1) = GetSecs-var.time_MRI;
SwallowPresentation(nTrial2,1) = howMuchWait(pressed,var,trashdata,nTrial2,Durations);
var.ref_end = var.ref_end + SwallowPresentation(nTrial2,1);
Durations.TrialStageThirten(nTrial2,1) = showInstruction (wPtr,'Avalez s''il vous plait',var);
end

function sleep(t) % t = sleeping duration in seconds
tic;
while toc < t
    drawnow();
end
end