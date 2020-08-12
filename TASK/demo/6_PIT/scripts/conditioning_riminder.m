function conditioning_riminder(var, wPtr, rect)

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
% INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Show instructions
showInstruction(wPtr, var.instructionPav);
WaitSecs(0.4);
KbWait(-1);


% Perform the training
for i = 1:length(var.PavCSs)
    for times = 1:3 % Perform every trial 3 times.
        trial(var.PavCSs{i}, var.PavSide{i}, var.PavTrig{i}, var.PavStim{i}, wPtr, rect, 1, var);
    end
    showBaseline(wPtr, rect,var);% Trial performed 3 times, show the baseline
end


% Show the end message
showInstruction(wPtr,var.TextEndConditioning);
WaitSecs(0.4);
KbWait(-1);

end



function trial(cs, side, stim, wPtr, rect, actualIndex, var)

global responseTimes;
global keysPressed;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create textures
csTexture = createTextures(wPtr,cs);
thermoTexture = createTextures (wPtr,var.thermoImage);

csRect = [0 0 200 200]; % Sizes of the CS(m) image (automatically re-sized later), we want the image to be 200x200 pixel
csDstRect = CenterRect(csRect , rect);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SECOND SCREEN: CS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Show CS
Screen('DrawTexture', wPtr, csTexture, [], csDstRect);
Screen('DrawTexture', wPtr, thermoTexture, [], [0 0 var.Twidth  var.hight]);
Screen('Flip', wPtr);

% Wait "randomisation entre 100ms-1000ms (= 0.1s-1s)"
var.csPresentationTime = 0.1+0.9*rand(1,1);
WaitSecs(var.csPresentationTime);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIRD SCREEN: CS with asterix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Show CS
asterix = ('*');
Screen('DrawTexture', wPtr, csTexture, [], csDstRect);
Screen('DrawTexture', wPtr, thermoTexture, [], [0 0 var.Twidth  var.hight]);
DrawFormattedText(wPtr, asterix, 'center', 'center', 0);
Screen('Flip', wPtr);

% Store the moment in which the patch appears.
asterixIsThere = GetSecs;
t2 = GetSecs;

var.responseWindow = 1;

cleanKeyboardMemory;

pressed = 0;
while (t2 - asterixIsThere <= var.responseWindow)
    [keyPressed, ~, keyCode]= KbCheck;
    keysPressed{actualIndex} = KbName(keyCode);
    if ((keyPressed == 1) && (keyCode(KbName('a')) == 1)) % If 'a' is pressed, the others keys are ignored.
        pressed = 1;
        var.reactionTime = GetSecs - asterixIsThere;
        responseTimes(actualIndex) = var.reactionTime;
        break;
    end
    t2 = GetSecs;
end

if (pressed == 0)
    responseTimes(actualIndex) = var.responseWindow; % Once again strange trick, but it works.
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOURTH SCREEN: CS with US
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Show CS  %%%%%%%% with odor
Screen('DrawTexture', wPtr, csTexture, [], csDstRect);
Screen('DrawTexture', wPtr, thermoTexture, [], [0 0 var.Twidth  var.hight]);
asterix = ('*');
DrawFormattedText(wPtr, asterix, 'center', 'center', 0);
Screen('Flip', wPtr);

if var.experimentalSetup
    oStimulus(side, stim);% select odor
    oCommit(); % release odor
    WaitSecs (var.odorDuration); % for 1 second
    oInterStimulus(var.sideISI); % reset the ISI air
    oCommit(); % release ISI air 
end

disp(side);
disp(stim);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIFTH SCREEN: CS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('DrawTexture', wPtr, csTexture, [], csDstRect);
Screen('DrawTexture', wPtr, thermoTexture, [], [0 0 var.Twidth  var.hight]);
Screen('Flip', wPtr);
WaitSecs(howMuchWait(pressed,var));

% Close the no longer needed textures
Screen('Close', csTexture);
Screen('Close', thermoTexture);

end
