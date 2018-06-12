% Version 1.1:
%               - Uses TCP/IP to run formation control between different
%               computers
%               - Modifies some functions (SpheroDetectInitial, and makes
%               reconstruction a function
%               - Inocrporated formation control
%
addpath(genpath('Sphero'));
addpath('Helpers');
addpath('Formation Control');
addpath('EKF');
addpath('CVX');
addpath(genpath('Calibration Images'));


%% Preallocate parameters

SphNames = { 'RPY', 'YWR', 'WWP'};                % Name of spheros
% 'YWB', 'WWP', 'WYP' ,'OWY', 'OGY', 'YWR', 'WOR', 'OYR', 'ROY', 'RPY'
CameraParam.col = [0, 255, 255]; % Detection color for followers (red)
SpheroState.SphNames = SphNames;

numItr             = 5000;         % Number of iterations to keep the data (must be > 1)
SpheroState.numItr = numItr;
SpheroState.numRob = 9;          % Total number of robots

%% Test Webcam

% camList = webcamlist;  % Identify Available Webcams
if isfield(CameraParam,'cam')
    delete(CameraParam.cam)
    CameraParam = rmfield(CameraParam,'cam');
end
cam = webcam(1);         % Connect to the webcam
preview(cam);            % Preview Video Stream

clear cam                % Release webcam 


%% Connect to Spheros

clc;

SpheroState = SpheroConnect_Ver1_3(CameraParam, SpheroState);
numRobLocal = SpheroState.numRobLocal;

% pause before turning off all sphero LEDs
pause(3);
for j = 1 : numRobLocal
    SpheroState.Sph{j}.Color = [0,50,0];
    pause(0.5);
end


%% Record movie (Video settings)

SpheroState.Video.VideoName = 'Test01';
SpheroState.Video.Record    = false;

SpheroState = SpheroVideoSetup_Ver1_0(SpheroState);


%% Initialize camera and detect checkerboard

CameraParam.squareSize = 28; % Checkerboard square size in mm
CameraParam.paramFile  =  'CameraParams_Logitech_640x480_Gans.mat';
CameraParam.camID = 1;

CameraParam = CameraCheckerboard_Ver1_2(CameraParam);


%% Theta0 estimation

clc

SpheroState.Theta0 = SpheroTheta0_Ver1_5(SpheroState, CameraParam);     


%% Formation Control Gains

% Setup TCPIP info
SpheroTCPIP.server = 0; % 1 <--> server computer, 0 <--> client computer
SpheroTCPIP.ip = ["192.168.1.8"]; % of server or clients
% SpheroTCPIP.ip = []; % of server or clients
SpheroTCPIP.gains = []; % update when calculated

% If server, calculate formation control gains
if SpheroTCPIP.server == 1
    SpheroState = FormCtrlDesign_Ver_1_1(SpheroState); % Design control gains
    SpheroTCPIP.gains = SpheroState.A;
end


%% Formation control

clc
close all

% Turn off Sphero LEDs
for j = 1 : numRobLocal
    SpheroState.Sph{j}.Color = [0,0,0];
    pause(0.5);
end


% Preallocate required variables
SpheroState = SpheroLoadParam_Ver1_4(SpheroState);


itr = 0;
while  true
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

% Formation control  
disp('Calculating control');
SpheroState = FormationControl_Ver3_2(iitr,itr,j, SpheroState, CameraParam);

% Sphero control
disp('Sphero control');
SpheroState = SpheroControl_Ver3_1(iitr,itr,j, SpheroState, CameraParam);
% SpheroState = SpheroControl_Nonhol_Ver3_2(iitr,itr,j, SpheroState, CameraParam);


% Kalman Filter
disp('Kalman filter');
SpheroState = SpheroKalmanFilter_Ver1_2(iitr, SpheroState);

% Display video stream
% SpheroState = SpheroVideoStream_Ver1_3(iitr, SpheroState, CameraParam);

% Keep only up to the last 'numItr' number of data
SpheroState = SpheroShiftData_Ver1_1(itr, SpheroState);
if itr == numItr, itr = itr - 1; end

fprintf('\n\n\n')
% keyboard; % dbcont;

end
end









%% Stop Spheros

SpheroStopVideo(SpheroState);  % Close and save video

for j = 1 : numRobLocal
    brake(SpheroState.Sph{j});     % Stop Spheros
    roll(SpheroState.Sph{j},0,0);  % Reset orientation
end
    
%% Disconnect from Spheros

SpheroDisconnect_Ver1_1(SpheroState);


%% Reset headings to zero

% for j =  1 : numRobLocal
%     roll(SpheroState.Sph{j},0,0); % Reset headings to zero
% end

%% Save variables

% if ~exist(Name)
%     Name = 'Sphero_v7_01_vid_01';
% end
% currentFolder = pwd;
% address =  strcat(currentFolder,'/SavedData/');
% fileName = strcat(Name, '_data');
% fileType = '.mat';
% fullAddress = strcat(address,fileName,fileType);
% 
% % Save all variables
% save(fullAddress)
























































