%% Sphero Robotic Platform - Matlab (SRP-Matlab)
% 
% This script demonstrates how one can use SRP-Matlab to validate a 
% distributed formation control strategy experimentally.
%
% In particular, the parameters are set to achieve a square grid formation 
% with 9 Sphero robots, where 3 computers are used and each computer 
% controls 3 robots. The number of robots, number of computers, and the 
% desired formation can be changed to one's liking. 
%
% Furthermore, the formation control algorithm that is called as a function 
% in the main loop can be replaced by any other multi-agent strategy if
% desired. 
%
% Questions and comments are welcome. 
% See "LICENSE.txt" for license information.
%
%
% Copyright (c) 2017-2018, Sleiman Safaoui, Kaveh Fathian  
%
% Emails:   Sleiman.Safaoui@utdallas.edu
%           kavehfathian@gmail.com
%


% Include helper files
addpath(genpath('Sphero'));
addpath('Helpers');
addpath('Formation Control');
addpath('EKF');
addpath('CVX');
addpath(genpath('Calibration Images'));


%% Preallocate parameters

SphNames                = {'RPY', 'YWR', 'WWP'};    % Name of spheros (controlled on this computer)
CameraParam.col         = [0, 255, 255];            % Detection color for robots (cyan)
SpheroState.SphNames    = SphNames;

numItr                  = 100;                      % Number of iterations to keep the data (must be > 1)
SpheroState.numItr      = numItr;
SpheroState.numRob      = 9;                        % Total number of robots (connected on all computers)


%% Test Webcam
%
% Webcam must be connected to the computer, and Matlab webcam support package
% must be installed. 

camList = webcamlist;  % Identify Available Webcams
if isfield(CameraParam,'cam')
    delete(CameraParam.cam)
    CameraParam = rmfield(CameraParam,'cam');
end
cam = webcam(1);         % Connect to the webcam (change this number to the correct webcam ID if you have more than 1 webcam)
preview(cam);            % Preview Video Stream

clear cam                % Release webcam


%% Connect to Spheros

clc;
SpheroState = SpheroConnect_Ver1_3(CameraParam, SpheroState);
numRobLocal = SpheroState.numRobLocal;

% Turn off all Sphero LEDs
pause(3);
for j = 1 : numRobLocal
    SpheroState.Sph{j}.Color = [0,50,0];
    pause(0.5);
end


%% Settings for recording the experiment movies

SpheroState.Video.VideoName = 'Test01';
SpheroState.Video.Record    = false;
SpheroState                 = SpheroVideoSetup_Ver1_0(SpheroState);


%% Initialize camera and detect checkerboard
%
% Camera must be looking at the arena floor and a checkerboard must be
% placed on the floor before running this section.
%
% If you don't have a checkerboard ready, you can print and use the one 
% included in the "Images" folder. You need to make sure that "squareSize" 
% is the correct size of each square on your printed checkerboard.
%
% For more detail on camera calibration see
% https://mathworks.com/help/vision/ug/single-camera-calibrator-app.html

CameraParam.squareSize = 28; % Checkerboard square size in mm
CameraParam.paramFile  = 'CameraParams_Logitech_640x480_Gans.mat';
CameraParam.camID      = 1;

CameraParam = CameraCheckerboard_Ver1_2(CameraParam);


%% Theta0 estimation
%
% In this section we estimate the initil heading direction of each Sphero.
% The Sphero with LEDs turned on should be placed on the arena floor. Once 
% a key is pressed the robot rolls forward and its initial heading is estimated. 

clc
SpheroState.Theta0 = SpheroTheta0_Ver1_5(SpheroState, CameraParam);


%% Setup TCPIP info
%
% This section is used when we have more than 1 computer. If you are using
% only 1 computer set:
%
% SpheroTCPIP.server  = 1;
% SpheroTCPIP.ip      = [];
%
% and comments the rest. 
%
% When dealing with more than 1 computer, the computer use TCPIP initially
% to come to a consensus on the tag number of robots, and communicate the 
% formation control gains. After this is done, there is no more need for 
% communication and  experiment runs in a distributed manner. 

SpheroTCPIP.server  = 0;                % 1 <--> server computer (or only one computer), 0 <--> client computer
% SpheroTCPIP.ip    = [];               % if only one computer is used
SpheroTCPIP.ip      = ["192.168.1.8"];  % of server or clients
SpheroTCPIP.gains   = [];               % update when calculated


%% Formation Control Gains
%
% In this section we find the formation control gains by solving an SDP
% problem using CVX.  CVX is a free software and is included in this
% folder.  You need to run "cvx_setup.m" before executing this section.

% If server, calculate formation control gains
if SpheroTCPIP.server == 1
    SpheroState = FormCtrlDesign_Ver_1_1(SpheroState); % Design control gains
    SpheroTCPIP.gains = SpheroState.A;
end


%% Main loop 

clc
close all

% Turn off Sphero LEDs
for j = 1 : numRobLocal
    SpheroState.Sph{j}.Color = [0,0,0];
    pause(0.5);
end

% Preallocate required variables
SpheroState = SpheroLoadParam_Ver1_4(SpheroState); % This file is used to set the low-level PID gains, max speed, etc.

itr = 0; % Iteration number
while  true % Main loop (press ctrl+c to stop)
itr = itr + 1;

j = 0;
while j <= numRobLocal-1
j = j + 1;
iitr = (itr-1)*numRobLocal + j; % Current iteration number

% Sphero detection, tracking, and 3D reconstruction
disp('Image detection & tracking');
SpheroState = SpheroTCPIPDetectionTracking_Ver1_2(iitr, SpheroState, CameraParam, SpheroTCPIP);

% Reset detection when it fails
if any(isnan(SpheroState.PosWorld(:,:,iitr))), itr = 1; j = 0; close all; continue; end

% Heading and speed estimation
disp('Heading and speed estimation');
SpheroState.Time(iitr)  =  cputime;
SpheroState = SpheroHeadingSpeedEstim_Ver1_2(iitr, SpheroState);

% Formation control (can replace with your own multi-agent algorithm)
disp('Calculating control');
SpheroState = FormationControl_Ver3_2(iitr,itr,j, SpheroState, CameraParam);

% Sphero control
disp('Sphero control');
SpheroState = SpheroControl_Ver3_1(iitr,itr,j, SpheroState, CameraParam);  % Single-integrator control 
% SpheroState = SpheroControl_Nonhol_Ver3_2(iitr,itr,j, SpheroState, CameraParam);  % Unicycle control

% Kalman Filter
disp('Kalman filter');
SpheroState = SpheroKalmanFilter_Ver1_2(iitr, SpheroState);

% Display video stream
SpheroState = SpheroVideoStream_Ver1_3(iitr, SpheroState, CameraParam);

% Keep only up to the last 'numItr' number of data
SpheroState = SpheroShiftData_Ver1_1(itr, SpheroState);
if itr == numItr, itr = itr - 1; end

fprintf('\n\n\n');

end
end


%% Stop Spheros and reset headings to zero

SpheroStopVideo(SpheroState);  % Close and save video

for j = 1 : numRobLocal
    brake(SpheroState.Sph{j});     % Stop Spheros
    roll(SpheroState.Sph{j},0,0);  % Reset orientation
end

%% Disconnect from Spheros

SpheroDisconnect_Ver1_1(SpheroState);


