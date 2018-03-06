function varargout = autoTraingui(varargin)
%AUTOTRAINGUI M-file for autoTraingui.fig
%      AUTOTRAINGUI, by itself, creates a new AUTOTRAINGUI or raises the existing
%      singleton*.
%
%      H = AUTOTRAINGUI returns the handle to a new AUTOTRAINGUI or the handle to
%      the existing singleton*.
%
%      AUTOTRAINGUI('Property','Value',...) creates a new AUTOTRAINGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to autoTraingui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      AUTOTRAINGUI('CALLBACK') and AUTOTRAINGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in AUTOTRAINGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help autoTraingui

% Last Modified by GUIDE v2.5 15-Jun-2017 18:40:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @autoTraingui_OpeningFcn, ...
                   'gui_OutputFcn',  @autoTraingui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before autoTraingui is made visible.
function autoTraingui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for autoTraingui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes autoTraingui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = autoTraingui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function thrdur_Callback(hObject, eventdata, handles)
% hObject    handle to thrdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thrdur as text
%        str2double(get(hObject,'String')) returns contents of thrdur as a double


% --- Executes during object creation, after setting all properties.
function thrdur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thrdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thramp_Callback(hObject, eventdata, handles)
% hObject    handle to thramp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thramp as text
%        str2double(get(hObject,'String')) returns contents of thramp as a double


% --- Executes during object creation, after setting all properties.
function thramp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thramp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function recd_Callback(hObject, eventdata, handles)
% hObject    handle to recd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of recd as text
%        str2double(get(hObject,'String')) returns contents of recd as a double


% --- Executes during object creation, after setting all properties.
function recd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function motuGain_Callback(hObject, eventdata, handles)
% hObject    handle to motuGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motuGain as text
%        str2double(get(hObject,'String')) returns contents of motuGain as a double


% --- Executes during object creation, after setting all properties.
function motuGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motuGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sessionType_Callback(hObject, eventdata, handles)
% hObject    handle to sessionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sessionType as text
%        str2double(get(hObject,'String')) returns contents of sessionType as a double


% --- Executes during object creation, after setting all properties.
function sessionType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sessionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function batName_Callback(hObject, eventdata, handles)
% hObject    handle to batName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of batName as text
%        str2double(get(hObject,'String')) returns contents of batName as a double


% --- Executes during object creation, after setting all properties.
function batName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to batName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ledCue_Callback(hObject, eventdata, handles)
% hObject    handle to ledCue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ledCue as text
%        str2double(get(hObject,'String')) returns contents of ledCue as a double


% --- Executes during object creation, after setting all properties.
function ledCue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ledCue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ledReward_Callback(hObject, eventdata, handles)
% hObject    handle to ledReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ledReward as text
%        str2double(get(hObject,'String')) returns contents of ledReward as a double


% --- Executes during object creation, after setting all properties.
function ledReward_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ledReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minInt_Callback(hObject, eventdata, handles)
% hObject    handle to minInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minInt as text
%        str2double(get(hObject,'String')) returns contents of minInt as a double


% --- Executes during object creation, after setting all properties.
function minInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxInt_Callback(hObject, eventdata, handles)
% hObject    handle to maxInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxInt as text
%        str2double(get(hObject,'String')) returns contents of maxInt as a double


% --- Executes during object creation, after setting all properties.
function maxInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxActive_Callback(hObject, eventdata, handles)
% hObject    handle to maxActive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxActive as text
%        str2double(get(hObject,'String')) returns contents of maxActive as a double


% --- Executes during object creation, after setting all properties.
function maxActive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxActive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minBreak_Callback(hObject, eventdata, handles)
% hObject    handle to minBreak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minBreak as text
%        str2double(get(hObject,'String')) returns contents of minBreak as a double


% --- Executes during object creation, after setting all properties.
function minBreak_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minBreak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ledTimeOut_Callback(hObject, eventdata, handles)
% hObject    handle to ledTimeOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ledTimeOut as text
%        str2double(get(hObject,'String')) returns contents of ledTimeOut as a double


% --- Executes during object creation, after setting all properties.
function ledTimeOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ledTimeOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function comments_Callback(hObject, eventdata, handles)
% hObject    handle to comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of comments as text
%        str2double(get(hObject,'String')) returns contents of comments as a double


% --- Executes during object creation, after setting all properties.
function comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trainOn.
function trainOn_Callback(hObject, eventdata, handles)
% hObject    handle to trainOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trainOn



function trainT_Callback(hObject, eventdata, handles)
% hObject    handle to trainT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trainT as text
%        str2double(get(hObject,'String')) returns contents of trainT as a double


% --- Executes during object creation, after setting all properties.
function trainT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trainT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function autoTraingui_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoTraingui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function sessionID_Callback(hObject, eventdata, handles)
% hObject    handle to sessionID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sessionID as text
%        str2double(get(hObject,'String')) returns contents of sessionType as a double

% --- Executes during object creation, after setting all properties.
function sessionID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sessionID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function motorS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motorS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function motorS_Callback(hObject, eventdata, handles)
% hObject    handle to motorS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motorS as text
%        str2double(get(hObject,'String')) returns contents of motorS as a double



function motorT_Callback(hObject, eventdata, handles)
% hObject    handle to motorT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motorT as text
%        str2double(get(hObject,'String')) returns contents of motorT as a double


% --- Executes during object creation, after setting all properties.
function motorT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motorT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minBW_Callback(hObject, eventdata, handles)
% hObject    handle to motorT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motorT as text
%        str2double(get(hObject,'String')) returns contents of motorT as a double


% --- Executes during object creation, after setting all properties.
function minBW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxTimeOut_Callback(hObject, eventdata, handles)
% hObject    handle to maxTimeOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxTimeOut as text
%        str2double(get(hObject,'String')) returns contents of maxTimeOut as a double


% --- Executes during object creation, after setting all properties.
function maxTimeOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxTimeOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dunceCap_Callback(hObject, eventdata, handles)
% hObject    handle to dunceCap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dunceCap as text
%        str2double(get(hObject,'String')) returns contents of dunceCap as a double


% --- Executes during object creation, after setting all properties.
function dunceCap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dunceCap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in recButton.
function recButton_Callback(hObject, eventdata, handles)
% hObject    handle to recButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of recButton



function thrfreq_Callback(hObject, eventdata, handles)
% hObject    handle to thrfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thrfreq as text
%        str2double(get(hObject,'String')) returns contents of thrfreq as a double


% --- Executes during object creation, after setting all properties.
function thrfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thrfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thrrms_Callback(hObject, eventdata, handles)
% hObject    handle to thrrms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thrrms as text
%        str2double(get(hObject,'String')) returns contents of thrrms as a double


% --- Executes during object creation, after setting all properties.
function thrrms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thrrms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in debugButton.
function debugButton_Callback(hObject, eventdata, handles)
% hObject    handle to debugButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of debugButton



function minWait_Callback(hObject, eventdata, handles)
% hObject    handle to minWait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minWait as text
%        str2double(get(hObject,'String')) returns contents of minWait as a double


% --- Executes during object creation, after setting all properties.
function minWait_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minWait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxReward_Callback(hObject, eventdata, handles)
% hObject    handle to maxReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxReward as text
%        str2double(get(hObject,'String')) returns contents of maxReward as a double


% --- Executes during object creation, after setting all properties.
function maxReward_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxReward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in recChan.
function recChan_Callback(hObject, eventdata, handles)
% hObject    handle to recChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns recChan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from recChan


% --- Executes during object creation, after setting all properties.
function recChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function playbackFile_Callback(hObject, eventdata, handles)
% hObject    handle to playbackFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playbackFile as text
%        str2double(get(hObject,'String')) returns contents of playbackFile as a double


% --- Executes during object creation, after setting all properties.
function playbackFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playbackFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in playbackButton.
function playbackButton_Callback(hObject, eventdata, handles)
% hObject    handle to playbackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of playbackButton



function responseT_Callback(hObject, eventdata, handles)
% hObject    handle to responseT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of responseT as text
%        str2double(get(hObject,'String')) returns contents of responseT as a double


% --- Executes during object creation, after setting all properties.
function responseT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to responseT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxDelay_Callback(hObject, eventdata, handles)
% hObject    handle to maxDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxDelay as text
%        str2double(get(hObject,'String')) returns contents of maxDelay as a double


% --- Executes during object creation, after setting all properties.
function maxDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sleepT_Callback(hObject, eventdata, handles)
% hObject    handle to sleepT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sleepT as text
%        str2double(get(hObject,'String')) returns contents of sleepT as a double


% --- Executes during object creation, after setting all properties.
function sleepT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sleepT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sleepOn.
function sleepOn_Callback(hObject, eventdata, handles)
% hObject    handle to sleepOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sleepOn
