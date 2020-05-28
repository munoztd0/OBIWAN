function varargout = PumpSetup(varargin)
% PUMPSETUP M-file for PumpSetup.fig
%      PUMPSETUP, by itself, creates a new PUMPSETUP or raises the existing
%      singleton*.
%
%      H = PUMPSETUP returns the handle to a new PUMPSETUP or the handle to
%      the existing singleton*.
%
%      PUMPSETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PUMPSETUP.M with the given input arguments.
%
%      PUMPSETUP('Property','Value',...) creates a new PUMPSETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PumpSetup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PumpSetup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PumpSetup

% Last Modified by GUIDE v2.5 04-Feb-2016 14:50:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PumpSetup_OpeningFcn, ...
                   'gui_OutputFcn',  @PumpSetup_OutputFcn, ...
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


% --- Executes just before PumpSetup is made visible.
function PumpSetup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PumpSetup (see VARARGIN)

% Choose default command line output for PumpSetup
handles.output = hObject;

if ~isempty(varargin)
    p = varargin{1};
else
    p = [];
end
if isstruct(p) &&...
    isfield(p,'diameter') &&...
    isfield(p,'volume') &&...
    isfield(p,'rate')

    handles.diameter = p.diameter;
    handles.volume = p.volume;
    handles.rate = p.rate;
    handles.cancelled = false;
    
    set(handles.ed_diameter,'String',num2str(handles.diameter));
    set(handles.ed_volume,'String',num2str(handles.volume));
    set(handles.ed_rate,'String',num2str(handles.rate));
else
    error('Invalid args for PumpSetup');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PumpSetup wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PumpSetup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if handles.cancelled
    p = [];
else
    p.diameter = handles.diameter;
    p.volume = handles.volume;
    p.rate = handles.rate;
end;

varargout{1} = p;
close(handles.figure1);

function ed_diameter_Callback(hObject, eventdata, handles)
handles.diameter = str2double(get(hObject,'String'));
guidata(hObject,handles);
    
function ed_diameter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ed_volume_Callback(hObject, eventdata, handles)
handles.volume = str2double(get(hObject,'String'));
guidata(hObject,handles);

function ed_volume_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ed_rate_Callback(hObject, eventdata, handles)
handles.rate = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ed_rate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pb_ok_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);

function pb_cancel_Callback(hObject, eventdata, handles)
handles.cancelled = true;
guidata(hObject,handles);
uiresume(handles.figure1);
