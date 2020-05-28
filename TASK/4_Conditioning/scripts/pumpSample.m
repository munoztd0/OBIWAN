function pumpSample()

%---------------------------------------------------
% Initialisation code
%---------------------------------------------------

% Are we in simulation mode ?

simulationMode = true;

% How many pumps do we have ?
nPumps = 12;

% default parameters
defltDiameter = 11.2838; % mm^2
defltVolume = 1; % cm^3
defltRate = 10; % ml/min.

% All the pumps configuration parameters will be in
% the 'cfg' structure.
%   cfg.firstPort : The first com port of the pumps
%   cfg.pumps : a nPumps by 1 structure array with
%   the following fields :
%       cfg.pumps(ii).diameter : the inner diameter of the pump
%       cfg.volume(ii).diameter : the volume in the pump
%       cfg.rate(ii).diameter : the flow rate of the pump
cfg = struct(...
    'simulationMode',simulationMode,...
    'firstPort',10,...
    'pumps',repmat(...
        struct(...
            'diameter',defltDiameter,...
            'volume',defltVolume,...
            'rate',defltRate),...
        nPumps,1)...
);

% Allocating pump pbjects
for ind = 1:nPumps
    pumps(ind,1) = Pump();
end

% Disconnecting all pumps just in case...
for pumpNum = 1:nPumps
    pumps(pumpNum).disconnect();
end

% Connecting all pumps and seting up their parameters
for pumpNum = 1:nPumps
    pumps(pumpNum).simulationMode = cfg.simulationMode;
    fprintf('connecting pump %d\n',pumpNum);
    pumps(pumpNum).connect(...
        cfg.firstPort + pumpNum - 1);
    if pumps(pumpNum).connected
        pumps(pumpNum).volume =...
            cfg.pumps(pumpNum).volume;
        pumps(pumpNum).diameter =...
            cfg.pumps(pumpNum).diameter;
        pumps(pumpNum).rate =...
            cfg.pumps(pumpNum).rate;
    end
end

%---------------------------------------------------
% Sample stimulus presentation
%---------------------------------------------------

pumpNum = 6;
quantity = 2; % ml
fprintf('Sending %f ml from pump %d\n',quantity,pumpNum);
send(pumps,cfg,pumpNum,quantity);
t = 2; % seconds
fprintf(...
    'Waiting during an inter-stimulus time of %f seconds\n',t);
sleep(t);

pumpNum = 7;
quantity = 4; % ml
fprintf('Sending %f ml from pump %d\n',quantity,pumpNum);
send(pumps,cfg,pumpNum,quantity);
t = 2; % seconds
fprintf(...
    'Waiting during an inter-stimulus time of %f seconds\n',t);
sleep(t);

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
sleep(tWait);

function sleep(t) % t = sleeping duration in seconds
tic;
while toc < t
    drawnow();
end
