function InternalState() %Modifica 17/01/2018 DOCE
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
var.instruction = 1;

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
    instruction1 = 'Nous vous proposons maintenant de répondre à quelques questions\n\n\n\n\n\n\n\n Appuyez sur un bouton pour continuer';
    wait = 'Voici les questions...';
    asterix = '*';
    cross = '+';
    one = '1';
    two = '2';
    three = '3';
    End = 'Cette partie de l''étude est terminée, merci !';
    attention = 'Attention !';
    var.howHungry = 'A quel point avez-vous faim?';
    var.anchorMinHungry = 'Pas faim\ndu tout';
    var.anchorMaxHungry = 'Très faim';
    var.howThirsty = 'A quel point avez-vous soif?';
    var.anchorMinThirsty = 'Pas soif\ndu tout';
    var.anchorMaxThirsty = 'Très soif';
    var.howPiss = 'A quel point avez-vous envie d''uriner?';
    var.anchorMinPiss = 'Pas du tout';
    var.anchorMaxPiss = 'Très forte\nenvie';
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
    var.howHungry = 'how pleasant was the taste?';
    var.anchorMinHungry = 'extremely pleasant';
    var.anchorMaxHungry = 'extremely unpleasant';
    var.howThirsty = 'how intense was the taste?';
    var.anchorMinThirsty = 'not Perceived';
    var.anchorMaxThirsty = 'extremely Strong';
    var.howPiss = 'à quel point avez-vous trouvé l''saveur familier?';
    var.anchorMinPiss = 'pas familier';
    var.anchorMaxPiss = 'extrêmement familier';
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialize Variables %%%%%%%%%%%%%%%%%%%%%%%%%%
nTrial = 0;
var.repetitions = 1;
var.lengthBlock = 1;
var.lines = (var.repetitions*var.lengthBlock); %to initialize the variables

data.Hungry = NaN (var.lines,1);
data.Thirsty = NaN (var.lines,1);
data.Piss = NaN (var.lines,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               OPEN PST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HideCursor;
PsychDefaultSetup(1);
screenNumber = max(Screen('Screens'));
%[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200], [20 20 800 800]);
[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200]);

showInstructionSimple (wPtr,instruction1);
WaitSecs(0.4);
KbWait(-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MRI Starts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
showInstructionSimple (wPtr,wait);
triggerscanner = 0;
WaitSecs(0.4);

while ~triggerscanner
    [down secs key d] = KbCheck(-1);
    if (down == 1)
        if strcmp('5%',KbName(key));
            triggerscanner = 1;
        end
    end
    WaitSecs(.01);
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
        for mb = 1:var.lengthBlock % MiniBlock: three repetion of the same taste
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Prepare trial %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TrialPreparationStart = GetSecs;
            nTrial = nTrial + 1;
            data.Trial(nTrial,1) = nTrial;
            data.Durations.TrialPreparation(nTrial,1) = GetSecs-TrialPreparationStart;
            var.ref_end = var.ref_end + data.Durations.TrialPreparation(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Hungry %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.Hungry(nTrial,1) = GetSecs-var.time_MRI;
            timeOnset = GetSecs;
            data.Hungry (nTrial,1) = ratingTaste(var.howHungry,var.anchorMinHungry,var.anchorMaxHungry,wPtr,rect,var);
            timeResponse = GetSecs;
            timeStartFlush = GetSecs;
            FlushEvents();
            timeEndFlush = GetSecs;
            data.Durations.Hungry(nTrial,1) = timeResponse-timeOnset;
            data.Durations.FlushEvents1(nTrial,1) = timeEndFlush-timeStartFlush;
            var.ref_end = var.ref_end + data.Durations.Hungry(nTrial,1) + data.Durations.FlushEvents1(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% InterQuestionBreak %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 0.5;
            data.Durations.IQCross1(nTrial,1)= showInstruction (wPtr, cross, var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Thirsty %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.Thirsty(nTrial,1) = GetSecs-var.time_MRI;
            timeOnset = GetSecs;
            data.Thirsty (nTrial,1) = ratingTaste(var.howThirsty,var.anchorMinThirsty,var.anchorMaxThirsty,wPtr,rect,var);
            timeResponse = GetSecs;
            timeStartFlush = GetSecs;
            FlushEvents();
            timeEndFlush = GetSecs;
            data.Durations.Thirsty(nTrial,1) = timeResponse-timeOnset;
            data.Durations.FlushEvents2(nTrial,1) = timeEndFlush-timeStartFlush;
            var.ref_end = var.ref_end + data.Durations.Thirsty(nTrial,1) + data.Durations.FlushEvents2(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% InterQuestionBreak %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            var.ref_end = var.ref_end + 0.5;
            data.Durations.IQCross2(nTrial,1)= showInstruction (wPtr, cross,var);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Piss %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.Piss(nTrial,1) = GetSecs-var.time_MRI;
            timeOnset = GetSecs;
            data.Piss (nTrial,1) = ratingTaste(var.howPiss,var.anchorMinPiss,var.anchorMaxPiss,wPtr,rect,var);
            timeResponse = GetSecs;
            timeStartFlush = GetSecs;
            FlushEvents();
            timeEndFlush = GetSecs;
            data.Durations.Piss(nTrial,1) = timeResponse-timeOnset;
            data.Durations.FlushEvents3(nTrial,1) = timeEndFlush-timeStartFlush;
            var.ref_end = var.ref_end + data.Durations.Piss(nTrial,1) + data.Durations.FlushEvents3(nTrial,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Save Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            data.Onsets.TrialEnd(nTrial,1) = GetSecs-var.time_MRI;
            SaveTrialStart = GetSecs;
            save(resultFile,'data','-append')
            data.Durations.SaveTrial(nTrial,1) = GetSecs-SaveTrialStart;
            var.ref_end = var.ref_end + data.Durations.SaveTrial(nTrial,1);
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