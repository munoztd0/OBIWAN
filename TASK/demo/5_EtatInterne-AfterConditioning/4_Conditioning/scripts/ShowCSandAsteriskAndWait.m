function tFunction = ShowCSandAsteriskAndWait(wPtr, csTexture, thermoTexture, asterisk, csDstRect, var)
startT = GetSecs();
Screen('DrawTexture', wPtr, csTexture, [], csDstRect);
Screen('DrawTexture', wPtr, thermoTexture, [], [0 0 var.Twidth  var.hight]);
DrawFormattedText(wPtr, asterisk, 'center', 'center', 0);
Screen('Flip', wPtr);

%recond how long does this function take
timer = GetSecs()-var.time_MRI;
while timer < var.ref_end
    timer = GetSecs()-var.time_MRI;
end

tFunction = GetSecs()-startT;