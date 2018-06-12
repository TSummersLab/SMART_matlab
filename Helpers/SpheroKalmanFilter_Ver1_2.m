%%%%%%%%%%%%%%%%%
% Kalman Filter %
%%%%%%%%%%%%%%%%% 
function SpheroState = SpheroKalmanFilter_Ver1_2(iitr, SpheroState)



PosWorld    = SpheroState.PosWorld;    % Positions in world coordinate frame
PosKalm     = SpheroState.PosKalm;     % Position of robots from Kalman filter(in world frame)
ThtKalm     = SpheroState.ThtKalm;     % Estimated headings from Kalman filter
MotionIndex = SpheroState.MotionIndex; % Index to identify motion
VelWorld    = SpheroState.VelWorld;    % Estimated speed
Omega       = SpheroState.Omega;       % Angular velocity 
Time        = SpheroState.Time;        % CPU time at each iteration
ThtEst      = SpheroState.ThtEst;      % Estimated heading
numRob      = SpheroState.numRob;      % Number of robots

Qkalm       = SpheroState.Param.Qkalm; % Covariance of process
Rkalm       = SpheroState.Param.Rkalm; % Covariance of measurement 
Pkalm       = SpheroState.Param.Pkalm; % Initial state covraiance


%%

for j = 1 : numRob % For each robot
    
if iitr == 1 % First iteration    
    stateKalm = [PosWorld(:,j,iitr); 0];
    dT = 0;    
else % Other iterations
    stateKalm = [PosKalm(:,j,iitr-1); ThtKalm(iitr-1,j)];  % State of the Kalman filter    
    dT = Time(iitr) - Time(iitr-1);                        % Ellapsed time
end

if (MotionIndex(iitr,j) && ~isnan(ThtEst(iitr,j)))
    yKalm = [PosWorld(:,j,iitr); ThtEst(iitr,j)];      % Measurments (full state)     
else
    yKalm = PosWorld(:,j,iitr);                        % Measurments (position only)
end

uKalm = [VelWorld(iitr,j); Omega(iitr,j)];             % Input (linar and angular velocity)

[stateKalm, Pkalm(:,:,j)] = EKF_Ver1_3(stateKalm,yKalm,uKalm, dT,Pkalm(:,:,j),Qkalm,Rkalm);     % EKF

PosKalm(:,j, iitr) = stateKalm(1:2);                   % Filtered position of robots
ThtKalm(iitr,j)    = wrapTo180( stateKalm(3) );        % Filtered headings

end

SpheroState.ThtKalm = ThtKalm;  % Estimated headings from Kalman filter
SpheroState.PosKalm = PosKalm;  % Position of robots from Kalman filter(in world frame)







































































































