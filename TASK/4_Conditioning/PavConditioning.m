function PavConditioning() %Modifica 17/01/2018 DOCE
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
var.training = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set the comunication with physiological se4 up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.experimentalSetup
    config_io;
    outp(57392, 0);
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
    var.TextGeneral1 = 'Dans cette partie de l''étude, vous verrez des images et recevrez des liquides.\n\n Lorsque que vous verrez des \n\n images et que le signe " * " apparaîtra à l''écran,\n\n appuyez sur la touche du milieu (majeur) le plus rapidement possible.\n\n Ceci vous permettra de découvrir \n\n le liquide associé à l''image.\n\n\n\n Appuyez sur un bouton pour continuer ';
    var.TextGeneral2 = 'Le liquide délivré ne dépend pas de la vitesse à laquelle vous appuyez sur la touche.\n\n En effet, si après 1 seconde vous n''avez pas appuyé sur la touche,\n\n le liquide sera délivré de toute manière. \n\n La vitesse à laquelle vous appuyez sur la touche\n\n permettra d''avoir une mesure de l''attention \n\n que vous portez à l''exercice.\n\n\n\n Certaines images sont plus souvent associées avec certains liquides,\n\n ESSAYEZ DE DECOUVRIR QUELLES SONT CES ASSOCIATIONS \n\n\n\n Appuyez sur un bouton pour continuer ';   
    var.TextTraining = 'Positionnez votre majeur gauche sur la touche du milieu (majeur) \n\n et pressez sur un bouton pour commencer l''entraînement.';
    var.WarningStart = 'L''entraînement est fini.\n\n Si vous avez des questions, vous pouvez les poser maintenant.\n\n Si ce n''est pas le cas, nous allons commencer.';
    var.InstructionRating = 'Veuillez évaluer l''agréabilité des images, sur une échelle allant de\n\n\n\n  " extrêmement désagréable"\n\n  à \n\n "extrêmement agréable \n\n\n\n Utilisez les boutons de gauche (annulaire) et droite (index) pour bouger le curseur\n\n et la touche du milieu (majeur) pour confirmer votre réponse.'; 
    var.TextEndConditioning = 'La tâche d''association liquide-image est terminée.\n\n';
    var.textEnd = 'La tâche d''évaluation est terminée\n\n';
    var.attention = 'Attention !!';
elseif var.instruction == 2
    var.TextGeneral = 'Dans cette partie de l''étude, vous verrez des images et recevrez des liquides.\n\n Lorsque que vous verrez des images et que le signe " * " apparaîtra à l''écran,\n\n appuyez sur la touche du milieu (majeur) le plus rapidement possible.\n\n Ceci vous permettra de découvrir le liquide associé à l''image.\n\n\n\n Le liquide délivré ne dépend pas de la vitesse à laquelle vous appuyez sur la touche.\n\n En effet, si après 1 seconde vous n''avez pas appuyé sur la touche,\n\n le liquide sera délivré de toute manière. \n\n La vitesse à laquelle vous appuyez sur la touche\n\n permettra d''avoir une mesure de l''attention que vous portez à l''exercice.\n\n\n\n Certaines images sont plus souvent associées avec certains liquides,\n\n ESSAYEZ DE DECOUVRIR QUELLES SONT CES ASSOCIATIONS ';
    var.TextTraining = 'Positionnez votre majeur gauche sur la touche du milieu (majeur) \n\n et pressez sur un bouton pour commencer l''entraînement.';
    var.WarningStart = 'L''entraînement est fini.\n\n Si vous avez des questions, vous pouvez les poser maintenant.\n\n Si ce n''est pas le cas, nous allons commencer.';
    var.InstructionRating = 'Veuillez évaluer l''agréabilité des images, sur une échelle allant de\n\n\n\n  " extrêmement désagréable"\n\n  à \n\n "extrêmement agréable \n\n\n\n Utilisez les boutons de gauche (annulaire) et droite (index) pour bouger le curseur\n\n et la touche du milieu (majeur) pour confirmer votre réponse'; 
    var.TextEndConditioning = 'La tâche d''association liquide-image est terminée.\n\n';
    var.textEnd = 'La tâche d''évaluation est terminée\n\n';
    var.attention = 'Attention !!';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Load variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.tasteDuration = 4;
[var.CSplus_image, var.CSminus_image, var.CSBL_image, var.list] = counter(participantID); % we counterbalance the images order according to the participant ID

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Trigger Coding System %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.trigPhase = 0;
var.triggerStart = 5;
var.triggerTrial = 0;
var.vanOpen = 30;
var.trialEnd = 90;
var.triggerBaseline = 64;
var.experimentEnd = 128;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target.stim = 1;
target.trig = 1;
target.label = 'Milkshake'; 

empty.stim = 2;
empty.trig = 2;
empty.label = 'empty';

Water.stim = 3;
Water.trig = 3;
Water.label = 'Water';

%%%%%%%%%%%%%%%%%%%%%%%%%% Create List %%%%%%%%%%%%%%%%%%%%%%%%%%
var.PavCSs = {var.CSplus_image; var.CSminus_image};
var.PavCond = {'CSplus'; 'CSminus'};
var.PavStim = {[target.stim];[empty.stim]};
var.PavTrig = {[target.trig];[empty.trig]};
var.Rinse = Water;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               OPEN PST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HideCursor;
PsychDefaultSetup(1);
screenNumber = max(Screen('Screens'));
%[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200], [20 20 800 800]);
[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200]);
HideCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%% Variables for graphical interface %%%%%%%%%%%%%%%%%%%%%%%%%%
var.thermoImage = 'ThermeterOFF.jpg';
wPtrRect = Screen('Rect',wPtr);
width = wPtrRect(3);
var.Twidth = width/7.5;
var.hight = wPtrRect(4);

%%%%%%%%%%%%%%%%%%%%%%%%%% Training %%%%%%%%%%%%%%%%%%%%%%%%%%
echo off all

showInstructionSimple(wPtr, var.TextGeneral1);
WaitSecs(0.4); 
KbWait(-1);

showInstructionSimple(wPtr, var.TextGeneral2);
WaitSecs(0.4); 
KbWait(-1);

conditioning_training(var, wPtr, rect, pumps, cfg);

%%%%%%%%%%%%%%%%%%%%%%%%%% MRI Starts %%%%%%%%%%%%%%%%%%%%%%%%%%
showInstructionSimple (wPtr,var.WarningStart);
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
data.attention_Durations = showInstruction(wPtr,var.attention,var);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Send Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.experimentalSetup
    [timeOnset,timeFunction] = SendTrigger(var.triggerStart, var); % send trigger and record time
    data.Onsets.ExperimentStart = timeOnset;
    data.Durations.SendExperimentStart = timeFunction;
    var.ref_end = var.ref_end + timeFunction;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Conditioning %%%%%%%%%%%%%%%%%%%%%%%%%%%%
[var] = conditioning (var, wPtr, rect, pumps, cfg, data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Send Trigger %%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.experimentalSetup
    [timeOnset,timeFunction] = SendTrigger(var.experimentEnd, var); % send trigger and record time
    data.Onsets.ExperimentEnd = timeOnset;
    data.Durations.SendExperimentEnd = timeFunction;
    var.ref_end = var.ref_end + timeFunction;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% End Conditioning %%%%%%%%%%%%%%%%%%%%%%%%%%%%
showInstructionSimple(wPtr,var.TextEndConditioning);
WaitSecs(0.4);
KbWait(-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Conditioning Check %%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.CheckCSs = {var.CSplus_image var.CSminus_image var.CSBL_image};
var.CheckCond = {'CSplus'  'CSminus'  'BL'};
var = randomizeList2(var);
showInstructionSimple(wPtr, var.InstructionRating);
WaitSecs(0.4);
KbWait(-1);
[ratingResult, imagesName, imagesCond] = rating (var.CheckCSs, var.CheckCond, wPtr, rect);
PavCheck.ratings = ratingResult;
PavCheck.imagesName = imagesName;
PavCheck.imagesCond = imagesCond;
cd(var.filepath.data);
save(var.resultFile,'PavCheck','-append'); 
cd(var.filepath.scripts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Experiment End %%%%%%%%%%%%%%%%%%%%%%%%%%%%
showInstructionSimple(wPtr, var.textEnd );
WaitSecs(0.4);
KbWait(-1);
Screen('CloseAll');
ShowCursor;

end