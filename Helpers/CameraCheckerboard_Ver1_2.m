
function CameraParam = CameraCheckerboard_Ver1_2(CameraParam)
%% Initialize camera

if isfield(CameraParam,'cam')
    delete(CameraParam.cam)
    CameraParam = rmfield(CameraParam,'cam');
%     imaqreset
%     clear cam
end


deviceId = CameraParam.camID; % Webcam device ID
cam = webcam(deviceId); % Connect to the webcam.

% Set camera properties
cam.Resolution = '640x480';
cam.Focus = 0;  
cam.Exposure = -11;

% Grab a frame
frame = snapshot(cam);
figure; imshow(frame);

% % % format = 'YCbCr422_1920x1080'; % 'RGB24_1280x720'   'RGB24_1920x1080'    'RGB24_1280x720'    'RGB24_864x480'   'RGB24_640x480'

% Load camera parameters
load(CameraParam.paramFile); % Must contain 'cameraParams', which is returned from the camera calibration toolbox

CameraParam.cam = cam;
CameraParam.Calib = (cameraParams.IntrinsicMatrix).'; % Camera clibration matrix
CameraParam.cameraParams = cameraParams;

pause(0.2);

%% 3D reconstruction

squareSize = CameraParam.squareSize; % Checkerboard square size in mm

webcamIm = snapshot(cam);
webcamIm = imresize(webcamIm, [480,640]);
figure;
imshow(webcamIm);

% Get the normal of the plane w.r.t the camera using the checkerboard
% R,T: rotation and translation that map a point from the world frame
% (on the checkerboard) to the camera frame.
% N: normal of the checkerboard plane in the camera frame

[imagePoints, boardSize] = detectCheckerboardPoints(webcamIm);
squareSize = 23;
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
[R, T] = extrinsics(imagePoints, worldPoints, cameraParams);
N = R.' * [0; 0; 1]; % Normal to the plane in the camera frame
pos_zero = worldToImage(cameraParams, R, T, [0 0 0]);

hold on; plot(pos_zero(1), pos_zero(2), 'xr'); hold off
T = T.';
R = R.';

CameraParam.Rot  = R;
CameraParam.Tran = T;
CameraParam.Norm = N;


