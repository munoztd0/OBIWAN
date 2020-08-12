function HedonicPleasure() %Modifica 17/01/2018 DOCE111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Preliminary stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PsychDefaultSetup(1);
AssertOpenGL;
KbName('UnifyKeyNames');
KbCheck;
WaitSecs(0.1);
GetSecs;
rng('shuffle');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% prepare experiment structure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.filepath = MakePathStruct();
cd(var.filepath.scripts);
var.experimentalSetup = str2num(input('Are the physiological set up and the olfactometer installed (1= yes or 0 = no) ','s'));
var.instruction = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set the com5unication with physiological se4 up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.experimentalSetup
    config_io;
    outp(53240, 0);
    % Are we in simulation mode ?
    simulationMode = false;
else
    simulationMode = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gustometer stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nPumps = 3;
defltDiameter = 27.5; % mm^2
defltVolume = 1; % cm^3
defltRate = 60; % ml/min.

cfg = struct(...
    'simulationMode',simulationMode,...
    'firstPort',9,...
    'pumps',repmat(...
        struct(...
            'diameter',defltDiameter,...
            'volume',defltVolume,...
            'rate',defltRate),...
        nPumps,1)...
);

for ind = 1:nPumps
    pumps(ind,1) = Pump();
end

for pumpNum = 1:nPumps
    pumps(pumpNum).disconnect();
end

for pumpNum = 1:nPumps
    pumps(pumpNum).simulationMode = cfg.simulationMode;
    fprintf('connecting pump %d\n',pumpNum);
    pumps(pumpNum).connect(...
        cfg.firstPort + pumpNum - 1);
    if pumps(pumpNum).connected
        pumps(pumpNum).volume =...
            cfg.pumps(pumpNum).volume;
        pumps(pumpNum).diameter =...
            cfg.pumps(pumpNum).diameter;
        pumps(pumpNum).rate =...
            cfg.pumps(pumpNum).rate;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Collect Participant and Day %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.SubDate= datestr(now, 24);
data.SubHour= datestr(now, 13);

[resultFile, participantID] = createResultFile(var);

var.participantID = participantID;
resultFile = fullfile (var.filepath.data,resultFile);
var.resultFile = resultFile;

save(var.resultFile,'data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Instructions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.instruction == 1
    instruction1 = 'Vous allez maintenant accomplir une tâche d''évaluation de différents liquides.\n\n Vous recevrez différents liquides et les jugerez \n\n sur différentes échelles allant de 0 à 100 \n\n\n\n\n\n\n\n Appuyez sur un bouton pour continuer';
    instruction2 = 'Attention !!! \n\n La perception de certaines propriétés des liquides peut varier selon le moment\n\n et les conditions dans lesquelles celui-ci est présenté. Pour cette raison, nous vous \n\n demandons d''évaluer les liquides en vous focalisant sur la perception\n\n que vous avez ici et maintenant.\n\n\n\n\n\n\n\n Appuyez sur un bouton pour continuer';
    wait = 'L''étude va commencer...';
    asterix = '*';
    cross = '+';
    one = '1';
    two = '2';
    three = '3';
    End = 'Cette partie de l''étude est terminée, merci !';
    attention = 'Attention !!';
    var.howPleasant = 'A quel point avez-vous trouvé ce liquide agréable?';
    var.anchorMinPleasant = 'Extrêmement\ndésagréable';
    var.anchorMaxPleasant = 'Extrêmement\nagréable';
    var.howIntense = 'A quel point avez-vous trouvé ce liquide intense?';
    var.anchorMinIntense = 'Pas\nperçu';
    var.anchorMaxIntense = 'Extrêmement\nfort';
    var.howFamiliar = 'A quel point avez-vous trouvé ce liquide familier?';
    var.anchorMinFamiliar = 'Pas\nfamilier';
    var.anchorMaxFamiliar = 'Extrêmement\nfamilier';
    var.pressToContinue = 'Bouton du milieu pour continuer';
    var.tooLong = 'Réponse trop lente';
elseif var.instruction == 2
    instruction1 = 'In this part of the experiment you will perform an taste evaluation task\n\nIn this task you will smell different kinds of tastes and you will evaluate \n\n them on different scales going from 0 to 100.\n\n\n\n\n\n\n\n press a button to continue';
    instruction2 = 'Beware !!!\n\n The perception of the tastes can vary across time and the conditions\n\n in which they tastes are perceived.\n\n For this reason, we ask you to evaluate the tastes, by focusing on\n\nthe perception you have here and now.\n\n\n\n\n\n\n\n press a button to continue';
    wait = 'the experiment is about to begin..';
    asterix = '*';
    cross = '+';
    one = '1';
    two = '2';
    three = '3';
    End = 'The experiment is over, thank you !';
    attention = 'attention !!';
    var.howPleasant = 'how pleasant was the taste?';
    var.anchorMinPleasant = 'extremely pleasant';
    var.anchorMaxPleasant = 'extremely unpleasant';
    var.howIntense = 'how intense was the taste?';
    var.anchorMinIntense = 'not Perceived';
    var.anchorMaxIntense = 'extremely Strong';
    var.howFamiliar = 'à quel point avez-vous trouvé l''saveur familier?';
    var.anchorMinFamiliar = 'pas familier';
    var.anchorMaxFamiliar = 'extrêmement familier';
    var.pressToContinue = 'Press the middle button to continue';
    var.tooLong = 'Too Slow';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Load variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.responseTimeWindow = Inf;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Trigger Coding System %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.trigPhase = 0; 
trig.trialStart = 2; 
trig.vanOpen = 30;
trig.scales = 60;
trig.trialEnd = 90;
trig.experimentEnd = 128; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MilkShake.side = [];
MilkShake.stim = 1;
MilkShake.trig = 1;
MilkShake.label = 'Milkshake'; 
MilkShake.trigScales = MilkShake.trig + trig.scales;
MilkShake.trigTrialStart = MilkShake.trig + trig.trialStart;
MilkShake.trigTrialEnd = MilkShake.trig + trig.trialEnd;

Empty.side = [];
Empty.stim = 2;
Empty.trig = 2;
Empty.label = 'Empty';
Empty.trigScales = Empty.trig + trig.scales;
Empty.trigTrialStart = Empty.trig + trig.trialStart;
Empty.trigTrialEnd = Empty.trig + trig.trialEnd;

Water.side = [];
Water.stim = 3;
Water.trig = 3;
Water.label = 'Water';
Water.trigScales = Water.trig + trig.scales;
Water.trigTrialStart = Water.trig + trig.trialStart;
Water.trigTrialEnd = Water.trig + trig.trialEnd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Var Vector %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.Label = {'MilkShake'; 'Empty'};
var.side = [0; 0];
var.stim = [MilkShake.stim; Empty.stim];
var.trigTrialStart = var.stim + trig.trialStart;
var.trig = var.stim + trig.vanOpen;
var.trigScales = var.stim + trig.scales;
var.trigEnd = var.stim + trig.trialEnd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialize Variables %%%%%%%%%%%%%%%%%%%%%%%%%%
nTrial = 0;
var.repetitions = 20;
var.lengthBlock = 1;
var.lines = (length(var.trig)*var.repetitions*var.lengthBlock); %to initialize the variables

data.liking = NaN (var.lines,1);
data.intensity = NaN (var.lines,1);
data.familiarity = NaN (var.lines,1);
data.tasteLabel = cell (var.lines,1);
data.tasteTrigger = NaN (var.lines,1);
data.tasteStim = NaN (var.lines,1);
data.Trial = NaN (var.lines,1);
data.Onsets.TrialStart = NaN (var.lines,1);
data.Onsets.TrialEnd = NaN (var.lines,1);
data.Onsets.PumpStart = NaN (var.lines,1);
data.Onsets.PumpStop = NaN (var.lines,1);
data.Onsets.Scales = NaN (var.lines,1);
data.Onsets.Liking = NaN (var.lines,1);
data.Onsets.Intensity = NaN (var.lines,1);
data.Onsets.Familiarity = NaN (var.lines,1);
data.Onsets.RinseStart = NaN (var.lines,1);
data.Onsets.RinseStop = NaN (var.lines,1);
data.Durations.TrialPreparation = NaN (var.lines,1);
data.Durations.StimulusPreparation = NaN (var.lines,1);
data.Durations.SendTriggerStart = NaN (var.lines,1);
data.Durations.count3 = NaN (var.lines,1);
data.Durations.count2 = NaN (var.lines,1);
data.Durations.count1 = NaN (var.lines,1);
data.Durations.SendTaste = NaN (var.lines,1);
data.Durations.asterix1 = NaN (var.lines,1);
data.Durations.StopTaste = NaN (var.lines,1);
data.Durations.asterix2 = NaN (var.lines,1);
data.Durations.jitter = NaN (var.lines,1);
data.Durations.SendTriggerScales = NaN (var.lines,1);
data.Durations.Liking = NaN (var.lines,1);
data.Durations.FlushEvents1 = NaN (var.lines,1);
data.Durations.IQCross1 = NaN (var.lines,1);
data.Durations.Intensity = NaN (var.lines,1);
data.Durations.FlushEvents2 = NaN (var.lines,1);
data.Durations.IQCross2 = NaN (var.lines,1);
data.Durations.Familiarity = NaN (var.lines,1);
data.Durations.FlushEvents3 = NaN (var.lines,1);
data.Durations.SendRinse = NaN (var.lines,1);
data.Durations.asterix3 = NaN (var.lines,1);
data.Durations.StopRinse = NaN (var.lines,1);
data.Durations.asterix4 = NaN (var.lines,1);
data.Durations.ITI = NaN (var.lines,1);
data.Durations.SaveTrial = NaN (var.lines,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               OPEN PST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HideCursor;
PsychDefaultSetup(1);
screenNumber = max(Screen('Screens'));
[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200], [20 20 800 800]);
%[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200]);

showInstructionSimple (wPtr,instruction1);
WaitSecs(0.4);
KbWait(-1);

showInstructionSimple (wPtr, instruction2);
WaitSecs(0.4);
KbWait(-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MRI Starts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
showInstructionSimple (wPtr,wait);
triggerscanner = 0;
WaitSecs(0.4);
if var.experimentalSetup
    while ~triggerscanner
        [down secs key d] = KbCheck(-1);
        if (down == 1)
            if strcmp('5%',KbName(key));
                triggerscanner = 1;
            end
        end
        WaitSecs(.01);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set Timing Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.time_MRI = GetSecs();
var.ref_end = 0;

var.ref_end = var.ref_end + 2.0;
data.attention_Durations = showInstruction(wPtr,attention,var);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        EXPERIMENTAL PROCEDURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for r = 1: var.repetitions
    RandomStart = GetSecs;
    % We randomize the taste order presentation after every serie repetition
    randomIndex = randperm(length(var.trig));
    var.stim = var.stim (randomIndex);
    var.side = var.side (randomIndex);
    var.trig = var.trig (randomIndex);
    var.trigEnd = var.trigEnd (randomIndex);
    var.Label = var.Label (randomIndex);
    var.trigScales = var.trigScales (randomIndex);
    var.trigTrialStart = var.trigTrialStart (randomIndex);
    data.Durations.Random(r,1) = GetSecs-RandomStart;
    var.ref_end = var.ref_end + data.Durations.Random(r,1);
    for i = 1:length(var.trig);
        for mb = 1:var.lengthBlock; % MiniBlock: three repetion of the same taste
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Prepare trial %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TrialPreparationStart = GetSecs;
            nTrial = nTrial + 1;
            data.Trial(nTrial,1) = nTrial;
            data.Durations.TrialPreparation(nTrial,1) = GetSecs-TrialPreparationStart;
            var.ref_end = var.ref_end + data.Durations.TrialPreparation(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Send Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [timeOnset,timeFunction] = SendTrigger(var.trigTrialStart(i),var); % send trigger and record time
            data.Onsets.TrialStart(nTrial,1) = timeOnset;
            data.Durations.SendTriggerStart(nTrial,1) = timeFunction;
            var.ref_end = var.ref_end + timeFunction;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Prepare stimulus %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            StimulusPreparationStart = GetSecs;
            data.tasteLabel (nTrial) = var.Label(i);
            data.tasteTrigger (nTrial) = var.trig(i);
            data.tasteStim (nTrial) = var.stim (i);
            data.Durations.StimulusPreparation(nTrial,1) = GetSecs-StimulusPreparationStart;
            var.ref_end = var.ref_end + data.Durations.StimulusPreparation(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Count Down three two one %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 1.0;
            data.Durations.count3(nTrial,1) = showInstruction (wPtr, three, var);
            var.ref_end = var.ref_end + 1.0;
            data.Durations.count2(nTrial,1) = showInstruction (wPtr, two, var);
            var.ref_end = var.ref_end + 1.0;
            data.Durations.count1(nTrial,1) = showInstruction (wPtr, one,var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% taste Release %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pumpNum=var.stim(i);
            trigger=var.trig(i);
            quantity=1; % Taste release is also manually stopped later
            [timeOnset, timeFunction] = SendTaste (var,pumps,cfg,pumpNum,trigger,quantity);
            data.Onsets.PumpStart (nTrial,1) = timeOnset;
            data.Durations.SendTaste(nTrial,1) = timeFunction;
            var.ref_end = var.ref_end + timeFunction;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% 1 seconds of stimulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 1;
            data.Durations.asterix1(nTrial,1) = showInstruction (wPtr,asterix,var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Close taste %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [timeOnset, timeFunction] = StopTaste(var,pumps,cfg,pumpNum);
            data.Onsets.PumpStop(nTrial,1) = timeOnset;
            data.Durations.StopTaste(nTrial,1) = timeFunction;
            var.ref_end = var.ref_end + timeFunction;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Taste signal continue for four second %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 4;
            data.Durations.asterix2(nTrial,1) = showInstruction (wPtr,asterix,var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Break before scales: jitter: [3;3.5;4] s %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.Starttjietter(nTrial,1) = GetSecs-var.time_MRI;
            tjietter = randsample([3;3.5;4],1);
            var.ref_end = var.ref_end + tjietter;
            data.Durations.jitter(nTrial,1) = showInstruction (wPtr,'Avalez s''il vous plait!',var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Send trigger before scales %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [timeOnset,timeFunction] = SendTrigger(var.trigScales(i),var);
            data.Onsets.TriggerScales(nTrial,1) = timeOnset;
            data.Durations.SendTriggerScales(nTrial,1) = timeFunction;
            var.ref_end = var.ref_end + timeFunction;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Pleasantness %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.Liking(nTrial,1) = GetSecs-var.time_MRI;
            timeOnset = GetSecs;
            data.liking (nTrial,1) = ratingTaste(var.howPleasant,var.anchorMinPleasant,var.anchorMaxPleasant,wPtr,rect,var);
            timeResponse = GetSecs;
            timeStartFlush = GetSecs;
            FlushEvents();
            timeEndFlush = GetSecs;
            data.Durations.Liking(nTrial,1) = timeResponse-timeOnset;
            data.Durations.FlushEvents1(nTrial,1) = timeEndFlush-timeStartFlush;
            var.ref_end = var.ref_end + data.Durations.Liking(nTrial,1) + data.Durations.FlushEvents1(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% InterQuestionBreak %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 0.5;
            data.Durations.IQCross1(nTrial,1)= showInstruction (wPtr, '', var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Intensity %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.Intensity(nTrial,1) = GetSecs-var.time_MRI;
            timeOnset = GetSecs;
            data.intensity (nTrial,1) = ratingTaste(var.howIntense,var.anchorMinIntense,var.anchorMaxIntense,wPtr,rect,var);
            timeResponse = GetSecs;
            timeStartFlush = GetSecs;
            FlushEvents();
            timeEndFlush = GetSecs;
            data.Durations.Intensity(nTrial,1) = timeResponse-timeOnset;
            data.Durations.FlushEvents2(nTrial,1) = timeEndFlush-timeStartFlush;
            var.ref_end = var.ref_end + data.Durations.Intensity(nTrial,1) + data.Durations.FlushEvents2(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% InterQuestionBreak %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 0.5;
            data.Durations.IQCross2(nTrial,1)= showInstruction (wPtr, '', var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Familiarity %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.Familiarity(nTrial,1) = GetSecs-var.time_MRI;
            timeOnset = GetSecs;
            data.familiarity (nTrial,1) = ratingTaste(var.howFamiliar,var.anchorMinFamiliar,var.anchorMaxFamiliar,wPtr,rect,var);
            timeResponse = GetSecs;
            timeStartFlush = GetSecs;
            FlushEvents();
            timeEndFlush = GetSecs;
            data.Durations.Familiarity(nTrial,1) = timeResponse-timeOnset;
            data.Durations.FlushEvents3(nTrial,1) = timeEndFlush-timeStartFlush;
            var.ref_end = var.ref_end + data.Durations.Familiarity(nTrial,1) + data.Durations.FlushEvents3(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% InterQuestionBreak %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 0.5;
            data.Durations.IQCross3(nTrial,1)= showInstruction (wPtr, '', var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Rinse release %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pumpNum=Water.stim;
            trigger=Water.trig;
            quantity=1;
            [timeOnset, timeFunction] = SendTaste (var,pumps,cfg,pumpNum,trigger,quantity);
            data.Onsets.RinseStart(nTrial,1) = timeOnset;
            data.Durations.SendRinse(nTrial,1) = timeFunction;
            var.ref_end = var.ref_end + timeFunction;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% 1 seconds of rinse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 1;
            data.Durations.asterix3(nTrial,1) = showInstruction (wPtr,cross,var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Close rinse %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [timeOnset, timeFunction] = StopTaste(var,pumps,cfg,pumpNum);
            data.Onsets.RinseStop(nTrial,1) = timeOnset;
            data.Durations.StopRinse(nTrial,1) = timeFunction;
            var.ref_end = var.ref_end + timeFunction;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% ITI: jitter [3;3.5;4] %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.ITI (nTrial,1) = GetSecs - var.time_MRI;
            ITI = randsample([3;3.5;4;4.5;5;5.5;6;6.5;7;7.5;8;8.5;9;9.5;10;10.5;11],1);
            var.ref_end = var.ref_end + ITI;
            data.Durations.ITI(nTrial,1) = showInstruction (wPtr,cross,var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Save Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.TrialEnd(nTrial,1) = GetSecs-var.time_MRI;
            SaveTrialStart = GetSecs;
            save(resultFile,'data','-append')
            data.Durations.SaveTrial(nTrial,1) = GetSecs-SaveTrialStart;
            var.ref_end = var.ref_end + data.Durations.SaveTrial(nTrial,1);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           END OF THE EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
showInstruction (wPtr,End,var);
WaitSecs(0.4);
KbWait(-1);

Screen('CloseAll');

end