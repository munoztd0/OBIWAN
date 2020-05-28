function [time,tFunction] = SendTrigger (trigger,var)
startT = GetSecs;
time = GetSecs - var.time_MRI; % time_MRI is  define in the main function
data_out = trigger; % trigger signaling when the odor is relased

if var.experimentalSetup % variable define in the main function
    outp(53240, data_out);
    WaitSecs (0.03);
    outp(53240,0);
end

tFunction = GetSecs()-startT;

end