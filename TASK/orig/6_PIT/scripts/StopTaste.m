function [tValveClose, tFunction] = StopTaste (var,pumps,pumpNum)
% get time
startT = GetSecs();
tValveClose = GetSecs - var.time_MRI; % time_MRI is define in the main function

% Stop taste
data_out = 0; % trigger signaling when the odor is relased
if var.experimentalSetup
    outp(53240, data_out);
end
pumps(pumpNum).stop;

tFunction = GetSecs()-startT;
end

%---------------------------------------------------
% Helper functions
%---------------------------------------------------

% send(pumps,cfg,pumpNum,quantity) : Sends <quantity> ml from pump
% #<punpNum> . This function returns when this quantity is sent.
% The argument <pumps> and <cfg> must be provided, they are definied in the
% 'Initialization' section.
function send(pumps,cfg,pumpNum,quantity)
% Let's be sure that this pump exists...
% if pumpNum > nPumps
%     sprintf(...
%         'Attempt to access to pump #%d. Valid pump nums are in [0 .. %d]\n',...
%         pumpNum,nPumps);
%     error(s);
% end

if exist('quantity','var') % if overriding default volume to send
    pumps(pumpNum).volume = quantity;
    q = quantity;
else
    pumps(pumpNum).volume = cfg.pumps(pumpNum).volume;
    q = cfg.pumps(pumpNum).volume;
end
tWait = 60*q/cfg.pumps(pumpNum).rate;
pumps(pumpNum).start;
end