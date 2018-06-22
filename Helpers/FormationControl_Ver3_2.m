%%%%%%%%%%%%%%%%%%%
% Sphero  control %
%%%%%%%%%%%%%%%%%%%  
%
% Ver 3_2:
%           - Formation control with collision avoidance
%           - Decouples Sphero control and formation control 
%
%
%
function SpheroState = FormationControl_Ver3_2(iitr,itr,j, SpheroState, CameraParam)


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

vMax        = SpheroState.Param.vMax;   % Maximum allowed velocity of Sphero
dcoll       = SpheroState.Param.dcoll;  % Threshold to activate collision avoidance
hcone       = SpheroState.Param.hcone;  % Base length of the collision cone 

% Calib       = CameraParam.Calib;            % Interinsics of camera
% R           = CameraParam.Rot;              % Rotation matrix of camera
% T           = CameraParam.Tran;             % Translation vector of camera
% PosPixel    = SpheroState.PosPixel;         % Pixel position of Spheros
% PosPixelAll = SpheroState.PosPixelAll;      % Pixel postion of all detected objects

Ctrl        = SpheroState.Ctrl;             % Control vectors
numRob      = SpheroState.numRob;           % Total number of robots
numRobLocal = SpheroState.numRobLocal;      % Number of robots in each computer
SphFlag     = SpheroState.SphFlag;          % Indicates what robots in SheroState.PosPixAll belong to this machine
A           = SpheroState.A;                % Formation control gains
Adj         = SpheroState.Adj;              % Graph adjacency matrix
Dd          = SpheroState.Dd;               % Desired inter-agent distances


%% Index of robots being controlled

SphIdx = find(SphFlag);
jj = SphIdx(j);

% Normalize A to have max element 1 for associated robots
A = A ./ max(max(abs(A(SphIdx, SphIdx))));


%% Formation Control (up to a scale factor)

posWorld = PosWorld(:,:,iitr);            % Coordinate of all robots
posWorldLocal = posWorld(:,SphIdx);       % Coordinate of associated robots
q = posWorld(:) ./ max(abs(posWorldLocal(:))); % Aggregate position vector (normalized)    
dq = (A * q) .* vMax;                     % Control velocity vectors

% % Normalize the control vector
% dqNrm = sqrt(sum(dq.^2, 1));
% if any(dqNrm > vMax)
%     dq = dq ./ max(dqNrm) .* vMax;
% end

% Reshape into matrix format
ctrl = reshape(dq,2,numRob);

% Current inter-agent distances
Dc = zeros(numRob,numRob); % inter-agent distances in current formation
for i = 1 : numRob
    for k = i+1 : numRob
        Dc(i,k) = norm(posWorld(:,i)-posWorld(:,k), 2);
    end
end
Dc = Dc + Dc';

%% Collision avoidance

% Index of neighbors inside collision radius
colIdx = Dc < dcoll;
colIdx = colIdx - diag(ones(1,numRob));

% Stop flag to avoid collision
stopFlag = false(numRob,1);

for i = 1 : numRob % Agent
        
    coneAng = []; % Angle of cone sides are stored in columns of 'coneAng'

    % Find cone angles
    for k = 1 : numRob % Neighbors
        if colIdx(i,k)  % If collision avoidance is needed
            
            dnb =  Dc(i,k);                       % Distance to neighbor
            vec = posWorld(:,k) - posWorld(:,i);  % Vector from agent to its neighbor
            tht = atan2d(vec(2), vec(1));         % Angle of connecting vector             
            alp = abs( atand((hcone/2)/dnb) );        % Vertex half-angle of the cone
            
            % Angle of cone sides
            thtm = tht - alp;
            thtp = tht + alp;
            
            % Bring all angles to the range [-180, 180] degrees
            if thtm < -180
                coneAng = [coneAng; [wrapTo180(thtm), 180] ];
                coneAng = [coneAng; [-180, thtp] ];
            elseif thtp > 180
                coneAng = [coneAng; [-180, wrapTo180(thtp)] ];
                coneAng = [coneAng; [thtm, 180] ];
            else
                coneAng = [coneAng; [thtm, thtp] ];
            end

        end
    end
    
    if any(colIdx(i,:))  % If collision avoidance is needed
        
        % Control vector angle in world coordinate frame
        thtC = atan2d(ctrl(2,i), ctrl(1,i));  
        
        % If control vector is inside a cone change its direction 
        if any( and((thtC >= coneAng(:,1)), (thtC <= coneAng(:,2))) ) 
            
            angs = [-180 : 5 : 180];    % Possible motion directions to test  
            angsIdx = true(size(angs)); % Index of angles outside of the collision cones
            
            % Determine which angles are inside the collision cones
            for k = 1 : length(angs)
                r = angs(k);
                if any( and((r > coneAng(:,1)), (r < coneAng(:,2))) )
                    angsIdx(k) = false;
                end
            end
            
            angsFeas = angs(angsIdx);  % Feasible directions to take
            
            % If there is no feasible angle stop
            if isempty(angsFeas) 
                stopFlag(i) = true;
            end
            
            % Find closest non-colliding control direction
            thtDiff = abs( wrapTo180(thtC - angsFeas) );
            [~,minIdx] = min(thtDiff);
            thtCnew = angsFeas(minIdx);
            
            % Check if the feasible control direction is within +-90 degrees,
            % otherwise stop
            if abs( wrapTo180(thtCnew - thtC) ) >= 90 
                stopFlag(i) = true;
            end
            
            % Modified control vector
            if stopFlag(i)
                ctrl(:,i) = zeros(2,1);
            else
                ctrl(:,i) = norm(ctrl(:,i)) * [cosd(thtCnew); sind(thtCnew)]; 
            end
            
        end
    end
    
end



%% Save output

Ctrl(:,:,iitr) = ctrl;

SpheroState.Ctrl        = Ctrl;         % Control vectors


















































































































