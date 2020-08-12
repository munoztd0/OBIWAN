function rate = ratingTaste(question,anchorMin, anchorMax, wPtr, rect,var) %% modified on 13.06.2015 by Eva

% Here the VAS scale is presented and the rating are recored. In this
% version of the function the participant has a maximal window time to
% respond: if after 6 sec (var.responseTimeWindow; deadline in the main
% script) the scripts goes on.


timer1 = GetSecs(); % set the timer to avoid extra long answers
% Query the frame duration
ifi = Screen('GetFlipInterval', wPtr);

% Sync us and get a time stamp
vbl = Screen('Flip', wPtr);
waitframes = 1;

% VAS parameters
verticalPosLine = RectHeight(rect) - 250; %% this was 100 before
distanceFromBorderLine = 200; % this was 100 before
horizontalCenterOfTheLine = RectWidth(rect)/2;
cursorPosition = horizontalCenterOfTheLine ;

% Maximum priority level
topPriorityLevel = MaxPriority(wPtr);
Priority(topPriorityLevel);

% The avaliable keys to press (adapted for MRI system)
escapeKey = KbName('3#');%||%  former 'space' that has been adapted to the middle button for the MRI boxes
%escapeKey2 =  KbName('3#');%  former 'space' that has been adapted to the middle button for the MRI boxes
leftKey = KbName('2@'); % former 'LeftArrow'
rightKey = KbName('4$'); % former 'RightArrow'

% Set the amount we want our square to move on each button press
pixelsPerPress = 5;

% This is the cue which determines whether we exit the demo
exitDemo = false;
exitDavid = true

% Loop the animation until the escape key is pressed
while exitDemo == false
    
    % Check the keyboard to see if a button has been pressed
    [~,~, keyCode] = KbCheck;
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey)
        exitDemo = true;
    elseif keyCode(leftKey)
        cursorPosition = cursorPosition - pixelsPerPress;
    elseif keyCode(rightKey)
        cursorPosition = cursorPosition + pixelsPerPress;
    end
    
    % We set bounds to make sure our square doesn't go completely off of
    % the screen
    if cursorPosition < distanceFromBorderLine
        cursorPosition = distanceFromBorderLine;
    elseif cursorPosition > RectWidth(rect) - distanceFromBorderLine
        cursorPosition = RectWidth(rect) - distanceFromBorderLine;
    end
    
    % Draw the image and the VAS.
    draw;
    
    %if it takes more than 6 seconds then exit the script adn record a NAN
    timer2 = GetSecs();
    if timer2-timer1 > var.responseTimeWindow
        displayTooLong(var);
        exitDemo = true;
    end
    
     if exitDavid
         pause(5);
         exitDemo = true;
    end
 
end

% Save the rate of the image
rate = (cursorPosition - 50) / ((RectWidth(rect) - 100) / 100); % even if the participant did not had time to confirm its response that will be recorded


% Function to draw the VAS and the image on screen
    function draw()
        
        % Draw the line
        Screen('DrawLine', wPtr, [0 0 0], distanceFromBorderLine, verticalPosLine, RectWidth(rect) - distanceFromBorderLine, verticalPosLine, 2);
        
        % Print VAS' text
        Screen('TextFont', wPtr, 'Arial');
        Screen('TextStyle', wPtr, 1);
        Screen('TextSize', wPtr, 40); % Maybe find a way to relate the text size and the window size.
        Screen('DrawText', wPtr, '0', distanceFromBorderLine, verticalPosLine - 55); % 15 was 5
        DrawFormattedText(wPtr, anchorMin, distanceFromBorderLine - 30, verticalPosLine + 40, 0);
        Screen('DrawText', wPtr, '100', RectWidth(rect) - distanceFromBorderLine - 12, verticalPosLine - 55); % 15 was 5
        DrawFormattedText(wPtr, anchorMax, RectWidth(rect) - distanceFromBorderLine - 170,verticalPosLine + 40, 0);

        % Print text
        Screen('TextFont', wPtr, 'Arial');
        Screen('TextSize', wPtr, 40);
        Screen('TextStyle', wPtr, 1);
        DrawFormattedText(wPtr, question, 'center', 'center', 0);
        
        % Print confirmation message
        Screen('TextFont', wPtr, 'Arial');
        Screen('TextSize', wPtr, 40);
        Screen('TextStyle', wPtr, 1);
        DrawFormattedText(wPtr, var.pressToContinue, 'center', RectHeight(rect) - 100);
        
        % Draw the cursor with the new position
        Screen('DrawLine', wPtr, [0 0 0], cursorPosition, verticalPosLine - 20, cursorPosition, verticalPosLine + 20, 5);
        
        % Flip to the screen
        vbl  = Screen('Flip', wPtr, vbl + (waitframes - 0.5) * ifi);
    end

    function displayTooLong(var)
        % Screen settings
        Screen('TextFont', wPtr, 'Arial');
        Screen('TextSize', wPtr, 40);
        Screen('TextStyle', wPtr, 1);
        Screen('TextColor',wPtr, [225 0 0]);
        % Print the instruction on the window
        DrawFormattedText(wPtr, var.tooLong, 'center', 'center');
        Screen(wPtr, 'Flip');
        WaitSecs(1);
    end
end