function SpheroState = SpheroShiftData_Ver1_1(itr, SpheroState)


numItr =  SpheroState.numItr;                        % Number of iterations
numRob =  SpheroState.numRob;                        % Number of iterations
numRobLocal =  SpheroState.numRobLocal;              % Number of robots in each computer

% Y = circshift(A,K,dim) circularly shifts the values in array A by K 
% positions along dimension dim. 

if itr == numItr  % Shift variables
    
SpheroState.Time          = circshift(SpheroState.Time       , -numRobLocal, 1);  % CPU time at each iteration
SpheroState.PosWorld      = circshift(SpheroState.PosWorld   , -numRobLocal, 3);  % Position array of robots (in world frame)
SpheroState.PosKalm       = circshift(SpheroState.PosKalm    , -numRobLocal, 3);  % Position from Kalman filter (in world frame)
SpheroState.PosPixel      = circshift(SpheroState.PosPixel   , -numRobLocal, 3);  % Pixel position array of robots
SpheroState.Bboxes        = circshift(SpheroState.Bboxes     , -numRobLocal, 3);  % Bounding boxes for display
SpheroState.PosPixelAll   = circshift(SpheroState.PosPixelAll, -numRobLocal, 1);  % Position of all detected objects (unordered)
SpheroState.BboxesAll     = circshift(SpheroState.BboxesAll  , -numRobLocal, 1);  % Bounding boxes of all detected objects (unordered)

SpheroState.VelWorld      = circshift(SpheroState.VelWorld    , -numRobLocal, 1); % Estimated speed in world coordinate frame
SpheroState.VelPixel      = circshift(SpheroState.VelPixel    , -numRobLocal, 1); % Estimated speed in pixels
SpheroState.VelPixelFilt  = circshift(SpheroState.VelPixelFilt, -numRobLocal, 1); % Low-pass filtered speed in pixels
SpheroState.VelWorldFilt  = circshift(SpheroState.VelWorldFilt, -numRobLocal, 1); % Low-pass filtered speed in world coordinates
SpheroState.VelCtrl       = circshift(SpheroState.VelCtrl     , -1, 1);           % Desired speed from control command 
SpheroState.VelInput      = circshift(SpheroState.VelInput    , -1, 1);           % Speed input command 
SpheroState.VelSatInput   = circshift(SpheroState.VelSatInput , -1, 1);           % Saturated speed input command 

SpheroState.MotionIndex   = circshift(SpheroState.MotionIndex, -numRobLocal, 1);  % Index to robots with large enough motion
SpheroState.ThtEst        = circshift(SpheroState.ThtEst     , -numRobLocal, 1);  % Estimated heading from image
SpheroState.ThtKalm       = circshift(SpheroState.ThtKalm    , -numRobLocal, 1);  % Estimated headings from Kalman filter
SpheroState.ThtCtrl       = circshift(SpheroState.ThtCtrl    , -numRobLocal, 1);  % Desired angle from control command
SpheroState.ThtInput      = circshift(SpheroState.ThtInput   , -1, 1);            % Heading angle input command
SpheroState.Omega         = circshift(SpheroState.Omega      , -numRobLocal, 1);  % Angular velocity 
SpheroState.Ctrl          = circshift(SpheroState.Ctrl       , -numRobLocal, 3);  % Control vectors

SpheroState.Video.Frames  = circshift(SpheroState.Video.Frames, -numRobLocal, 1); % Video stream


end






























































































