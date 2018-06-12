%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Heading and speed estimation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpheroState = SpheroHeadingSpeedEstim_Ver1_2(iitr, SpheroState)

kv              = SpheroState.Param.kv;
distPixelThresh = SpheroState.Param.distPixelThresh;
VelPixelThresh  = SpheroState.Param.VelPixelThresh;

numRob          = SpheroState.numRob;
Time            = SpheroState.Time;
VelWorld        = SpheroState.VelWorld;
VelPixel        = SpheroState.VelPixel;
VelPixelFilt    = SpheroState.VelPixelFilt;
VelWorldFilt    = SpheroState.VelWorldFilt;
PosWorld        = SpheroState.PosWorld;
PosPixel        = SpheroState.PosPixel;
ThtEst          = SpheroState.ThtEst;
MotionIndex     = SpheroState.MotionIndex;  

%%

if iitr == 1  % First iteration
    
% VelWorld(iitr,:) = zeros(1,numRob);
% VelPixel(iitr,:) = zeros(1,numRob);
    
else  % Other than first iterations

dT = Time(iitr) - Time(iitr-1); % Time interval

% Euclidean Coordinate velocity
dPosWorld = PosWorld(:,:,iitr) - PosWorld(:,:,iitr-1);
VelWorld(iitr,:) = sqrt(sum(dPosWorld.^2, 1)) ./ dT;

% Pixel velocity
dPosPixel = PosPixel(:,:,iitr) - PosPixel(:,:,iitr-1);
VelPixel(iitr,:) = sqrt(sum(dPosPixel.^2, 1)) ./ dT;


% Filtered velociy
dVelPixel = VelPixel(iitr,:) - VelPixelFilt(iitr-1,:); 
VelPixelFilt(iitr,:) = VelPixelFilt(iitr-1,:) + kv .* dVelPixel; 

dVelWorld = VelWorld(iitr,:) - VelWorldFilt(iitr-1,:); 
VelWorldFilt(iitr,:) = VelWorldFilt(iitr-1,:) + kv .* dVelWorld; 

% Heading estimation
for j = 1 : numRob  % For each robot
    for i = iitr-1 : -1 : 1  % Previous iterations
        dPosWorld = PosWorld(:,j,iitr) - PosWorld(:,j,i);
        dPosPixel = PosPixel(:,j,iitr) - PosPixel(:,j,i);
        distPixel = sqrt(sum(dPosPixel.^2, 1));
        if distPixel >= distPixelThresh % Heading estimation when there is large enough motion
            ThtEst(iitr,j) = atan2d(dPosWorld(2), dPosWorld(1));  % Heading angle estimate          
            break;
        end
    end
end

% Motion detection
MotionIndex(iitr, :) = VelPixelFilt(iitr,:) >= VelPixelThresh; % Robots with large enough motion


SpheroState.VelWorld      =  VelWorld;
SpheroState.VelPixel      =  VelPixel;
SpheroState.VelPixelFilt  =  VelPixelFilt;
SpheroState.VelWorldFilt  =  VelWorldFilt;
SpheroState.MotionIndex   =  MotionIndex;
SpheroState.ThtEst        =  ThtEst;

end







































































