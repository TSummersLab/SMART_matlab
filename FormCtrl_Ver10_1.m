
% Version 10.1: 
%               - Inocrporated formation control
%               
% Version 9.9: 
%               - Updated SpheroConnect
%
%
% Version 9.6S: 
%               - Indefinite loop (while instead of for)
%
% Version 9.5S:
%               - Special version for leader follow
%               - modified function are replaced with the s version too
%               - S stands for Special
% 
% Version 9.5:
%               - Automatic connecttion to Spheros
%               - Show video feed while running the experiment
%
% Version 9.4:
%               - Uses theta0 estimation
%
% Version 9.3:
%               - Uses Kalman filter to control robot motion
%
% Version 9.2:
%               - Uses Kalman filter to track heading of one robot
%
% Version 9.1:
%               - Preparing to use Kalman filter to track robots
%
addpath(genpath('Sphero'));
addpath('Helpers');
addpath('Formation Control');
addpath('EKF')
addpath('CVX')
addpath(genpath('Calibration Images'));


%% Preallocate parameters

SphNames = {'OYR', 'OGY', 'WWP'};                % Name of spheros
% 'YWB', 'WWP', 'WYP' ,'OWY', 'OGY', 'YWR', 'WOR', 'OYR', 'ROY', 'RPY'

CameraParam.col = [0,   255,   255]; % Detection color for followers (cyan)
SpheroState.SphNames = SphNames;

numItr             = 10;         % Number of iterations to keep the data (must be > 1)
SpheroState.numItr = numItr;


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
SpheroState = SpheroConnect_Ver1_1(CameraParam, SpheroState);
numRob      = SpheroState.numRob;


%% Record movie (Video settings)

SpheroState.Video.VideoName = 'Test04';
SpheroState.Video.Record    = false; % ture;

SpheroState = SpheroVideoSetup_Ver1_0(SpheroState);


%% Initialize camera and detect checkerboard

CameraParam.squareSize = 28; % Checkerboard square size in mm
CameraParam.paramFile  =  'CameraParams_Logitech_640x480_Gans.mat';

CameraParam = CameraCheckerboard(CameraParam);


%% Theta0 estimation

clc
SpheroState.Theta0 = SpheroTheta0_Ver1_3(SpheroState, CameraParam);     


%% Formation Control Gains

% Size of desired formation 
scale = 400; % in mm

% Desired formation coordinates
qDes = [0    -2    -2    -4    -4    -4
        0    -1     1    -2     0     2]*scale;
SpheroState.Ctrl.posDes = qDes;      % Desired Formation

% Graph adjacency matrix (must be symmetric)
Adj = [ 0     1     1     0     0     0
        1     0     1     1     1     0
        1     1     0     0     1     1
        0     1     0     0     1     0
        0     1     1     1     0     1
        0     0     1     0     1     0];   
% Adj(:,:,1) = ones(numRob) - eye(numRob); % Complete graph    
SpheroState.Ctrl.Adj = Adj;      % Graph adjacency matrix

% Find stabilizing formation control gains 
cvx_startup;
A = FindGains(qDes(:), Adj); 
SpheroState.A = A;


%% Formation control

clc
close all

% Preallocate required variables
SpheroState = SpheroLoadParam_Ver1_3(SpheroState);

itr = 0;
while  true
itr = itr + 1;    

j = 0;
while j <= numRob-1
j = j + 1;    
iitr = (itr-1)*numRob + j; % Current iteration number

% Sphero detection, tracking, and 3D reconstruction  
disp('Image detection & tracking');
SpheroState = SpheroDetectionTracking_Ver1_4(iitr, SpheroState, CameraParam);

% Reset detection when it fails
if any(isnan(SpheroState.PosPixel(:,:,iitr))), itr = 1; j = 0; close all; continue; end

% Heading and speed estimation
disp('Heading and speed estimation');
SpheroState.Time(iitr)  =  cputime;
SpheroState = SpheroHeadingSpeedEstim_Ver1_2(iitr, SpheroState);

% Formation control  
disp('Control');
SpheroState = SpheroControl_Ver2_1(iitr,itr,j, SpheroState, CameraParam);

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

for j = 1 : numRob
    brake(SpheroState.Sph{j});     % Stop Spheros
    roll(SpheroState.Sph{j},0,0);  % Reset orientation
end
    
%% Disconnect from Spheros

SpheroDisconnect_Ver1_1(SpheroState);


%% Reset headings to zero

% for j =  1 : numRob
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
























































