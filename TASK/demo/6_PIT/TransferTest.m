function TransferTest()
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
    simulationMode = false;
else
    simulationMode = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gustometer stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nPumps = 1;
defltDiameter = 27.5;
defltVolume = 1;
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
    var.instruction1 = 'Dans cette partie de l''étude, nous vous demanderons\n\n à nouveau de presser le capteur de force afin d''obtenir du milkshake\n\n\n\n Appuyez sur un bouton pour continuer';
    var.instruction2 = 'Les images vont vous être présentées à nouveau. À chaque présentation, nous vous \n\n demanderons de faire des ‘bonnes pressions’. Celles-ci détermineront la quantité \n\n de milkshake que vous recevrez à la fin de l''expérience. \n\n\n\n Appuyez sur un bouton pour continuer';
    var.instructionA = 'Tout d''abord, nous devons calibrer le capteur de force. Pour ce faire, nous vous demanderons \n\n de tenir le capteur de force sans excercer aucune pression. \n\n Appuyez sur un bouton pour continuer';
    var.instructionB = 'Ensuite, nous vous demanderons \n\n de presser avec votre force maximale sur le capteur de force \n\n Appuyez sur un bouton pour continuer';
    var.pressez = ' PRESSEZ AVEC VOTRE FORCE MAXIMALE MAITENANT !!! \n ';
    var.tenez = ' TENEZ LE CAPTEUR DE FORCE SANS EXERCER AUCUNE PRESSION';
    var.calibrationEnd = 'La calibration est terminée, merci';
    var.InstructionEndExperimentation = 'Cette partie de l''étude est terminée';
    var.WarningStart = 'L''expérience va démarrer...';
    var.attention = 'Attention !!';
    var.cross = '+';
elseif var.instruction == 2
    var.instruction1 = 'Dans cette partie de l''étude, nous vous demanderons à nouveau de presser le capteur de force\n\n afin d''obtenir du milkshake\n\n\n\n';
    var.instruction2 = 'Dans cette partie de l''étude, nous vous demanderons à nouveau de presser le capteur de force\n\n afin d''obtenir du milkshake\n\n\n\n Appuyez sur un bouton pour continuer';
    var.instructionA = 'Tout d''abord, nous devons calibrer le capteur de force. Pour ce faire, nous vous demanderons \n\n de tenir le capteur de force sans excercer aucune pression';
    var.instructionB = 'Ensuite, Nous vous demanderons \n\n de presser avec votre force maximale sur le capteur de force';
    var.pressez = ' PRESSEZ AVEC VOTRE FORCE MAXIMALE MAITENANT !!! \n ';
    var.tenez = ' TENEZ LE CAPTEUR DE FORCE SANS EXERCER AUCUNE PRESSION';
    var.calibrationEnd = 'La calibration est terminée, merci';
    var.InstructionEndExperimentation = 'Cette partie de l''étude est terminée';
    var.WarningStart = 'L''expérience va démarrer...';
    var.attention = 'Attention !!';
    var.cross = '+';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Load variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.SamplingRate = 50;
var.ExpectedNumberOfDataPoints = 12 * var.SamplingRate;
var.odorDuration = 2;
[var.CSplus_image, var.CSminus_image, var.CSBL_image, var.list] = counter(participantID); % we counterbalance the images order according to the participant ID
data.list = var.list;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target.stim = 1;
target.trig = 1;
target.label = 'Milkshake';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               OPEN PST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HideCursor;
PsychDefaultSetup(1);
screenNumber = max(Screen('Screens'));
[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200], [20 20 800 800]);
%[wPtr,rect]=Screen('OpenWindow',screenNumber, [200 200 200]);
HideCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%% Variables for graphical interface %%%%%%%%%%%%%%%%%%%%%%%%%%
var.thermometerImage = imread ('TermometroON.jpg');
var.GeoImage = imread('Image1.jpg');

wPtrRect = Screen('Rect',wPtr); 
ImageRect = [0 0 200 200];
var.dstRect = CenterRect(ImageRect,wPtrRect);
width = wPtrRect(3);
var.hight = wPtrRect(4);
var.fl = width/18.5 ;
ft = var.hight/3.02;
var.tr = width/12.5;
var.tb = var.hight/1.1477;
var.Twidth = width/7.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Task Instruction %%%%%%%%%%%%%%%%%%%%%%%%%%
echo off all
showInstructionSimple(wPtr, var.instruction1);
WaitSecs(0.4);
KbWait(-1);

showInstructionSimple(wPtr, var.instruction2);
WaitSecs(0.4);
KbWait(-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calibrate Handgrip %%%%%%%%%%%%%%%%%%%%%%%%%%
[var] = calibrateHandgrip(var,wPtr);
data.maximalforce = var.maximalforce;
data.minimalforce = var.minimalforce;
save(var.resultFile,'data','-append');

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% PIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%
PITPreparationStart = GetSecs();
var.phase = 3;
var.blockSize = 3;
var.RewardNumber = 0; 
data.PIT.Durations.PITPreparation = GetSecs - PITPreparationStart;
var.ref_end = var.ref_end + data.PIT.Durations.PITPreparation;

for tt = 1:5
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inizialize variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LoopPreparationStart = GetSecs();
    var.CSs = {var.CSplus_image var.CSminus_image var.CSBL_image};
    var.CSsTXT = {'CSplus' 'CSminus' 'BL'};
    var.condition = [1; 2; 3];
    var.ordre = randperm(size(var.CSs,2));
    ITI = [7.5; 8; 8.5];
    randomIndex = randperm(length(ITI));
    var.ITI = ITI(randomIndex);
    data.PIT.Durations.LoopPreparation(tt,1) = GetSecs() - LoopPreparationStart;
    var.ref_end = var.ref_end + data.PIT.Durations.LoopPreparation(tt,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% First miniblock: CS1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [var, data] = cycle (12, var, 1, wPtr, tt, data);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Second miniblock: CS2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [var, data] = cycle (12, var, 2, wPtr, tt, data);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Third miniblock: CS3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [var, data] = cycle (12, var, 3, wPtr, tt, data);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           FAKE REWARD PHASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% showInstruction (wPtr,'Vous allez en nouveau gouter du milkshake,\n\nen fonction des préssions que vous avez exércé');
% WaitSecs(0.4);
% KbWait(-1);
% starttime=GetSecs;
% stopcondition = 0;
% while stopcondition == 0
%     if GetSecs-starttime < 15
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n..');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n...');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n....');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.....');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n......');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.......');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n........');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.........');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n..........');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n...........');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n............');
%         WaitSecs(0.4)
%         showInstruction (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.............');
%     else
%         stopcondition = 1;
%     end
% end

% showInstruction (wPtr,'Felicitations!!\n\nvous avez gagné 24.5 ml de milkshake\n\npour les prochains 30 secondes\n\n');
% WaitSecs(0.4);
% KbWait(-1);
% showInstruction (wPtr,'Recompense: 24.2 ml pour les prochains 30 secondes!\n\n');
% 
% quantity = 1.5;
% timestart = GetSecs;
% send(pumps,cfg,target.stim,quantity);
% GetSecs-timestart

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           REWARD PHASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% ratio = meanCSplus / (meanCSplus + meanCSminu);
% TimingStim = ratio*60; %%%% Envoie la reward pour 60 secondes si le ratio est completement favorable au CSplus, 0 secondes si le ratio est complement favorable au CSminu, 30 secondes si le ratio est 50% / 50% entre CSplus et CSminu
% 
% showInstructionSimple (wPtr,'Vous allez en nouveau gouter du milkshake,\n\nen fonction des préssions que vous avez exércé');
% WaitSecs(0.4);
% KbWait(-1);
% starttime=GetSecs;
% stopcondition = 0;
% while stopcondition == 0
%     if GetSecs-starttime < 10
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n..');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n...');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n....');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.....');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n......');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.......');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n........');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.........');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n..........');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n...........');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n............');
%         WaitSecs(0.2)
%         showInstructionSimple (wPtr,'Attendez encore quelques instant,\n\nnotre algorithme est en train de calculer\n\nla quantité de milkshake vous avez gagné\n\n\n\n.............');
%     else
% %         stopcondition = 1;
% %     end
% % end
% 
% showInstructionSimple (wPtr,char(strcat({'Felicitations!!\n\nvous avez gagné du milk-shake\n\npour les prochains 7.9 secondes\n\n')));
% WaitSecs(0.4);
% KbWait(-1);
% showInstructionSimple (wPtr,char(strcat({'Recompense: Milk-shake pour les prochains '}, num2str(TimingStim), {' secondes!'})));
% 
% pumpNum=target.stim;
% trigger=100;
% quantity=20;
% SendTaste (var,pumps,cfg,pumpNum,trigger,quantity);
% WaitSecs(TimingStim)
% StopTaste(var,pumps,pumpNum);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           FORCE FEEDBACK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

integralCSplus = trapz(data.PIT.mobilizedforce(:,strcmp('CSplus',data.PIT.Cond)')-data.minimalforce);
meanCSplus = mean(integralCSplus);
integralCSminu = trapz(data.PIT.mobilizedforce(:,strcmp('CSminus',data.PIT.Cond)')-data.minimalforce);
meanCSminu =  mean(integralCSminu);
integralbaseline = trapz(data.PIT.mobilizedforce(:,strcmp('BL',data.PIT.Cond)')-data.minimalforce);
meanbaseline =  mean(integralbaseline);

disp('%%%%%%%%%%%%%%%%%%%%%%%')
disp('FEEDBACK FORCE!!!!!!!!!')
disp('%%%%%%%%%%%%%%%%%%%%%%%')
disp('meanCSplus')
disp(meanCSplus)
disp('meanCSminu')
disp(meanCSminu)
disp('meanbaseline')
disp(meanbaseline)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           ENDING THE EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data.TotalDuration = GetSecs - var.time_MRI;
save(var.resultFile,'data', '-append');% Final data

%%% Olfactometer and handgrip
if var.experimentalSetup
    closeDevice % handgrip
end

showInstructionSimple (wPtr, var.InstructionEndExperimentation); % end instructions
WaitSecs(0.4);
KbWait(-1);

Screen('CloseAll');%Close comunication PTB
ShowCursor;

end

function send(pumps,cfg,pumpNum,quantity)
% Let's be sure that this pump exists...
% if pumpNum > nPumps
%     sprintf(...
%         'Attempt to access to pump #%d. Valid pump nums are in [0 .. %d]\n',...
%         pumpNum,nPumps);
%     error(s);
% end
if exist('quantity','var') % if overriding default volume to send
    pumps(pumpNum).volume = quantity;
    q = quantity;
else
    pumps(pumpNum).volume = cfg.pumps(pumpNum).volume;
    q = cfg.pumps(pumpNum).volume;
end
tWait = 60*q/cfg.pumps(pumpNum).rate;
pumps(pumpNum).start;
sleep(tWait);
end

function sleep(t) % t = sleeping duration in seconds
tic;
while toc < t
    drawnow();
end
end