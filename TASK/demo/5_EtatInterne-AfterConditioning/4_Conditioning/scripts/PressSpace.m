% press space keyboard to continue




function PressSpace ();

% First check that all button are relesased

[keyisdown,secs,keycode]= KbCheck;

while keyisdown == 1 % if already down, wait for release
    [keyisdown, secs, keycode]=KbCheck;
    WaitSecs(0.001);
end;

% Second press keyboard
spaceKey = KbName('space');

while 1
    [keyisdown,secs,keycode]= KbCheck;
    if keycode(spaceKey);
        keycode = zeros (1,256);
        break
    end;
end


end

