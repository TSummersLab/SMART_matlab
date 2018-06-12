function [sys, x0, str, ts] = sfun3d(t,x,u,flag,ax,varargin)

%SFUN3D S-function that acts as an X-Y-Z scope using MATLAB plotting functions.
%   This M-file is designed to be used in a Simulink S-function block.
%   It draws a line from the previous input point and the current point.
%
%   NOTE: this is a new version of sfunxyz. It has more natural inputs
%   that is (x1,y1,z1, x2,y2,z2 ... instead of x1,x2, y1,y2, z1,z2 ...)
%   and has the LineStyle and Marker properties as additional parameters,
%   so users should try to use this one instead of the older sfunxyz
%   for versions 2014b and later.
%
%   See also SFUNXYZS, LORENZS.

%   Copyright 1990-2015 The MathWorks, Inc.
%   $Revision: 1.38 $
%   Andrew Grace 5-30-91.
%   Revised Wes Wang 4-28-93, 8-17-93, 12-15-93
%   Revised Craig Santos 10-28-96
%   Modified by Giampiero Campa, April 04
%   Almost completely revritten by Giampiero Campa, November 2015

switch flag
    
    % Initialization %
    case 0
        [sys,x0,str,ts] = mdlInitializeSizes(ax,varargin{:});
        
        % This sets the callbacks for the cases in which flag is a string
        SetBlockCallbacks(gcbh);
        
        % Update %
    case 2
        sys = mdlUpdate(t,x,u,flag);
        
        % Callbacks set by 'SetBlockCallbacks' above
        
        % Start %
    case 'Start'
        LocalBlockStartFcn
        
        % Stop %
    case 'Stop'
        LocalBlockStopFcn
        
        % NameChange %
    case 'NameChange'
        LocalBlockNameChangeFcn
        
        % CopyBlock, LoadBlock %
    case { 'CopyBlock', 'LoadBlock' }
        LocalBlockLoadCopyFcn
        
        % DeleteBlock %
    case 'DeleteBlock'
        LocalBlockDeleteFcn
        
        % DeleteFigure %
    case 'DeleteFigure'
        LocalFigureDeleteFcn
        
        % Unused flags %
    case { 3, 9 }
        sys = [];
        
        % Unexpected flags %
    otherwise
        if ischar(flag),
            errmsg=sprintf('Unhandled flag: ''%s''', flag);
        else
            errmsg=sprintf('Unhandled flag: %d', flag);
        end
        
        error(errmsg);
        
end

% end sfunxy

%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys,x0,str,ts] = mdlInitializeSizes(ax,varargin)

vrs=version;
if str2double(vrs(1:3))<8.4,
    error('This S-Function (sfun3d.m) works only within MATLAB versions 2014b and later, please delete any existing version of 3Dscope, reinstall it on this MATLAB version, and use the legacy S-Function ''sfunxyz.m''.');
end

if length (ax)~=6
    error(['Axes limits must be defined.'])
end

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 3*fix(varargin{2});
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0 = [];

str = [];

% initialize the array of sample times, note that in earlier
% versions of this scope, a sample time was not one of the input
% arguments, the varargs checks for this and if not present, assigns
% the sample time to -1 (inherited)
ts = [varargin{1} 0];

% do the figure initialization:
FigHandle = GetSfunXYZFigure(gcbh);
if ~ishandle(FigHandle),
    % the figure doesn't exist, create one
    FigHandle = figure('Units',          'pixel',...
        'Position',       [100 100 400 300],...
        'Name',           get_param(gcbh,'Name'),...
        'Tag',            'SIMULINK_XYZGRAPH_FIGURE',...
        'NumberTitle',    'off',...
        'IntegerHandle',  'off',...
        'Toolbar',        'none',...
        'Menubar',        'none',...
        'DeleteFcn',      'sfun3d([],[],[],''DeleteFigure'')');
else
    % otherwise clear it
    clf(FigHandle);
end

% create the objects
CreateSfunXYZObjects(FigHandle,ax,varargin{:});
% end mdlInitializeSizes

%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
function sys=mdlUpdate(t,x,u,flag)

% always return empty, there are no states...
sys = [];

% Locate the figure window associated with this block.  If it's not a valid
% handle (it may have been closed by the user), then return.
FigHandle=GetSfunXYZFigure(gcbh);
if ~ishandle(FigHandle),
    return
end

% get userdata structure
ud = get(FigHandle,'UserData');

% add points to each line
nmax=length(ud.XYZLine);
for i=1:nmax,
    addpoints(ud.XYZLine(i),u(3*(i-1)+1),u(3*(i-1)+2),u(3*(i-1)+3));
end
% end mdlUpdate

function LocalBlockStartFcn

function LocalBlockStopFcn

%=============================================================================
% LocalBlockNameChangeFcn
% Function that handles name changes on the Graph scope block.
%=============================================================================
function LocalBlockNameChangeFcn
% get the figure associated with this block, if it's valid, change
% the name of the figure
FigHandle = GetSfunXYZFigure(gcbh);
if ishandle(FigHandle),
    set(FigHandle,'Name',get_param(gcbh,'Name'));
end
% end LocalBlockNameChangeFcn

%=============================================================================
% LocalBlockLoadCopyFcn
% This is the XYZGraph block's LoadFcn and CopyFcn.  Initialize the block's
% UserData such that a figure is not associated with the block.
%=============================================================================
function LocalBlockLoadCopyFcn
SetSfunXYZFigure(gcbh,-1);
% end LocalBlockLoadCopyFcn


%=============================================================================
% LocalBlockDeleteFcn
% This is the XYZ Graph block'DeleteFcn.  Delete the block's figure window,
% if present, upon deletion of the block.
%=============================================================================
function LocalBlockDeleteFcn
% Get the figure handle associated with the block, if it exists, delete
% the figure.
FigHandle=GetSfunXYZFigure(gcbh);
if ishandle(FigHandle),
    delete(FigHandle);
    SetSfunXYZFigure(gcbh,-1);
end
% end LocalBlockDeleteFcn

%=============================================================================
% LocalFigureDeleteFcn
% This is the XYZ Graph figure window's DeleteFcn.  The figure window is
% being deleted, update the XYZ Graph block's UserData to reflect the change.
%=============================================================================
function LocalFigureDeleteFcn
% Get the block associated with this figure and set it's figure to -1
ud=get(gcbf,'UserData');
SetSfunXYZFigure(ud.Block,-1)
% end LocalFigureDeleteFcn

%=============================================================================
% GetSfunXYZFigure
% Retrieves the figure window associated with this S-function XYZ Graph block
%=============================================================================
function FigHandle=GetSfunXYZFigure(block)
FigHandle=get_param(block,'UserData');
if isempty(FigHandle),
    FigHandle=-1;
end
% end GetSfunXYZFigure

%=============================================================================
% SetSfunXYZFigure
% Stores the figure window associated with this S-function XYZ Graph block
% in the block UserData.
%=============================================================================
function SetSfunXYZFigure(block,FigHandle)
set_param(block,'UserData',FigHandle);
% end SetSfunXYZFigure

%=============================================================================
% CreateSfunXYZFigure
% Creates the figure window associated with this S-function XYZ Graph block.
%=============================================================================
function FigHandle=CreateSfunXYZObjects(FigHandle,ax,varargin)

% get varargin arguments
nmax=fix(varargin{2});
CameraPosition=varargin{3};
if varargin{4}, GdSwitch='On'; else GdSwitch='Off'; end

% store the block's handle in the figure's UserData
ud.Block=gcbh;

% axes
ud.XYZAxes = axes;
cord=get(ud.XYZAxes,'ColorOrder');
set(ud.XYZAxes,'Visible','on','Xlim', ax(1:2),'Ylim', ax(3:4),'Zlim', ax(5:6),'CameraPosition',CameraPosition,'XGrid',GdSwitch,'YGrid',GdSwitch,'ZGrid',GdSwitch);
%set(FigHandle,'Color',get(FigHandle,'Color'));

% line
ud.XYZLine = [];
for n=1:nmax,
    ud.XYZLine = [ud.XYZLine animatedline('LineStyle',varargin{5},'Marker',varargin{6},'Color',cord(1+mod(n-1,size(cord,1)),:))];
end

% labels
xlabel('X Axis');
ylabel('Y Axis');
zlabel('Z Axis');

% title
ud.XYZTitle  = get(ud.XYZAxes,'Title');
set(ud.XYZTitle,'String','X Y Z Plot');

% Associate the figure with the block, and set the figure's UserData.
SetSfunXYZFigure(gcbh,FigHandle);
set(FigHandle,'UserData',ud);

% end CreateSfunXYZFigure

%=============================================================================
% SetBlockCallbacks
% This sets the callbacks of the block if it is not a reference.
%=============================================================================
function SetBlockCallbacks(block)

callbacks={
    'CopyFcn',       'sfun3d([],[],[],''CopyBlock'')' ;
    'DeleteFcn',     'sfun3d([],[],[],''DeleteBlock'')' ;
    'LoadFcn',       'sfun3d([],[],[],''LoadBlock'')' ;
    'StartFcn',      'sfun3d([],[],[],''Start'')' ;
    'StopFcn'        'sfun3d([],[],[],''Stop'')'
    'NameChangeFcn', 'sfun3d([],[],[],''NameChange'')' ;
    };

for i=1:length(callbacks),
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2}),
        set_param(block,callbacks{i,1},callbacks{i,2})
    end
end

% end SetBlockCallbacks
