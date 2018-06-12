function Theta0 = SpheroTheta0_Ver1_5(SpheroStateOrig, CameraParam)


numRobLocal = SpheroStateOrig.numRobLocal;
SphOrig     = SpheroStateOrig.Sph;      % Spheros
blk         = [   0,    0,    0 ];      % Black == off
col         = CameraParam.col;          % Detection color
Theta0      = zeros(1, numRobLocal);    % theta0 for each robot

for j =  1 : numRobLocal    

SpheroState        = SpheroStateOrig;    % A copy of the original SpheroState
Sph                = SphOrig(j);         % Desired Sphero
SpheroState.Sph    = Sph;
SpheroState.numRob = 1;                  % Number of robots set to 1

numItr             = 100;                % Maximum number of iterations
SpheroState.numItr = numItr;          
distPix            = 50;                 % Desired distance to be travelled in pixels
vel                = 40;                 % Moving forward speed
ang                = 0;                  % Moving forward angle

for jj = setdiff(1:numRobLocal, j)  % Turn off light of other robots  
    SphOrig{jj}.Color = blk;
end
Sph{1}.Color = col;            % Keep light on for desired robot

% Reset headings to zero
roll(Sph{1},0,0);       

fprintf('Press a key to estimate theta0 for %s.\n', SphOrig{j}.DeviceName);
pause();

SpheroState = SpheroLoadParam_Ver1_4(SpheroState);  % Load parameters

disp('Moving forward...'); 
for itr = 1 : numItr
    
    % 3D reconstruction  
%     disp('Image detection & tracking');
    SpheroState = SpheroDetectionTracking_Ver1_4(itr, SpheroState, CameraParam);
    
    % Heading and speed estimation
%     disp('Heading estimation');
    SpheroState.Time(itr)  =  cputime;
    SpheroState = SpheroHeadingSpeedEstim_Ver1_2(itr, SpheroState);
    
    % Move Sphero forward      
    roll(Sph{1},vel,ang);    
    
    % Stop Sphero once desired distance is travelled
    if norm(SpheroState.PosPixel(:,:,itr) - SpheroState.PosPixel(:,:,1)) >= distPix        
        roll(Sph{1},0,ang);
%         pause(0.5);
        
        % Find theta0
        ThtEst  = SpheroState.ThtEst;
        theta0  = nanmean(ThtEst - ang)
        
        % Theta0 estimated from the initial and end locations
        posDiff = SpheroState.PosWorld(:,:,itr) - SpheroState.PosWorld(:,:,1);
        theta0  =atan2d(posDiff(2), posDiff(1))
        
        fprintf('\n\ntheta0 = %3.2f estimated.\n\n', theta0)
        break;
    end
        
    
end

Theta0(j) = theta0;


end


%%

% Turn all LEDs on
for j = 1 : numRobLocal    
    SphOrig{j}.Color = col; 
end
pause(1);
    
    
    
    



















































































































