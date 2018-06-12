
% Version 10.1:
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

SphNames = {'OGY', 'WYP', 'OYR'};                % Name of spheros
% 'YWB', 'WWP', 'WYP' ,'OWY', 'OGY', 'YWR', 'WOR', 'OYR', 'ROY', 'RPY'
CameraParam.col = [0, 255, 255]; % Detection color for followers (red)
SpheroState.SphNames = SphNames;

numItr             = 100;         % Number of iterations to keep the data (must be > 1)
SpheroState.numItr = numItr;
SpheroState.numRob = 3;           % Total number of robots

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


%% Record movie (Video settings)

SpheroState.Video.VideoName = 'Test01';
SpheroState.Video.Record    = true;

SpheroState = SpheroVideoSetup_Ver1_0(SpheroState);


%% Initialize camera and detect checkerboard

CameraParam.squareSize = 28; % Checkerboard square size in mm
CameraParam.paramFile  =  'CameraParams_Logitech_640x480_Gans.mat';
CameraParam.camID  =  1;

CameraParam = CameraCheckerboard_Ver1_2(CameraParam);


%% Theta0 estimation

clc
SpheroState.Theta0 = SpheroTheta0_Ver1_5(SpheroState, CameraParam);     


%% Formation Control Gains

% Setup TCPIP info
SpheroTCPIP.setup = 0;
SpheroTCPIP = SetupTCPIP(SpheroTCPIP);

% If server Calculate formation control gains and save them to TCPIP
if SpheroTCPIP.server == 1
    SpheroState = FormCtrlDesign_Ver_1_1(SpheroState);  % Desing control gains
    SpheroTCPIP.gains = SpheroState.A;
end


%% Formation control

clc
close all

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
SpheroState = SpheroDetectionTracking_Ver2_1(iitr, SpheroState, CameraParam, SpheroTCPIP);

% Reset detection when it fails
if any(isnan(SpheroState.PosWorld(:,:,iitr))), itr = 1; j = 0; close all; continue; end

% Heading and speed estimation
disp('Heading and speed estimation');
SpheroState.Time(iitr)  =  cputime;
SpheroState = SpheroHeadingSpeedEstim_Ver1_2(iitr, SpheroState);

% Formation control  
disp('Control');
SpheroState = SpheroControl_Ver2_2(iitr,itr,j, SpheroState, CameraParam);

% Kalman Filter
disp('Kalman filter');
SpheroState = SpheroKalmanFilter_Ver1_2(iitr, SpheroState);

% Display video stream
SpheroState = SpheroVideoStream_Ver1_3(iitr, SpheroState, CameraParam);

% Keep only up to the last 'numItr' number of data
SpheroState = SpheroShiftData_Ver1_0(itr, SpheroState);
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
























































