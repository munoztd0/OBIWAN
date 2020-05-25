 function DisplayTermoImage (var, wPtr)
tex2 = Screen ('MakeTexture', wPtr, var.thermometerImage);
tex1 = Screen ('MakeTexture', wPtr, var.centralImage);
Screen('DrawTexture', wPtr, tex2,[],[0 0 var.Twidth  var.hight]);
Screen('DrawTexture', wPtr, tex1,[],var.dstRect); 
Screen('Close',tex2);
Screen('Close',tex1);
Screen('Flip', wPtr, 0, 1);