function [posWorldAll] = reconstruction(CameraParam, posPixAll, numRob)

Calib     = CameraParam.Calib;              % Camera calibration parameters
Rot       = CameraParam.Rot;                % Rotation from camera to world frame
Tran      = CameraParam.Tran;               % Translation from camera to world frame

imPts = [posPixAll; ones(1,size(posPixAll,2))];
p     = Calib \ imPts;                         % Homogenious point coordinates on the image
Nc    = Rot * [0; 0; 1];                       % Normal of the plane (given in the camara coordinate frame)
d     = Nc.' * Tran;                           % Distance from camera to the plane
Nxp   = Nc.' * p;
P     = bsxfun(@rdivide, d*p, Nxp);            % Point coordinates (in camera coordinate frame)
Pw    = bsxfun(@plus, Rot.'*P, -Rot.'*Tran);   % Point coordinates (in world coordinate frame)
posWorldAll      =  Pw(1:2,:);
posWorldAll(1,:) = -posWorldAll(1,:);      % Orient the world frame s.t. z-axis is pointing up
