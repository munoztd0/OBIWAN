function displayFeedback (var,ft, wPtr)
% Determine max and min high of the mercury AND BETA
maxhight = var.hight/18.6047;
minhight = var.hight/1.2739;
beta = (maxhight - minhight)/(var.ValMax-var.minimalforce);

%Delete previous feedback
Screen('FillRect', wPtr, [225 255 255], [var.fl, (var.ValMax-var.minimalforce)*beta+minhight, var.tr, var.tb])
Screen('FillRect', wPtr, [225 0 0], [var.fl, ft, var.tr, var.tb]);
Screen('Flip', wPtr, 0, 1);
end%% modified on the 5.03.2015