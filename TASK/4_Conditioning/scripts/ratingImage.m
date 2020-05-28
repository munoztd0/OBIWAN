function rate = ratingImage(image, wPtr, rect) %% modified on the 28.04.2015 by Eva and Vanessa
% Load image and create texture
[~, imageName, imageExt] = fileparts(image);
image = imread(strcat(imageName, imageExt));
imageTexture = Screen('MakeTexture', wPtr, image);

% Define the image rect and the destination rect
imageRect = [0 0 RectWidth(rect) (RectHeight(rect) - 100)];
imageDestRect = CenterRect([0 0 200 200], imageRect); %%%%%%%%%%%%%%%%% modified by Eva

% Query the frame duration
ifi = Screen('GetFlipInterval', wPtr);

% Sync us and get a time stamp
vbl = Screen('Flip', wPtr);
waitframes = 1;

% VAS parameters
verticalPosLine = RectHeight(rect) - 250;
distanceFromBorderLine = 200;
horizontalCenterOfTheLine = RectWidth(rect)/2;
cursorPosition = horizontalCenterOfTheLine ;

% Maximum priority level
topPriorityLevel = MaxPriority(wPtr);
Priority(topPriorityLevel);

% The avaliable keys to press (adapted for MRI system)
escapeKey = KbName('3#');%||%  former 'space' that has been adapted to the middle button for the MRI boxes
leftKey = KbName('2@'); % former 'LeftArrow'
rightKey = KbName('4$'); % former 'RightArrow'


% Set the amount we want our square to move on each button press
pixelsPerPress = 5;

% This is the cue which determines whether we exit the demo
exitDemo = false;

% Loop the animation until the escape key is pressed
while exitDemo == false
    
    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    
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
end

% Save the rate of the image
rate = (cursorPosition - 50) / ((RectWidth(rect) - 100) / 100);

% Close the texture
Screen('Close', imageTexture);

% Function to draw the VAS and the image on screen
    function draw()
        
        % Show image
        Screen('DrawTexture', wPtr, imageTexture, [], imageDestRect);
        
        % Draw the line
        Screen('DrawLine', wPtr, [0 0 0], distanceFromBorderLine, verticalPosLine, RectWidth(rect) - distanceFromBorderLine, verticalPosLine, [2]);
        
        % Print VAS' text
        Screen('TextFont', wPtr, 'Arial');
        Screen('TextStyle', wPtr, 1);
        Screen('TextSize', wPtr, 40); % Maybe find a way to relate the text size and the window size.
        Screen('DrawText', wPtr, '0', distanceFromBorderLine, verticalPosLine - 55);
        DrawFormattedText(wPtr, 'Extrêmement\ndésagréable', distanceFromBorderLine - 30, verticalPosLine + 40);
        Screen('DrawText', wPtr, '100', RectWidth(rect) - distanceFromBorderLine - 12, verticalPosLine - 55);
        DrawFormattedText(wPtr, 'Extrêmement\nagréable', RectWidth(rect) - distanceFromBorderLine - 170,verticalPosLine + 40);
        
        % Print confirmation message
        DrawFormattedText(wPtr, 'bouton du millieu pour continuer', 'center', RectHeight(rect) - 60);
        
        % Draw the cursor with the new position
        Screen('DrawLine', wPtr, [50 50 50], cursorPosition, verticalPosLine - 20, cursorPosition, verticalPosLine + 20, [5]); %%% modified by Eva: the color is adapated to a grey backgroud
        
        
        % Flip to the screen
        vbl  = Screen('Flip', wPtr, vbl + (waitframes - 0.5) * ifi);
        
    end

end