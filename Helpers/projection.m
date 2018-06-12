function [posPixAll] = projection(CameraParam, posWorldAll)%change fucntion name

Calib     = CameraParam.Calib;              % Camera calibration parameters
Rot       = CameraParam.Rot;                % Rotation from camera to world frame
Tran      = CameraParam.Tran;               % Translation from camera to world frame

% change this to map back world pos to image pos
% imPts = [posPixAll; ones(1,numRob)];
% p     = Calib \ imPts;                         % Homogenious point coordinates on the image
% Nc    = Rot * [0; 0; 1];                       % Normal of the plane (given in the camara coordinate frame)
% d     = Nc.' * Tran;                           % Distance from camera to the plane
% Nxp   = Nc.' * p;
% P     = bsxfun(@rdivide, d*p, Nxp);            % Point coordinates (in camera coordinate frame)
% Pw    = bsxfun(@plus, Rot.'*P, -Rot.'*Tran);   % Point coordinates (in world coordinate frame)
% posWorldAll      =  Pw(1:2,:);
% posWorldAll(1,:) = -posWorldAll(1,:);      % Orient the world frame s.t. z-axis is pointing up

posWorldAll(1,:) = -posWorldAll(1,:);
posWorldAll = [posWorldAll; zeros(1,size(posWorldAll,2))];
P = bsxfun(@plus, Rot*posWorldAll, Tran);   % Point coordinates (in world coordinate frame)
p = bsxfun(@rdivide, P, P(3,:));            % P/z (projected) 
imgPts = Calib * p;                         % Get pixles
posPixAll = round(imgPts(1:2,:));           % get rid of last column