 function displayFeedbackExtinction (var,ft, wPtr)
% Determine max and min high of the mercury AND BETA
maxhight = var.hight/18.6047;
minhight = var.hight/1.2739;
beta = (maxhight - minhight)/(var.ValMax-var.minimalforce);

%Delete previous feedback
Screen('FillRect', wPtr, [225 255 255], [var.fl, (var.ValMax-var.minimalforce)*beta+minhight, var.tr, var.tb])
Screen('FillRect', wPtr, [225 0 0], [var.fl, ft, var.tr, var.tb]);

wPtrRect = Screen('Rect', wPtr);
Rectangle = [0 0 25 25];
CoordinatesRectangle = CenterRect(Rectangle, wPtrRect);

Screen('FrameRect', wPtr, [0 0 0], CoordinatesRectangle)
Screen('FillRect', wPtr, [0 0 0], CoordinatesRectangle)
Screen('Flip', wPtr, 0, 1);
 end
