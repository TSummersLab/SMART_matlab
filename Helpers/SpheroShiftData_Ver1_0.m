function SpheroState = SpheroShiftData_Ver1_0(itr, SpheroState)


numItr =  SpheroState.numItr;                        % Number of iterations
numRob =  SpheroState.numRob;                        % Number of iterations

% Y = circshift(A,K,dim) circularly shifts the values in array A by K 
% positions along dimension dim. 

if itr == numItr  % Shift variables
    
SpheroState.Time          = circshift(SpheroState.Time       , -numRob, 1);  % CPU time at each iteration
SpheroState.PosWorld      = circshift(SpheroState.PosWorld   , -numRob, 3);  % Position array of robots (in world frame)
SpheroState.PosKalm       = circshift(SpheroState.PosKalm    , -numRob, 3);  % Position from Kalman filter (in world frame)
SpheroState.PosPixel      = circshift(SpheroState.PosPixel   , -numRob, 3);  % Pixel position array of robots
SpheroState.Bboxes        = circshift(SpheroState.Bboxes     , -numRob, 3);  % Bounding boxes for display
SpheroState.PosPixelAll   = circshift(SpheroState.PosPixelAll, -numRob, 1);  % Position of all detected objects (unordered)
SpheroState.BboxesAll     = circshift(SpheroState.BboxesAll  , -numRob, 1);  % Bounding boxes of all detected objects (unordered)

SpheroState.VelWorld      = circshift(SpheroState.VelWorld    , -numRob, 1); % Estimated speed in world coordinate frame
SpheroState.VelPixel      = circshift(SpheroState.VelPixel    , -numRob, 1); % Estimated speed in pixels
SpheroState.VelPixelFilt  = circshift(SpheroState.VelPixelFilt, -numRob, 1); % Low-pass filtered speed in pixels
SpheroState.VelWorldFilt  = circshift(SpheroState.VelWorldFilt, -numRob, 1); % Low-pass filtered speed in world coordinates
SpheroState.VelCtrl       = circshift(SpheroState.VelCtrl     , -1, 1);      % Desired speed from control command 
SpheroState.VelInput      = circshift(SpheroState.VelInput    , -1, 1);      % Speed input command 
SpheroState.VelSatInput   = circshift(SpheroState.VelSatInput , -1, 1);      % Saturated speed input command 

SpheroState.MotionIndex   = circshift(SpheroState.MotionIndex, -numRob, 1);  % Index to robots with large enough motion
SpheroState.ThtEst        = circshift(SpheroState.ThtEst     , -numRob, 1);  % Estimated heading from image
SpheroState.ThtKalm       = circshift(SpheroState.ThtKalm    , -numRob, 1);  % Estimated headings from Kalman filter
SpheroState.ThtCtrl       = circshift(SpheroState.ThtCtrl    , -numRob, 1);  % Desired angle from control command
SpheroState.ThtInput      = circshift(SpheroState.ThtInput   , -1, 1);       % Heading angle input command
SpheroState.Omega         = circshift(SpheroState.Omega      , -numRob, 1);  % Angular velocity 

SpheroState.Video.Frames  = circshift(SpheroState.Video.Frames, -numRob, 1); % Video stream


end






























































































