
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

SphNames = {'YWR', 'WOR'};                % Name of spheros
% 'YWB', 'WWP', 'WYP' ,'OWY', 'OGY', 'YWR', 'WOR', 'OYR', 'ROY', 'RPY'
CameraParam.col = [0, 255, 255]; % Detection color for followers (red)
SpheroState.SphNames = SphNames;

numItr             = 100;         % Number of iterations to keep the data (must be > 1)
SpheroState.numItr = numItr;
SpheroState.numRob = 3;          % Total number of robots

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

pause(3); % pause before turning off all spheros

for j = 1 : numRobLocal
    
    SpheroState.Sph{j}.Color = [0,0,0];
    pause(0.5);
    
end



%% Record movie (Video settings)

SpheroState.Video.VideoName = 'Test01';
SpheroState.Video.Record    = true;

SpheroState = SpheroVideoSetup_Ver1_0(SpheroState);


%% Initialize camera and detect checkerboard

CameraParam.squareSize = 28; % Checkerboard square size in mm
CameraParam.paramFile  =  'CameraParams_Logitech_640x480_Gans.mat';
CameraParam.camID = 1;
CameraParam = CameraCheckerboard_Ver1_2(CameraParam);


%% Theta0 estimation

clc
SpheroState.Theta0 = SpheroTheta0_Ver1_5(SpheroState, CameraParam);     


%% Turn off Spheros


for j = 1 : numRobLocal
    
    SpheroState.Sph{j}.Color = [0,0,0];
    pause(0.5);
    
end

%% Formation Control Gains
% Setup TCPIP info
SpheroTCPIP.setup = 0;
SpheroTCPIP = SetupTCPIP(SpheroTCPIP);


SpheroTCPIP.server = 1; % 1 <--> server computer, 0 <--> client computer
SpheroTCPIP.ip = ["192.168.1.5"]; % of server or clients
SpheroTCPIP.gains = []; % update when calculated
SpheroTCPIP.setup = 1; % setup is complete


% If server Calculate formation control gains and save them to TCPIP
if SpheroTCPIP.server == 1
    % Size of desired formation 
    scale = 400; % in mm

    % Desired formation coordinates
    qDes = [0    1     0.5      ;    
            0    0     sqrt(3)/2] * scale;
%     qDes = [0    -2    -2    -4    -4    -4
%             0    -1     1    -2     0     2]*scale;
    SpheroState.posDes = qDes;      % Desired Formation

    % Graph adjacency matrix (must be symmetric)
%     Adj = [ 0     1     1     0     0     0
%             1     0     1     1     1     0
%             1     1     0     0     1     1
%             0     1     0     0     1     0
%             0     1     1     1     0     1
%             0     0     1     0     1     0];   
    Adj(:,:,1) = ones(SpheroState.numRob) - eye(SpheroState.numRob); % Complete graph    
    SpheroState.Adj = Adj;      % Graph adjacency matrix

    % Find stabilizing formation control gains 
    cvx_startup;
    A = FindGains(qDes(:), Adj); 
    SpheroState.A = A;
    SpheroTCPIP.gains = SpheroState.A;
end

%% Turn off Spheros


for j = 1 : numRobLocal
    
    SpheroState.Sph{j}.Color = [0,0,0];
    pause(0.5);
    
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
SpheroState = SpheroTCPIPDetectionTracking_Ver1_1(iitr, SpheroState, CameraParam, SpheroTCPIP);

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
























































