function SpheroState = SpheroConnect_Ver1_3(CameraParam, SpheroState)


SphNames    = SpheroState.SphNames;
col         = CameraParam.col;         % Color used for detection
numRobLocal = length(SphNames);        % Number of robots in each computer

bklight  = 0;          % Back LED
MotionTO = 0.2;        % Motion timeout
hdshk    = 1;          % Bluetooth handshake
resTO    = 100;        % Response timeout


Sph = {};

for j = 1 : numRobLocal
    
    varName  = strcat('Sphero-', SphNames{j});
    fprintf('Connecting to %s ...\n', varName);
    
    sph = sphero(varName);
    sph.InactivityTimeout = 60000;
    sph.Color = col;
    sph.BackLEDBrightness = bklight;
    sph.MotionTimeout = MotionTO;
    sph.Handshake = hdshk;  
    sph.ResponseTimeout = resTO;
    
    connect(sph);
    
    Sph{j} = sph;
    
    fprintf('Connected.\n\n');
    pause(0.5);
    
end


SpheroState.Sph     = Sph;     % Spheros
SpheroState.numRobLocal  = numRobLocal;  % Number of robots























































































