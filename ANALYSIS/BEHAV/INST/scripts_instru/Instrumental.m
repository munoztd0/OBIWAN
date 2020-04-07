function Instrumental() % Script for Instrumental learning 13.06.2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRELIMINATY STUFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AssertOpenGL;% Check for Opengl compatibility, abort otherwise:
KbName('UnifyKeyNames');% Make sure keyboard mapping is the same on all supported operating systems
KbCheck; WaitSecs(0.1); GetSecs;% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure they are loaded and ready

%%%%%%%%%%%%%%%%%% prepare experiment structure %%%%%%%%%%%%%%%%%%%%%%%%%%%

var.filepath = MakePathStruct();
cd(var.filepath.scripts);
%var.experimentalSetup = str2num(input('Are the pyhsiological set up and the olfactometer installed (1= yes or 0 = no) ','s'));
var.experimentalSetup = 1;
%var.instruction = str2num(input('Play the instructions? (1 = French or 2 = English) ','s'));
var.instruction = 1;
%%%%%%%%%%%% Set the comunication with physiological set up %%%%%%%%%%%%%%%

if var.experimentalSetup

    var.ioObj = SetParallelPort();%% Open comunication with paralle port 
    openDevice; %Open device for handgrip
    configureAD(0,1); % configure devie for hand grip
    comport = str2num(input('Enter COMPORT olfactometer','s')); % to insert the right comport each time
    oInit(comport,true); % Open Olfacto library
    
end

%%%%%%%%%%%%%%%%% Insert participant's and collection day data%%%%%%%%%%%%%

% Create the file where storing the results
resultFile = createResultFile(var);
resultFile = fullfile (var.filepath.data,resultFile); %to save the the file in the data directory

var.resultFile = resultFile;

% Date and time informations
data.SubDate= datestr(now, 24); % Use datestr to get the date in the format dd/mm/yyyy
data.SubHour= datestr(now, 13); % Use datestr to get the time in the format hh:mm:ss
save(var.resultFile,'data');% We save immediately the session's informations

%%%%%%%%%%%%%%%%%%%%%%%%%% Load list of variable %%%%%%%%%%%%%%%%%%%%%%%%%%
var.trigPhase = 4; % here insert 8 (CH4) for Pavlovian conditioning and 4 (CH3) for instrumetal phase
var.trigTarget = 2; % chocolate odor is code on CH 2

target.side = 1;
target.stim = 2;

var.sideISI = 1; %right or left according to the setting %
var.odorDuration = 1; % how long do we want the odor to be relased
var.triggerStart = 5; % start has the fMRI
var.triggerEnd = 128; % coded on CH 8

%%%%%%%%%%%%%%%%%%%%%%%%%% Write instructions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if var.instruction == 1 %instruction in French
    
    var.instruction1 = 'Dans cette partie de l''étude, nous vous demanderons à nouveau de presser le capteur de force\n\n afin de déclencher la libération d''une odeur de chocolat\n\n\n\n Appuyez sur la barre d''espace pour continuer à lire les instructions';
    var.instruction2 = 'Cette tâche est composée de plusieurs items.\n\n Chaque item dure 12 secondes environ. Pendant cette période de temps, vous êtes libre de\n\n presser le capteur de force quand vous voulez, ne soyez pas préocupé(e) par la vitesse avec\n\nlaquelle vous exercez les pressions. Durant ces 12 secondes, il y aura trois fenï¿½tres\n\ntemporelles particulières de 1 seconde chacune qui apparaitront de manière aléatoire. Aucun \n\nsignal visuel ne vous indiquera la présence de ces fenêtres temporelles, par contre si pendant \n\nces fenêtres temporelles particulières vous serez en train d''exercer une pression complète sur le\n\ncapteur de force, vous déclencherez  la libération d''une odeur de chocolat.\n\nEssayez d''utiliser votre intuition pour presser pendant les fenêtres temporelles et déclencher\n\n l''odeur de chocolat !\n\nEntre deux items, il y aura une pause pendant laquelle une croix de fixation sera affichée à\n\nl''écran. A ce moment, vous devrez fixer la croix et relaxer votre main.\n\n\n\n Appuyez sur la barre d''espace pour commencer l''étude en tant que telle ';
    var.instruction3 ='Maintenant vous aurez un moment pour vous familiariser avec le fonctionnement du capteur \n\n de force. Sur la gauche de l''écran, vous verrez un  thermomètre: la hauteur du mercure de ce\n\n thermomètre variera selon la force que vous exercerez sur le capteur de force.\n\n Chaque fois que vous presserez le capteur de force vous devrez essayer de faire monter le \n\n mercure jusqu''au maximum et immédiatement après le faire redescendre jusqu''au minimum.\n\n Pendant la phase de familiarisation, vous devrez exercer plusieurs pressions sur le capteur de \n\n force pour comprendre son fonctionnement.\n\n\n\n Appuyez sur la barre « espace » quand vous êtes prêt(e) à commencer.';
    var.instruction4 =  'Maintenant vous allez accomplir un entraînement avant de commencer la tâche en tant que telle \n\n \n\n Appuyez sur la barre « espace » pour commencer l''entraînement.';
    var.instructionA = 'Tout d''abord, nous devons calibrer le capteur de force. Pour ce faire, nous vous demanderons \n\n de tenir le capteur de force sans excercer aucune pression';
    var.instructionB = 'Ensuite, Nous vous demanderons \n\n de presser avec votre force maximale sur le capteur de force';
    var.pressez =  'PRESSEZ AVEC VOTRE FORCE MAXIMALE MAITENANT !!! ';
    var.tenez = 'TENEZ LE CAPTEUR DE FORCE SANS EXERCER AUCUNE PRESSION';
    var.calibrationEnd = 'La calibration est terminée, merci';
    var.InstructionEndExperimentation = 'Cette partie de l''étude est termininée';
    var.wait = 'l''étude va démarrer...';
    
elseif var.instruction == 2 %instruction in English
       
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
    var.wait = 'English version of instructions';
end

%%%%%%%%%%%%%%%%%%%%%% Open comunication with PTB %%%%%%%%%%%%%%%%%%%%%%%%%

PsychDefaultSetup(1);% Here we call some default settings for setting up PTB
screenNumber = max(Screen('Screens')); % check if there are one or two screens and use the second screen if necessary
[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200], [20 20 800 800]); %from the left; from the top; up to the right; up to the bottom
%[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200]); 

%%%%%%%%%%%%%%% Setting parameters and preparing varibles %%%%%%%%%%%%%%%%%

% For the geometrical images
var.GeoImage = imread('Image1.jpg');% read the jpg images


wPtrRect = Screen('Rect',wPtr); % referece rect is the total window
ImageRect = [0 0 200 200];% sizes of the images (automatically re-sized later)
var.dstRect = CenterRect(ImageRect,wPtrRect);% put the image at the center of the screen automaticall

% For the theromometer
var.thermometerImage = imread ('TermometroON.jpg');

% Automatically adapt the images to width and hight of the screen
width = wPtrRect(3);
var.hight = wPtrRect(4);

% Create variable to coordinate for the "mercury feedback"
var.fl = width/18.5 ; % from the left
ft = var.hight/3.02; % from the top
var.tr = width/12.5; % up to the right
var.tb = var.hight/1.1477; % up to the buttom
var.Twidth = width/7.5; % for the theromometer

%%% Display the instructions
showInstruction(wPtr, var.instruction1);
WaitSecs(0.4);
KbWait(-1);

HideCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% calibrate handgrip %%%%%%%%%%%%%%%%%%%%%%%%%%
[var] = calibrateHandgrip(var,wPtr);
data.maximalforce = var.maximalforce;
data.minimalforce = var.minimalforce;

save(var.resultFile,'data','-append'); %save minimal and maximal force

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task Instruction %%%%%%%%%%%%%%%%%%%%%%%%%%%%
showInstruction(wPtr, var.instruction3);
WaitSecs(0.4);
KbWait(-1);

Instrumental_familiarization(var,wPtr); % this last util the spacebar is pressed 

showInstruction(wPtr, var.instruction4);
WaitSecs(0.4);
KbWait(-1);

ITI = [7.5];
randomIndex = randperm(length(ITI));
var.ITI = ITI (randomIndex);
var.time_MRI = GetSecs; % htis is necessary here but will be update later with the real time
Nloops = Intrumental_Training(1,var,target,wPtr);

%%%%%%%%%%%%%%%%%%%%  Warning: the Experiment starts %%%%%%%%%%%%%%%%%%%%%%
showInstruction (wPtr,var.wait);
triggerscanner = 0;

while ~triggerscanner
    [down secs key d] = KbCheck(-1);
    if (down == 1)
        if strcmp('5%',KbName(key)); %% 5 is the fMRI message saying it starts...
            triggerscanner = 1;
        end
    end
    WaitSecs(.01);
end

var.time_MRI = GetSecs;

TriggerStart (var.triggerStart,var); %send starting trigger
WaitSecs(0.03);
TriggerEnd(var);
WaitSecs(0.5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          INSTRUMENTAL CONDITIONING PROCEDURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo off all % Prevents MATLAB from reprinting the source code when the program runs

%NTrial = [1;2;3]; %!keep this as a vector and not a value
%ITI = [7.5; 8; 8.5]; % with these values the minimal ITI = 1.5; maximal
%ITI; = 8.5; average ITI = 8 and the trial will always be 20 s long in
%total

NTrial = [1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24];
ITI = [7.5;7.5;7.5;7.5;7.5;7.5;7.5;7.5; 8; 8; 8; 8; 8; 8; 8; 8; 8.5; 8.5; 8.5; 8.5;8.5; 8.5; 8.5; 8.5];
randomIndex = randperm(length(ITI));
var.ITI = ITI (randomIndex);

Intrumental_trials(Nloops,NTrial,var,target,wPtr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           ENDING THE EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TriggerStart (var.triggerEnd,var); %send ending trigger
WaitSecs(0.03);
TriggerEnd(var);
data.TotalDuration = GetSecs - var.time_MRI;
save(var.resultFile,'data', '-append');% Final data

%%% Olfactometer and handgrip
if var.experimentalSetup
    oClose %olfacto
    closeDevice % handgrip
end

showInstruction(wPtr, var.InstructionEndExperimentation); % end instructions
WaitSecs(0.4);
KbWait(-1);

Screen('CloseAll');% Close comunication PTB
ShowCursor;
   
end