function time = howMuchWait(pressed, var)

% Auxiliary function that compute how much time show the CS for having
% all the trials performed in 4 secs.

if (pressed == 0)
    time = 2 - var.csPresentationTime - var.responseWindow;
else
    time = 2 - var.csPresentationTime - var.reactionTime;
end
end
