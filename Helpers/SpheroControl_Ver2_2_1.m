%%%%%%%%%%%%%%%%%%%
% Sphero  control %
%%%%%%%%%%%%%%%%%%%  
%
% Ver 2_2_1:
%           - Formation control with fixed scale
%
%
function SpheroState = SpheroControl_Ver2_2_1(iitr,itr,j, SpheroState, CameraParam)


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
A           = SpheroState.A;            % Formation control gains

vMax        = SpheroState.Param.vMax;   % Maximum allowed velocity
Kp          = SpheroState.Param.Kp;     % P-Gain for PID control
Kd          = SpheroState.Param.Kd;     % D-Gain for PID control

% Calib       = CameraParam.Calib;            % Interinsics of camera
% R           = CameraParam.Rot;              % Rotation matrix of camera
% T           = CameraParam.Tran;             % Translation vector of camera
% PosPixel    = SpheroState.PosPixel;         % Pixel position of Spheros
% PosPixelAll = SpheroState.PosPixelAll;      % Pixel postion of all detected objects
Ctrl        = SpheroState.Ctrl;             % Control vectors
numRob      = SpheroState.numRob;           % Total number of robots
numRobLocal = SpheroState.numRobLocal;      % Number of robots in each computer
SphFlag     = SpheroState.SphFlag;          % Indicates what robots in SheroState.PosPixAll belong to this machine
Adj         = SpheroState.Adj;              % Graph adjacency matrix
Dd          = SpheroState.Dd;               % Desired inter-agent distances


%% Inded of robots being controlled

SphIdx = find(SphFlag);
jj = SphIdx(j);


%% Formation Control

% Coordinate of all robots
posWorld = PosWorld(:,:,iitr);      

% Current distances
Dc = zeros(numRob,numRob); % inter-agent distances in current formation
for i = 1 : numRob
    for k = i+1 : numRob
        Dc(i,k) = norm(posWorld(:,i)-posWorld(:,k), 2);
    end
end
Dc = Dc + Dc';

sat = 30; % Saturation (in mm)

% Control to fix the scale
g = (1/numRob)*(1/pi); % Gain
F = g * atan( (1/sat)* Adj.*(Dc-Dd) );
F = F + diag(-sum(F,2));
F2 = C2R(F);

q = posWorld(:) ./ max(abs(posWorld(:))); % Aggregate position vector (normalized)    
dq = A * q + F2 * q;            % Control velocity vectors

% Normalize the control vector's length
dqNrm = sqrt(sum(dq.^2, 1));
if any(dqNrm > vMax)
    dq = dq ./ max(dqNrm) .* vMax;
end

% Reshape into matrix format
ctrl = reshape(dq,2,numRob);


%% Sphero Control

% VelCtrl(iitr,:) = vdGain .* sqrt(sum(ctrl.^2, 1)); % Desired speed
VelCtrl(iitr,:) = Kp .* sum(ctrl.^2, 1) - Kd .* VelWorldFilt(iitr,:) ;  % Desired speed

% Speed of Sphero
vel = 0.1 * VelCtrl(iitr,jj);           % Desired speed
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

Ctrl(:,:,iitr) = ctrl;

SpheroState.VelCtrl     = VelCtrl;      % Speed from control vector
SpheroState.ThtCtrl     = ThtCtrl;      % Heading from control vector
SpheroState.VelInput    = VelInput;     % Input speed
SpheroState.VelSatInput = VelSatInput;  % Input speed
SpheroState.ThtInput    = ThtInput;     % Input heading
SpheroState.Omega       = Omega;        % Angular velocity 
SpheroState.Ctrl        = Ctrl;         % Control vectors


















































































































