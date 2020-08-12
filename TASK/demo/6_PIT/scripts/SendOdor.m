function [tValve] = SendOdor (var) % modified on 21.06.2015 for BBL room

% get time
tValve = GetSecs - var.time_MRI; % time_MRI is define in the main function

% Send odor
data_out = var.odorTrigger; % trigger signaling when the odor is relased

if var.experimentalSetup % variable define in the main function
    
    outp(53240, data_out);
    oCommit(); % release odor
    outp(53240, 0);
    
end

end