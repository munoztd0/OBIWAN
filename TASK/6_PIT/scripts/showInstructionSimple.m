    function showInstructionSimple(wPtr, instructionText)
          
        % Screen settings
        Screen('TextFont', wPtr, 'Arial');
        Screen('TextSize', wPtr, 40);
        Screen('TextStyle', wPtr, 1);   
        
        % Print the instruction on the window
        DrawFormattedText(wPtr, instructionText, 'center', 'center', 0);
        Screen(wPtr, 'Flip');
        
    end %% modified on 13.03.2015
