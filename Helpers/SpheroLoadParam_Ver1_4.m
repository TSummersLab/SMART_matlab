function SpheroState = SpheroLoadParam_Ver1_4(SpheroState)


numItr =  SpheroState.numItr;                        % Number of iterations
numRob =  SpheroState.numRob;                        % Total number of robots
numRobLocal =  SpheroState.numRobLocal;              % Number of robots in each computer


SpheroState.Param.numRob          = numRob;          % Number of robots
SpheroState.Param.kv              = 0.5;             % Gain for V low-pass filter
SpheroState.Param.distPixelThresh = 5;               % Threshold for estimating the heading
SpheroState.Param.VelPixelThresh  = 10;              % Threshold to identify robots with large enough motion
SpheroState.Param.vMax            = 50;              % Maximum allowed velocity
SpheroState.Param.Kp              = 7e0;             % P-Gain for PID control
SpheroState.Param.Kd              = 0;               % D-Gain for PID control
SpheroState.Param.Ki              = 5;               % I-Gain for PID control

% Collision avoidance parameters
SpheroState.Param.dcoll           = 100;             % Threshold to activate collision avoidance (in mm)
SpheroState.Param.hcone           = 10000;           % Base length of the collision cone (in mm)

% Kalman filter parameters
SpheroState.Param.Qkalm           = [1.0   0.0   0.0
                                     0.0   1.0   0.0
                                     0.0   0.0   1.0];     % Covariance of process
SpheroState.Param.Rkalm           = [0.1   0.0   0.0
                                     0.0   0.1   0.0
                                     0.0   0.0   0.1];     % Covariance of measurement 
SpheroState.Param.Pkalm           = repmat([0.1   0.0   0.0
                                            0.0   0.1   0.0
                                            0.0   0.0   1.5], 1,1,numRob);  % Initial state covraiance
     


% SpheroState.iitr        = iitr;
SpheroState.Time          = zeros(numItr*numRobLocal, 1);         % CPU time at each iteration
SpheroState.PosWorld      = NaN(2,numRob, numItr*numRobLocal);    % Position array of robots (in world frame)
SpheroState.PosKalm       = zeros(2,numRob, numItr*numRobLocal);  % Position from Kalman filter (in world frame)
SpheroState.PosPixel      = NaN(2,numRob, numItr*numRobLocal);    % Pixel position array of robots
SpheroState.Bboxes        = zeros(4,numRob, numItr*numRobLocal);  % Bounding boxes for display
SpheroState.PosPixelAll   = cell(numItr*numRobLocal, 1);          % Position of all detected objects (unordered)
SpheroState.BboxesAll     = cell(numItr*numRobLocal, 1);          % Bounding boxes of all detected objects (unordered)

SpheroState.VelWorld      = zeros(numItr*numRobLocal, numRob);    % Estimated speed in world coordinate frame
SpheroState.VelPixel      = zeros(numItr*numRobLocal, numRob);    % Estimated speed in pixels
SpheroState.VelPixelFilt  = zeros(numItr*numRobLocal, numRob);    % Low-pass filtered speed in pixels
SpheroState.VelWorldFilt  = zeros(numItr*numRobLocal, numRob);    % Low-pass filtered speed in world coordinates
SpheroState.VelCtrl       = zeros(numItr, numRob);                % Desired speed from control command 
SpheroState.VelInput      = zeros(numItr, numRob);                % Speed input command 
SpheroState.VelSatInput   = zeros(numItr, numRob);                % Saturated speed input command 
SpheroState.VelErrInt     = zeros(1, numRob);                     % Integral of velocity error for PID control


SpheroState.MotionIndex   = false(numItr*numRobLocal, numRob);    % Index to robots with large enough motion
SpheroState.ThtEst        = NaN(numItr*numRobLocal,numRob);       % Estimated heading from image
SpheroState.ThtKalm       = zeros(numItr*numRobLocal,numRob);     % Estimated headings from Kalman filter
SpheroState.ThtCtrl       = NaN(numItr*numRobLocal, numRob);      % Desired angle from control command
SpheroState.ThtInput      = zeros(numItr, numRob);                % Heading angle input command
SpheroState.Omega         = zeros(numItr*numRobLocal, numRob);    % Angular velocity 
SpheroState.Ctrl          = NaN(2,numRob, numItr*numRobLocal);    % Control vectors

SpheroState.Video.Frames  = cell(numItr*numRobLocal,1);           % Video stream


SpheroState.SphFlag       = [];                                  % Indicates what robots in SheroState.Pos* belong to this machine

































