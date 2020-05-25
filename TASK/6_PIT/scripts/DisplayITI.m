function ITI = DisplayITI (var, wPtr,nTrial)

startT = GetSecs;

if var.RewardNumber == 0 % extinction
    expectedTime = 12;
    var.RewardWindowDuration1 = 1;
    var.RewardWindowDuration2 = 1;
elseif var.RewardNumber == 1 % partial extinction
    expectedTime = 11;
    var.RewardWindowDuration2 = 1;
elseif var.RewardNumber == 2 % riminder or learning
    expectedTime  = 10;  
end
        
ITI = var.ITI(nTrial) - (((var.RewardWindowDuration1 -1) + (var.RewardWindowDuration2-1)) + (var.drift-expectedTime));% minimal ITI = 1.5; maximal ITI; = 8.5; average ITI = 8

Cross = '+';
DrawFormattedText(wPtr, Cross, 'center', 'center', [0 0 0]);
Screen('Flip', wPtr);

timer = 0;

while timer < ITI
    
    timer = GetSecs()-startT;;
end

end