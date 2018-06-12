%%%%%%%%%%%%%%%%%%%
% Sphero  control %
%%%%%%%%%%%%%%%%%%%  
%
% Ver3_1:
%           - Separates Sphero control from formation control
%           - Integrator control
%
%
function SpheroState = SpheroControl_Ver3_1(iitr,itr,j, SpheroState, CameraParam)


PosWorld    = SpheroState.PosWorld;     % Positions in world coordinate frame
PosKalm     = SpheroState.PosKalm;      % Position of robots from Kalman filter(in world frame)
ThtKalm     = SpheroState.ThtKalm;      % Estimated headings from Kalman filter
MotionIndex = SpheroState.MotionIndex;  % Index to identify motion
VelWorld    = SpheroState.VelWorld;     % Estimated speed
VelWorldFilt= SpheroState.VelWorldFilt; % Filtered estimated speed
Omega       = SpheroState.Omega;        % Angular velocity 
Time        = SpheroState.Time;         % CPU time at each iteration
Sph         = SpheroState.Sph;          % Spheros
VelCtrl     = SpheroState.VelCtrl;      % Speed from control vector
ThtCtrl     = SpheroState.ThtCtrl;      % Heading from control vector
VelInput    = SpheroState.VelInput;     % Input speed
VelSatInput = SpheroState.VelSatInput;  % Input speed
ThtInput    = SpheroState.ThtInput;     % Input heading
Theta0      = SpheroState.Theta0;       % Orientation bias

vMax        = SpheroState.Param.vMax;   % Maximum allowed velocity
Kp          = SpheroState.Param.Kp;     % P-Gain for PID control
Kd          = SpheroState.Param.Kd;     % D-Gain for PID control
Ki          = SpheroState.Param.Ki;     % I-Gain for PID control
VelErrInt   = SpheroState.VelErrInt;    % Integral of velocity error for PID control

% Calib       = CameraParam.Calib;            % Interinsics of camera
% R           = CameraParam.Rot;              % Rotation matrix of camera
% T           = CameraParam.Tran;             % Translation vector of camera
% PosPixel    = SpheroState.PosPixel;         % Pixel position of Spheros
% PosPixelAll = SpheroState.PosPixelAll;      % Pixel postion of all detected objects

numRob      = SpheroState.numRob;           % Total number of robots
numRobLocal = SpheroState.numRobLocal;      % Number of robots in each computer
SphFlag     = SpheroState.SphFlag;          % Indicates what robots in SheroState.PosPixAll belong to this machine
Ctrl        = SpheroState.Ctrl;             % Desired control vector


%% Index of robots being controlled

SphIdx = find(SphFlag);
jj = SphIdx(j);


%% Sphero Control

ctrl  = Ctrl(:,:,iitr);                  % Desired control direction
speed = sqrt(sum(ctrl.^2, 1));           % Desired speed

% Integrator control
VelErrInt = VelErrInt + Ki * (speed-VelWorldFilt(iitr,:));
VelErrInt = min(VelErrInt, vMax);  % Anti-windup
VelErrInt = max(VelErrInt, 0);  % Anti-windup

% PID control for speed
VelCtrl(iitr,:) = Kp .* speed - Kd .* VelWorldFilt(iitr,:) + VelErrInt;  

% Speed of Sphero
vel = VelCtrl(iitr,jj);                 % Sphero velocity
VelInput(itr,jj) = vel;                       
vel = min(vel,vMax);                    % Limit speed to maximum allowed velocity
vel = max(vel,0.01);                    % Keep speed > 0 
VelSatInput(itr,jj) = vel;              % Saturated speed

thtC = atan2d(ctrl(2,jj), ctrl(1,jj));  % Control vector angle in world coordinate frame
ThtCtrl(iitr,jj) = thtC;

ThtInput(itr,jj) = wrapTo180( Theta0(j) - ThtCtrl(iitr,jj) );

if itr > 1
    dT = Time(iitr) - Time(iitr-1);
    Omega(iitr,jj) = wrapTo180( ThtInput(itr,jj) - ThtInput(itr-1,jj) ) ./ dT; % Angular velocity input
end

% Issue input command   
% if j == 3
roll(Sph{j}, VelSatInput(itr,jj), ThtInput(itr,jj) );
% end

%%

SpheroState.VelCtrl     = VelCtrl;      % Speed from control vector
SpheroState.ThtCtrl     = ThtCtrl;      % Heading from control vector
SpheroState.VelInput    = VelInput;     % Input speed
SpheroState.VelSatInput = VelSatInput;  % Input speed
SpheroState.ThtInput    = ThtInput;     % Input heading
SpheroState.Omega       = Omega;        % Angular velocity 
SpheroState.VelErrInt   = VelErrInt;    % Integral of velocity error for PID control


















































































































