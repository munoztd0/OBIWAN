function Instrumental() %Modifica 17/01/2018 DOCE
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
var.experimentalSetup = str2num(input('Are the pyhsiological set up and the olfactometer installed (1= yes or 0 = no) ','s'));
var.instruction = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set the comunication with physiological se4 up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.experimentalSetup
    config_io;
    outp(53240, 0);
    openDevice(); %Open device for handgrip     5
    configureAD(0,1); % configure devie for hand grip
    % Are we in simulation mode ?
    simulationMode = false;
else
    simulationMode = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gustometer stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nPumps = 3;
defltDiameter = 27.5;
defltVolume = 2;
defltRate = 60;
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
    var.instruction1 = 'Dans cette partie de l''étude, nous vous demanderons de presser le capteur de force\n\n afin de déclencher la libération du milkshake\n\n\n\n Appuyez sur un bouton pour continuer';
    var.instruction2a = 'Cette tâche est composée de plusieurs items.\n\n Chaque item dure 12 secondes environ. Pendant cette période de temps, vous êtes libre de\n\n presser le capteur de force quand vous voulez, ne soyez pas préocupé(e) par la vitesse avec\n\nlaquelle vous exercez les pressions. Durant ces 12 secondes, il y aura deux fenêtres\n\ntemporelles particulières de 1 seconde chacune qui apparaîtront de manière aléatoire. Aucun \n\nsignal visuel ne vous indiquera la présence de ces fenêtres temporelles, par contre si pendant \n\nces fenêtres temporelles particulières vous serez en train d''exercer une pression complète sur le\n\ncapteur de force, vous déclencherez  la libération du milkshake.\n\n\n\n Appuyez sur un bouton pour continuer';
    var.instruction2b = 'Essayez d''utiliser votre intuition pour presser pendant les fenêtres temporelles et déclencher\n\n le milkshake !\n\nEntre deux items, il y aura une pause pendant laquelle une croix de fixation sera affichée à\n\nl''écran. A ce moment, vous devrez fixer la croix et relaxer votre main.\n\n\n\n Durant la pause, vous recevrez un rinçage. \n\n\n\n Appuyez sur un bouton pour continuer';
    var.instruction3 ='Maintenant vous aurez un moment pour vous familiariser avec le fonctionnement du capteur \n\n de force. Sur la gauche de l''écran, vous verrez un  thermomètre : la hauteur du mercure de ce\n\n thermomètre variera selon la force que vous exercerez sur le capteur de force.\n\n Chaque fois que vous presserez le capteur de force vous devrez essayer de faire monter le \n\n mercure jusqu''au maximum et immédiatement après le faire redescendre jusqu''au minimum.\n\n Pendant la phase de familiarisation, vous devrez exercer plusieurs pressions sur le capteur de \n\n force pour comprendre son fonctionnement.\n\n\n\n Appuyez sur un bouton pour continuer';
    var.instruction4 =  'Maintenant vous allez accomplir un entraînement avant de commencer la tâche en tant que telle \n\n \n\n Appuyez sur un bouton pour continuer';
    var.instructionA = 'Tout d''abord, nous devons calibrer le capteur de force. Pour ce faire, nous vous demanderons \n\n de tenir le capteur de force sans excercer aucune pression. \n\n Appuyez sur un bouton pour continuer';
    var.instructionB = 'Ensuite, Nous vous demanderons \n\n de presser avec votre force maximale sur le capteur de force \n\n Appuyez sur un bouton pour continuer';
    var.pressez =  'PRESSEZ AVEC VOTRE FORCE MAXIMALE MAITENANT !!! ';
    var.tenez = 'TENEZ LE CAPTEUR DE FORCE SANS EXERCER AUCUNE PRESSION';
    var.calibrationEnd = 'La calibration est terminée, merci';
    var.InstructionEndExperimentation = 'Cette partie de l''étude est terminée';
    var.WarningStart = 'L''étude va démarrer...';
    var.attention = 'Attention !';
    var.cross = '+';
elseif var.instruction == 2
    var.instruction1 = 'English version of instructions';
    var.instruction2 = 'English version of instructions';
    var.instruction3 = 'English version of instructions';
    var.instruction4 =  'English version of instructions';
    var.instructionA = 'English version of instructions';
    var.instructionB = 'English version of instructions';
    var.pressez = 'English version of instructions IN CAPS';
    var.tenez = 'English version of instructions IN CAPS';
    var.calibrationEnd = 'La calibration est terminée, merci';
    var.InstructionEndExperimentation = 'English version of instructions';
    var.WarningStart = 'English version of instructions';
    var.attention = 'attention !!';
    var.cross = '+';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Load variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.SamplingRate = 50;
var.ExpectedNumberOfDataPoints = 12 * var.SamplingRate;
NTrial = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24];
var.RewardNumber = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Trigger Coding System %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.trigPhase = 4;
var.triggerStart = 5;
var.trigTrialStart = 6;
var.triggerEnd = 128;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target.stim = 1;
target.trig = 1;
target.label = 'Milkshake';

Water.stim = 3;
Water.trig = 3;
Water.label = 'Water';
var.Rinse = Water;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               OPEN PST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HideCursor;
PsychDefaultSetup(0);   %1
screenNumber = max(Screen('Screens'));
[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200], [20 20 800 800]);
%[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200]);
HideCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%% Variables for graphical interface %%%%%%%%%%%%%%%%%%%%%%%%%%
var.thermometerImage = imread ('TermometroON.jpg');
var.centralImage = imread('Image1.jpg');
wPtrRect = Screen('Rect',wPtr);
ImageRect = [0 0 200 200];
var.dstRect = CenterRect(ImageRect,wPtrRect);
width = wPtrRect(3);
var.hight = wPtrRect(4);
var.fl = width/18.5;
ft = var.hight/3.02;
var.tr = width/12.5;
var.tb = var.hight/1.1477;
var.Twidth = width/7.5; % 15 with old PC Windows7

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task Instruction %%%%%%%%%%%%%%%%%%%%%%%%%%
showInstructionSimple(wPtr, var.instruction1);
WaitSecs(0.4);
KbWait(-1);

showInstructionSimple(wPtr, var.instruction2a);
WaitSecs(0.4);
KbWait(-1);

showInstructionSimple(wPtr, var.instruction2b);
WaitSecs(0.4);
KbWait(-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calibrate Handgrip %%%%%%%%%%%%%%%%%%%%%%%%%%
[var] = calibrateHandgrip(var,wPtr);
data.maximalforce = var.maximalforce;
data.minimalforce = var.minimalforce;
save(var.resultFile,'data','-append');

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task Instruction %%%%%%%%%%%%%%%%%%%%%%%%%%
showInstructionSimple(wPtr, var.instruction3);
WaitSecs(0.4);
KbWait(-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Familiarization %%%%%%%%%%%%%%%%%%%%%%%%%%
Instrumental_familiarization(var,wPtr);
Screen(wPtr, 'Flip');
showInstructionSimple(wPtr, var.instruction4);
WaitSecs(0.4);
KbWait(-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Training %%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo off all
ITI = 7.5;
randomIndex = randperm(length(ITI));
var.ITI = ITI (randomIndex);
var.time_MRI = GetSecs;
Intrumental_Training(1, var, target, wPtr, pumps, cfg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% MRI Starts %%%%%%%%%%%%%%%%%%%%%%%%%%%%
showInstructionSimple (wPtr,var.WarningStart);
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
data.attention_Durations = showInstruction(wPtr,var.attention,var);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Send Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.experimentalSetup
    [timeOnset,timeFunction] = SendTrigger(var.triggerStart, var);
    data.Onsets.ExperimentStart = timeOnset;
    data.Durations.SendExperimentStart = timeFunction;
    var.ref_end = var.ref_end + timeFunction;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Send Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%
[var, data] = Intrumental_trials(NTrial,var,target,wPtr, pumps, cfg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           ENDING THE EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TriggerStart (var.triggerEnd,var);
WaitSecs(0.03);
TriggerEnd(var);
data.TotalDuration = GetSecs - var.time_MRI;
save(var.resultFile,'data', '-append');

if var.experimentalSetup
    closeDevice 
end

showInstructionSimple(wPtr, var.InstructionEndExperimentation); 
WaitSecs(0.4);
KbWait(-1);

Screen('CloseAll');
ShowCursor;
   
end