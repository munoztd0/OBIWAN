function tFunction = ShowCSandAsterisk(wPtr, csTexture, thermoTexture, asterisk, csDstRect, var)
startT = GetSecs();
Screen('DrawTexture', wPtr, csTexture, [], csDstRect);
Screen('DrawTexture', wPtr, thermoTexture, [], [0 0 var.Twidth  var.hight]);
DrawFormattedText(wPtr, asterisk, 'center', 'center', 0);
Screen('Flip', wPtr);
tFunction = GetSecs()-startT;