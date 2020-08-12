function varargout = PumpControl(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PumpControl_OpeningFcn, ...
                   'gui_OutputFcn',  @PumpControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function num = numFromTag(tag)
l = length(tag);
for ind = l:-1:1
    thisChar = tag(ind);
    if thisChar < '0' || thisChar > '9'
        break;
    end
end
if ind == l
    num = [];
else
    num = str2double(tag(ind+1:end));
end
    

function updatePumps(handles)
if handles.pumps(1).simulationMode ~= handles.cfg.simulationMode
    for ind=1:handles.nPumps
        if handles.pump(ind).connected
            handles.pump(ind).disconnect();
            handles.pumps(ind).simulationMode = handles.cfg.simulationMode;
            handles.pumps(pumpNum).connect(...
                handles.cfg.firstPort + ind - 1);
        end
    end
end
for ind=1:handles.nPumps
    handles.pumps(ind).volume = handles.cfg.pumps.volume;
    handles.pumps(ind).diameter = handles.cfg.pumps.diameter;
    handles.pumps(ind).rate = handles.cfg.pumps.rate;
end

function cfg = loadConfig()
if ~exist('PumpControl_cfg.mat','file')
    cfg = [];
else
    load('PumpControl_cfg.mat');
end

function saveConfig(cfg)
save('PumpControl_cfg.mat','cfg');

function updatePumpLabel(handles,pumpNum)
labelHandle = handles.(['lb_pump',num2str(pumpNum)]);
status = '';
if handles.pumps(pumpNum).isOpened()
    status = 'Connected';
    set(labelHandle,'ForegroundColor',0.7*[0,1,0]);
else
    status = 'Not connected';
    set(labelHandle,'ForegroundColor',0.7*[1,0,0]);
end
thisPumpCfg = handles.cfg.pumps(pumpNum);
labelStr = sprintf(...
    'Diameter = %g\nVolume = %g\nRate = %g\n',...
    [thisPumpCfg.diameter,...
    thisPumpCfg.volume,...
    thisPumpCfg.rate]);
    labelStr = [labelStr,status];
set(labelHandle,'String',labelStr);

function PumpControl_OpeningFcn(hObject, eventdata, handles, varargin)
clc;
handles.output = hObject;
handles.nPumps = 12;
handles.connected = false;
defltDiameter = 11.2838; % 1 cm^2
defltVolume = 1; % cm^3
defltRate = 1; % ml/min.

cfg = loadConfig();
if ~isempty(cfg)
    handles.cfg = cfg;
else
    handles.cfg = struct(...
        'firstPort',1,...
        'simulationMode',false,...
        'pumps',repmat(...
            struct(...
                'diameter',defltDiameter,...
                'volume',defltVolume,...
                'rate',defltRate),...
            handles.nPumps,1)...
    );
        
    saveConfig(handles.cfg);
end
set(handles.ed_firstPort,'String',...
    num2str(handles.cfg.firstPort));
set(handles.cb_simulationMode,'Value',handles.cfg.simulationMode);
for ind = 1:handles.nPumps
    handles.pumps(ind,1) = Pump();
end
for ind = 1:handles.nPumps
    updatePumpLabel(handles,ind);
end


guidata(hObject, handles);

function varargout = PumpControl_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function ed_firstPort_Callback(hObject, eventdata, handles)
handles.cfg.firstPort = str2num(get(hObject,'String'));
guidata(hObject,handles);
saveConfig(handles.cfg);

function ed_firstPort_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pb_connect_Callback(hObject, eventdata, handles)
for pumpNum = 1:handles.nPumps
    handles.pumps(pumpNum).disconnect();
    updatePumpLabel(handles,pumpNum);
end
if handles.connected
    set(hObject,'String','Connect');
    handles.connected = false;
else
    set(hObject,'String','Disconnect');
    for pumpNum = 1:handles.nPumps
        handles.pumps(pumpNum).simulationMode = handles.cfg.simulationMode;
        handles.pumps(pumpNum).connect(...
            handles.cfg.firstPort + pumpNum - 1);
        if handles.pumps(pumpNum).connected
            handles.pumps(pumpNum).volume =...
                handles.cfg.pumps(pumpNum).volume;
            handles.pumps(pumpNum).diameter =...
                handles.cfg.pumps(pumpNum).diameter;
            handles.pumps(pumpNum).rate =...
                handles.cfg.pumps(pumpNum).rate;
            updatePumpLabel(handles,pumpNum);
        end
    end
    handles.connected = true;
end
guidata(hObject,handles)

function setup(hObject,handles)
pumpNum = numFromTag(get(hObject,'Tag'));
p = PumpSetup(handles.cfg.pumps(pumpNum));
if ~isempty(p)
    handles.cfg.pumps(pumpNum) = p;
    guidata(hObject,handles);
    updatePumpLabel(handles,pumpNum);
    saveConfig(handles.cfg);
    if handles.pumps(pumpNum).connected
        handles.pumps(pumpNum).volume =...
            handles.cfg.pumps(pumpNum).volume;
        handles.pumps(pumpNum).diameter =...
            handles.cfg.pumps(pumpNum).diameter;
        handles.pumps(pumpNum).rate =...
            handles.cfg.pumps(pumpNum).rate;
    end
end

function start(hObject,handles)
pumpNum = numFromTag(get(hObject,'Tag'));
if handles.pumps(pumpNum).connected
    handles.pumps(pumpNum).start();
end

function stop(hObject,handles)
pumpNum = numFromTag(get(hObject,'Tag'));
if handles.pumps(pumpNum).connected
    handles.pumps(pumpNum).stop();
end

function pause(hObject,handles)
pumpNum = numFromTag(get(hObject,'Tag'));
if handles.pumps(pumpNum).connected
    handles.pumps(pumpNum).pause();
end

function restart(hObject,handles)
pumpNum = numFromTag(get(hObject,'Tag'));
if handles.pumps(pumpNum).connected
    handles.pumps(pumpNum).restart();
end

function pb_setup1_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup2_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup3_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup4_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup5_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup6_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup7_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup8_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup9_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup10_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup11_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_setup12_Callback(hObject, eventdata, handles)
setup(hObject,handles)

function pb_start1_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start2_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start3_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start4_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start5_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start6_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start7_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start8_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start9_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start10_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start11_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_start12_Callback(hObject, eventdata, handles)
start(hObject,handles);

function pb_stop1_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop2_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop3_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop4_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop5_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop6_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop7_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop8_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop9_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop10_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop11_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_stop12_Callback(hObject, eventdata, handles)
stop(hObject,handles);

function pb_pause1_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause2_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause3_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause4_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause5_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause6_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause7_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause8_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause9_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause10_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause11_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_pause12_Callback(hObject, eventdata, handles)
pause(hObject,handles);

function pb_restart1_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart2_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart12_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart11_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart10_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart9_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart8_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart7_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart6_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart5_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart4_Callback(hObject, eventdata, handles)
restart(hObject,handles);

function pb_restart3_Callback(hObject, eventdata, handles)
restart(hObject,handles);


% --- Executes on button press in cb_simulationMode.
function cb_simulationMode_Callback(hObject, eventdata, handles)
% hObject    handle to cb_simulationMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_simulationMode
handles.cfg.simulationMode = get(hObject,'Value');
guidata(hObject,handles);
saveConfig(handles.cfg);
