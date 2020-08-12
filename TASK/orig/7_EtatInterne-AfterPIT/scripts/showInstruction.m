function tFunction = showInstruction(wPtr, instructionText,var)

startT = GetSecs();
% Screen settings
Screen('TextFont', wPtr, 'Arial');
Screen('TextSize', wPtr, 40);
Screen('TextStyle', wPtr, 1);

% Print the instruction on the window
DrawFormattedText(wPtr, instructionText, 'center', 'center', 0);
Screen(wPtr, 'Flip');

%recond how long does this function take
timer = GetSecs()-var.time_MRI;
while timer < var.ref_end
    timer = GetSecs()-var.time_MRI;
end

tFunction = GetSecs()-startT;

end %% modified on 13.03.2015