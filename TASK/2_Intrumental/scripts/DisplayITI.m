function tFunction = DisplayITI (var, wPtr)
startT = GetSecs;

Cross = '+';
DrawFormattedText(wPtr, Cross, 'center', 'center', [0 0 0]);
Screen('Flip', wPtr);

%recond how long does this function take
timer = GetSecs()-var.time_MRI;
while timer < var.ref_end
    timer = GetSecs()-var.time_MRI;
end

tFunction = GetSecs()-startT;