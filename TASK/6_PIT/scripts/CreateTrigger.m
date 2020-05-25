
function trigger = CreateTrigger(var) % modified on the 22.04.2015

switch var.phase
    case 1
        phase = 4; %instrumental riminder
    case 2
        phase = 8; % partial extinction
    case 3
        phase = 16; % PIT
end

CS= 0;
if var.phase == 3
    switch var.condition(var.ordre(:,var.nCycle),:)
        
        case 1 % CSplus
            CS = 32;
        case 2 % CS minus
            CS = 64;
        case 3 % Baseline
            CS = 128;
    end
end

trigger = phase + CS;

end