function duration = cleanKeyboardMemory
t1 = GetSecs();
[keyisdown, ~,~] = KbCheck;
while (keyisdown == 1) % if already down, wait for release: questo loop pulisce la memoria della tastiera
    [keyisdown, ~, ~] = KbCheck;
    WaitSecs(0.001);
end;
duration = GetSecs - t1;

end