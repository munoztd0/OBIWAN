function [var] = conditioning(var, wPtr, rect, pumps, cfg, data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Prepare loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%
LoopPreparationStart = GetSecs();
global responseTimes;
global keysPressed;
data.list = var.list;
resultArraysLength = length(var.PavCSs)*20*1;
[data.csNames, keysPressed] = deal(cell(1, resultArraysLength).');
[data.rounds, responseTimes] = deal(zeros(1, resultArraysLength).');
var = randomizeList(var);
nTrial1 = 0;
nTrial2 = 0;
data.Durations.LoopPreparation = GetSecs()-LoopPreparationStart;
var.ref_end = var.ref_end + data.Durations.LoopPreparation;
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Looping %%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j = 1:20
    RandomizeListStart = GetSecs();
    var = randomizeList(var);
    data.Durations.RandomizeList(j) = GetSecs()-RandomizeListStart;
    var.ref_end = var.ref_end + data.Durations.RandomizeList(j);
    for i = 1:length(var.PavCSs)
        FilePartsStart = GetSecs();
        nTrial1 = nTrial1 + 1;
        [~, csName, ~] = fileparts(var.PavCSs{i});
        PavCond = var.PavCond{i};
        data.Durations.FileParts(nTrial1) = GetSecs()-FilePartsStart;
        var.ref_end = var.ref_end + data.Durations.FileParts(nTrial1);
        for times = 1:1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Prepare trial %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TrialPreparationStart = GetSecs();
            nTrial2 = nTrial2 + 1;
            data.csNames{nTrial2} = csName;
            data.PavCond{nTrial2} = PavCond;
            data.rounds(nTrial2) = times;
            if ismember((data.PavCond {nTrial2}),'CSminus') == 1
                var.triggerTrial(nTrial2) = 16 + var.trigPhase;
            elseif ismember((data.PavCond {nTrial2}),'CSplus') == 1
                var.triggerTrial(nTrial2) = 32 + var.trigPhase;
            end
            data.Durations.TrialPreparation(nTrial2,1) = GetSecs()-TrialPreparationStart;
            var.ref_end = var.ref_end + data.Durations.TrialPreparation(nTrial2,1);
            if times == 1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%% Send Trial Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [timeOnset,timeFunction] = SendTrigger(var.triggerTrial(nTrial1), var);
                data.Onsets.TrialStart(nTrial1,1) = timeOnset;
                data.Durations.SendTriggerStart(nTrial1,1) = timeFunction;
                var.ref_end = var.ref_end + timeFunction;
            end
            [data, var] = trial (var.PavCSs{i}, var.PavTrig{i}, var.PavStim{i}, wPtr, rect, nTrial2, var, pumps, cfg, data);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Send BaseLine Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [timeOnset,timeFunction] = SendTrigger(var.triggerBaseline, var);
        data.Onsets.BaselineStart(nTrial1,1) = timeOnset;
        data.Durations.SendTriggerBaseline(nTrial1,1) = timeFunction;
        var.ref_end = var.ref_end + timeFunction;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Show BaseLine %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        data.Onsets.BaseLineStart(nTrial1,1) = timeOnset;
        timeFunction = showBaseline(wPtr, rect, var);
        data.Durations.PrintBaseline(nTrial1,1) = timeFunction;
        var.ref_end = var.ref_end + timeFunction;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Rinse release %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pumpNum=var.Rinse.stim;
        trigger=var.Rinse.trig;
        quantity=1;
        [timeOnset, timeFunction] = SendTaste (var,pumps,cfg,pumpNum,trigger,quantity);
        data.Onsets.RinseStart(nTrial1,1) = timeOnset;
        data.Durations.SendRinse(nTrial1,1) = timeFunction;
        var.ref_end = var.ref_end + timeFunction;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% 1 seconds of rinse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        var.ref_end = var.ref_end + 1;
        data.Durations.Rinse(nTrial1,1) = WaitABit (var);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Close rinse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [timeOnset, timeFunction] = StopTaste(var,pumps,cfg,pumpNum);
        data.Onsets.RinseStop(nTrial1,1) = timeOnset;
        data.Durations.StopRinse(nTrial1,1) = timeFunction;
        var.ref_end = var.ref_end + timeFunction;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% 11 seconds of Baseline %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        var.ref_end = var.ref_end + 11;
        data.Durations.ShowBaseline(nTrial1,1) = WaitABit (var);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Save %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        data.Onsets.TrialEnd(nTrial1,1) = GetSecs-var.time_MRI;
        SaveTrialStart = GetSecs;
        cd(var.filepath.data);
        save(var.resultFile, 'data', 'responseTimes', 'keysPressed', '-append');
        cd(var.filepath.scripts);
        data.Durations.SaveTrial(nTrial1,1) = GetSecs-SaveTrialStart;
        var.ref_end = var.ref_end + data.Durations.SaveTrial(nTrial1,1);
    end
end
end

function [data, var] = trial(cs, trigger, stim, wPtr, rect, nTrial2, var, pumps, cfg, data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage1: prepare trial %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageOne(nTrial2,1) = GetSecs-var.time_MRI;
TrialStageOneStart = GetSecs();
global responseTimes;
global keysPressed;
csTexture = createTextures(wPtr,cs);
thermoTexture = createTextures(wPtr,var.thermoImage);
asterisk = ('*');
csRect = [0 0 200 200]; % Sizes of the CS(m) image (automatically re-sized later), we want the image to be 200x200 pixel
csDstRect = CenterRect(csRect , rect);
data.Durations.TrialStageOne(nTrial2,1) = GetSecs()-TrialStageOneStart;
var.ref_end = var.ref_end + data.Durations.TrialStageOne(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage2: show CS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageTwo(nTrial2,1) = GetSecs-var.time_MRI;
data.csPresentationTime1(nTrial2,1) = 4;
var.ref_end = var.ref_end + data.csPresentationTime1(nTrial2,1);
[timeFunction] = ShowCS(wPtr, csTexture, thermoTexture, csDstRect, var);
data.Durations.TrialStageTwo(nTrial2,1) = timeFunction;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage3: show CS + * %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageThree(nTrial2,1) = GetSecs-var.time_MRI;
[timeFunction] = ShowCSandAsterisk(wPtr, csTexture, thermoTexture, asterisk, csDstRect, var);
data.Durations.TrialStageThree(nTrial2,1) = timeFunction;
var.ref_end = var.ref_end + data.Durations.TrialStageThree(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage4: flushing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageFour(nTrial2,1) = GetSecs-var.time_MRI;
TrialStageFourStart = GetSecs;
FlushEvents();
data.Durations.TrialStageFour(nTrial2,1) = GetSecs-TrialStageFourStart;
var.ref_end = var.ref_end + data.Durations.TrialStageFour(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage5: prepare subject answer %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageFive(nTrial2,1) = GetSecs-var.time_MRI;
TrialStageFiveStart = GetSecs();
asterixIsThere = GetSecs;
t2 = GetSecs;
var.responseWindow = 1;
pressed = 0;
data.Durations.TrialStageFive(nTrial2,1) = GetSecs()-TrialStageFiveStart;
var.ref_end = var.ref_end + data.Durations.TrialStageFive(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage6: record subject answer %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageSix(nTrial2,1) = GetSecs-var.time_MRI;
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
data.Durations.TrialStageSix(nTrial2,1) = GetSecs()-TrialStageSixStart;
var.ref_end = var.ref_end + data.Durations.TrialStageSix(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage7: show CS + * %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageSeven(nTrial2,1) = GetSecs-var.time_MRI;
[timeFunction] = ShowCSandAsterisk(wPtr, csTexture, thermoTexture, asterisk, csDstRect, var);
data.Durations.TrialStageSeven(nTrial2,1) = timeFunction;
var.ref_end = var.ref_end + data.Durations.TrialStageSeven(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage8: deliver UCS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageEight(nTrial2,1) = GetSecs-var.time_MRI;
if var.experimentalSetup
    quantity=1; %Taste release is also manually stopped later
    [timeOnset, timeFunction] = SendTaste (var,pumps,cfg,stim,trigger,quantity);
    data.Onsets.PumpStart (nTrial2,1) = timeOnset;
    data.Durations.TrialStageEight(nTrial2,1) = timeFunction;
    var.ref_end = var.ref_end + data.Durations.TrialStageEight(nTrial2,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage9: Wait 1 seconds %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageNine(nTrial2,1) = GetSecs-var.time_MRI;
var.ref_end = var.ref_end + 1;
timeFunction = WaitABit(var);
data.Durations.TrialStageNine(nTrial2,1) = timeFunction;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage10: Stop the Pump %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageTen(nTrial2,1) = GetSecs-var.time_MRI;
if var.experimentalSetup
    [timeOnset, timeFunction] = StopTaste (var,pumps,cfg,stim);
    data.Onsets.PumpStop (nTrial2,1) = timeOnset;
    data.Durations.TrialStageTen(nTrial2,1) = timeFunction;
    var.ref_end = var.ref_end + data.Durations.TrialStageTen(nTrial2,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage11: Show CS again %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageEleven(nTrial2,1) = GetSecs-var.time_MRI;
data.csPresentationTime2(nTrial2,1) = randsample([2;2.5;3],1);
var.ref_end = var.ref_end + data.csPresentationTime2(nTrial2,1);
[timeFunction] = ShowCSandAsteriskAndWait(wPtr, csTexture, thermoTexture, asterisk, csDstRect, var);
data.Durations.TrialStageEleven(nTrial2,1) = timeFunction;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage12: Close Textures %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageTwelve(nTrial2,1) = GetSecs-var.time_MRI;
StageTwelveStart = GetSecs();
Screen('Close', csTexture);
Screen('Close', thermoTexture);
data.Durations.TrialStageTwelve(nTrial2,1) = GetSecs() - StageTwelveStart;
var.ref_end = var.ref_end + data.Durations.TrialStageTwelve(nTrial2,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage13: Swallow Please! %%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.Onsets.StageThirten(nTrial2,1) = GetSecs-var.time_MRI;
data.SwallowPresentation(nTrial2,1) = howMuchWait(pressed,var,data,nTrial2,data.Durations);
var.ref_end = var.ref_end + data.SwallowPresentation(nTrial2,1);
data.Durations.TrialStageThirten(nTrial2,1) = showInstruction (wPtr,'Avalez s''il vous plait',var);
end