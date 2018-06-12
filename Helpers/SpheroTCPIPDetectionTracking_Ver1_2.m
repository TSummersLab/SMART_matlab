% Ver 2_1:
%       - Makes reconstruction a function
%       - Integrates the initial detection with Sphero_Server and
%       Sphero_Client
%       - Changes tracking to use the world coordinates
%
%
%%%%%%%%%%%%%%%%%%%%%
% 3D reconstruction %
%%%%%%%%%%%%%%%%%%%%% 
function SpheroState = SpheroTCPIPDetectionTracking_Ver1_2(iitr, SpheroState, CameraParam, SpheroTCPIP)

col       = CameraParam.col;                % Detection color
cam       = CameraParam.cam;                % Camera object
Calib     = CameraParam.Calib;              % Camera calibration parameters
Rot       = CameraParam.Rot;                % Rotation from camera to world frame
Tran      = CameraParam.Tran;               % Translation from camera to world frame
% Norm    = CameraParam.Norm;              % Normal to checkerboard

numRob    = SpheroState.numRob;             % Number of robots


Sph       = SpheroState.Sph;                % Sphero objects
PosWorld  = SpheroState.PosWorld;           % Positions in world coordinate frame
PosPixel  = SpheroState.PosPixel;           % Positions in pixel
Bboxes    = SpheroState.Bboxes;             % Bounding boxes
       

if iitr == 1 % In the first iteration  

    if SpheroTCPIP.server == 1
        [posWorldOrder, bboxesOrder, InitFrames, SpheroState.SphFlag] = ...
            Sphero_Server_Ver1_2(SpheroTCPIP.ip, SpheroState.A, SpheroState.Adj, SpheroState.Dd, numRob, Sph, CameraParam, SpheroState.numRobLocal)
    else
        [posWorldOrder, SpheroTCPIP.gains, SpheroState.Adj, SpheroState.Dd, bboxesOrder, InitFrames, SpheroState.SphFlag] = ...
            Sphero_Client_Ver1_2(SpheroTCPIP.ip, Sph, numRob, CameraParam, SpheroState.numRobLocal)
        SpheroState.A = SpheroTCPIP.gains;
    end
    
    % turn on all Spheros once all computers are done tagging
    for j = 1 : SpheroState.numRobLocal
    
    SpheroState.Sph{j}.Color = CameraParam.col;
    pause(0.5);
    
    end

%     
% [posPixOrder, bboxesOrder, InitFrames] = ...
%     Detect_Sphero_Initial_Ver2_5(cam, Sph, numRob, col);   % Detect Sphero locations in the order of sph vector
% [posWorldOrder] = reconstruction(SpheroState, CameraParam, posPixOrder); % Reconstruct the world position

posPixOrder = projection(CameraParam, posWorldOrder);
% detectionFlag = true
SpheroState.Video.InitFrames  = InitFrames;
% SpheroState.PosPixelAll{iitr} = posPixOrder;
SpheroState.BboxesAll{iitr}   = bboxesOrder;
PosWorld(:,:,iitr) =  posWorldOrder;           % Robot positions in 3D (world coord frame)   

else % Other iterations  
    
[posPixAll, bboxes, frame] = Detect_Sphero_Ver2_5(cam, numRob, col); % Detect Spheros   
[posWorldAll] = reconstruction(CameraParam, posPixAll, numRob); % Reconstruct the world position

SpheroState.PosPixelAll{iitr} = posPixAll;
SpheroState.BboxesAll{iitr}   = bboxes;

SpheroState.Video.Frames{iitr} = frame;

if size(posPixAll,2) >= numRob    
    detectionFlag = true;
%     posOld = PosPixel(:,:,iitr-1);
%     posNew = posPixAll;
    posWorldOld = PosWorld(:,:,iitr-1);
    posWorldNew = posWorldAll;
    [posWorldOrder, idx] = track_Sphero_Ver2_1(posWorldOld, posWorldNew); % Track Spheros  
    posPixOrder = projection(CameraParam, posWorldOrder);
%     [posPixOrder, idx] = track_Sphero_Ver2_1(posOld, posNew); % Track Spheros  
    
    PosPixel(:,:,iitr) = posPixOrder;         % Robot positions on the image (in pixels)

%     bboxesOrder        = bboxes(:,idx); % wrong valued
    PosWorld(:,:,iitr) =  posWorldOrder;           % Robot positions in 3D (world coord frame)    
    % we need to do something about the pixel position of the robots
else
    detectionFlag = false;
    PosWorld(:,:,iitr) = NaN(2,numRob);
    PosPixel(:,:,iitr) = NaN(2,numRob);
    Bboxes(:,:,iitr)   = NaN(4,numRob);
end

end

% if detectionFlag
%     
% % PosPixel(:,:,iitr) = posPixOrder;         % Robot positions on the image (in pixels)
% % Bboxes(:,:,iitr)   = bboxesOrder;         % Bounding boxes
% 
% % x-y position of robots in the world coordinate frame (defined via the checkerboard)
% 
% % imPts = [posPixOrder; ones(1,numRob)];
% % p     = Calib \ imPts;                         % Homogenious point coordinates on the image
% % Nc    = Rot * [0; 0; 1];                       % Normal of the plane (given in the camara coordinate frame)
% % d     = Nc.' * Tran;                           % Distance from camera to the plane
% % Nxp   = Nc.' * p;
% % P     = bsxfun(@rdivide, d*p, Nxp);            % Point coordinates (in camera coordinate frame)
% % Pw    = bsxfun(@plus, Rot.'*P, -Rot.'*Tran);   % Point coordinates (in world coordinate frame)
% % posWorldOrder      =  Pw(1:2,:);
% % posWorldOrder(1,:) = -posWorldOrder(1,:);      % Orient the world frame s.t. z-axis is pointing up
% 
% % PosWorld(:,:,iitr) =  posWorldOrder;           % Robot positions in 3D (world coord frame)    
% 
% end
%%

SpheroState.PosWorld = PosWorld;
SpheroState.PosPixel = PosPixel;
SpheroState.Bboxes   = Bboxes;











































































































