% keysWanted is a matrix list of keys you are waiting for e.g, [124 125 kbName('space')]

function keyPressed = getKeys(keysWanted) 
  flushevents('keydown');
  success = 0;
  while success == 0
   pressed = 0;
   while pressed == 0
    [pressed, secs, kbData] = kbcheck;
   end;
    for i = 1:length(keysWanted)
      if kbData(keysWanted(i)) == 1
       success = 1;
       keyPressed = keysWanted(i);
       flushevents('keydown');
       break;
      end;
    end;
    flushevents('keydown');
end;