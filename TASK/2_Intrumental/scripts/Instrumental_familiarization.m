function Instrumental_familiarization(var,wPtr) % modified on the 28 of april 2015 by Eva

% this function displays the online feeback witout delivering any reward or
% reconding and data. Is just to familiarize the participant with the
% handgrip functioning. It needs as input the values of the calibration 

cleanKeyboardMemory;
SpaceIsPressed = 0;
DisplayTermoImage (var, wPtr);

while SpaceIsPressed == 0
    
    %read mobilized force
    if var.experimentalSetup
        val = readAD(); % define the number according to the value that is displayed with no force in order to have it at 0
    else
        val = rand([1]);
    end
    
    %to set the maximal value as a value that change randomly
    % between 50% and 70%
    idxv = randperm(numel(var.v));
    var.ValMax = var.v (idxv (1:1));
    
    % compute variable for online feedback and Diplay feedback on the screen
    ft = OnlineFeedback(var,val, wPtr);
    displayFeedback(var,ft,wPtr);
    
    % Check if space has been pressed
    [keyPressed, ~, keyCode]= KbCheck;
    if ((keyPressed == 1) && (keyCode(KbName('space')) == 1))
    SpaceIsPressed = 1;
    end
    
end

end