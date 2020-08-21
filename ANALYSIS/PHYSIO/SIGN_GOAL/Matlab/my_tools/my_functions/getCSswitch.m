function [CSswitch] = getCSswitch (variable)

CSswitch = nan(length(variable),1);

for i = 2:length (variable)
    CSswitch (1,1) = 1;
    if variable(i-1) == variable(i)
        CSswitch(i) = 0;
    else
        CSswitch(i) = 1;  
    end
end