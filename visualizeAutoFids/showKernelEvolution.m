function varargout = showKernelEvolution(varargin)
% SHOWKERNELEVOLUTION MATLAB code for showKernelEvolution.fig
%      SHOWKERNELEVOLUTION, by itself, creates a new SHOWKERNELEVOLUTION or raises the existing
%      singleton*.
%
%      H = SHOWKERNELEVOLUTION returns the handle to a new SHOWKERNELEVOLUTION or the handle to
%      the existing singleton*.
%
%      SHOWKERNELEVOLUTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOWKERNELEVOLUTION.M with the given input arguments.
%
%      SHOWKERNELEVOLUTION('Property','Value',...) creates a new SHOWKERNELEVOLUTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before showKernelEvolution_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to showKernelEvolution_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help showKernelEvolution

% Last Modified by GUIDE v2.5 15-Sep-2017 14:29:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @showKernelEvolution_OpeningFcn, ...
                   'gui_OutputFcn',  @showKernelEvolution_OutputFcn, ...
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


% --- Executes just before showKernelEvolution is made visible.
function showKernelEvolution_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to showKernelEvolution (see VARARGIN)


%%%% load data :
path = '/Users/anton/Documents/allMatlabStuff/testingStuff/fullAutoData';
file = 'AutoProcData.mat';
fullpath = fullfile(path,file);
load(fullpath)


%%%% set up global with beatKernel:
global XXX
fieldsToRemove = {'fidKernels','limPotvalsOfSearch','RMSofSearchArea'};
XXX = rmfield(data,fieldsToRemove);




%%%% set up the axes
ax = handles.myAxes;
plotAxes(ax,1)


%%%% set the slider
sl = handles.slider1;
sl.Min = 1;
sl.Max = length(XXX);
sl.Value = 1;
sl.SliderStep =[ 0.01, 0.02 ];


%%%% set up listener for slider
addlistener(sl,'ContinuousValueChange',@(~,~)slider1_Callback(sl,3,guidata(sl)) );





% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = showKernelEvolution_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on slider movement.
function slider1_Callback(hObject,eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

frame = round(hObject.Value);
ax = handles.myAxes;
plotAxes(ax,frame)





% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function plotAxes(ax,frame)
global XXX

plot(ax,XXX(frame).beatKernel);
Ylim =ylim(ax);


%%%% get fidValues
tpeak = XXX(frame).locFidValues(5);
qstart = XXX(frame).locFidValues(1);
qend = XXX(frame).locFidValues(2);
tstart = XXX(frame).locFidValues(3);
tend = XXX(frame).locFidValues(4);

%%%% plot fids
% q-wave
patch(ax,[qstart qend qend qstart], [ Ylim(1), Ylim(1), Ylim(2), Ylim(2)], 'red', 'FaceAlpha', 0.1)

% t-wave
patch(ax,[tstart tend tend tstart], [ Ylim(1), Ylim(1), Ylim(2), Ylim(2)], 'blue', 'FaceAlpha', 0.1)

% t-peak
line(ax,[tpeak tpeak], Ylim, 'Color','blue', 'LineStyle','--', 'LineWidth', 2)

%%%% title
text(ax,0.5,0.9,num2str(frame),'Units', 'normalized')


