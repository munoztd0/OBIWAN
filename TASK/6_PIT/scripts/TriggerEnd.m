function [time] = TriggerEnd (var) % modified 21.05.2015 for BBL room

        time = GetSecs - var.time_MRI; % time_MRI is  define in the main function   
        
        if var.experimentalSetup % variable define in the main function
            io32(var.ioObj,hex2dec('CFF8'), 0);
        end
        
    end