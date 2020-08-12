function tFunction = ShowCS(wPtr, csTexture, thermoTexture, csDstRect, var)
startT = GetSecs();
Screen('DrawTexture', wPtr, csTexture, [], csDstRect);
Screen('DrawTexture', wPtr, thermoTexture, [], [0 0 var.Twidth  var.hight]);
Screen('Flip', wPtr);

timer = GetSecs()-var.time_MRI;
while timer < var.ref_end
    timer = GetSecs()-var.time_MRI;
end
tFunction = GetSecs()-startT;