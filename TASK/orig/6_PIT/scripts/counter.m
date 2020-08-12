function [CSplus_image, CSminus_image, CSBL_image, list] = counter(participantID)
 
% this randomization is not compleate (otherwise 144 lists would be
% necessary) but it makes sure that each color equally corresponded to one
% Pavolvian role
 
if participantID == 1 || mod((participantID - 1),6) == 0;
    list = 1;
    CSplus_image = 'yellow.jpg';
    CSminus_image = 'green.jpg';
    CSBL_image = 'red.jpg';
elseif participantID == 2 || mod((participantID - 2),6) == 0;
    list = 2;
    CSplus_image = 'yellow.jpg';
    CSBL_image = 'green.jpg';
    CSminus_image = 'red.jpg';
elseif participantID == 3 || mod((participantID - 3),6) == 0;
    list = 3;
    CSminus_image = 'yellow.jpg';
    CSplus_image = 'green.jpg';
    CSBL_image = 'red.jpg';
elseif participantID == 4 || mod((participantID - 4),6) == 0;
    list = 4;
    CSminus_image = 'yellow.jpg';
    CSBL_image = 'green.jpg';
    CSplus_image = 'red.jpg';
elseif participantID == 5 || mod((participantID - 5),6) == 0;
    list = 5;
    CSBL_image = 'yellow.jpg';
    CSplus_image = 'green.jpg';
    CSminus_image = 'red.jpg';
elseif participantID == 6 || mod((participantID - 6),6) == 0;
    list = 6;
    CSBL_image = 'yellow.jpg';
    CSminus_image = 'green.jpg';
    CSplus_image = 'red.jpg';     
end
end