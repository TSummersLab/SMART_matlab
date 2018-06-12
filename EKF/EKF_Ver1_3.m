% EKF   Extended Kalman Filter for nonlinear dynamic systems
%
% [q, P] = ekf(q,y,u,P,Q,R) returns state estimate q and state covariance P 
% for nonlinear dynamic system 
% 
%           q_k+1 = f(q_k, u_k, w_k)
%           y_k+1 = h(q_k, v_k)
%
% linearized as:
%
%           q_k+1 = F q_k + L w_k
%           y_k   = H q_k + M v_k
%
% where w ~ N(0,Q) meaning w is gaussian noise with covariance Q
%       v ~ N(0,R) meaning v is gaussian noise with covariance R
%
% Inputs:   
%           q:  "a priori" state estimate
%           y:  Current measurement
%           u:  Input
%           dT: Time step
%           P:  "a priori" estimated state covariance
%           Q:  Process noise covariance 
%           R:  Measurement noise covariance
%
% Output:   
%           q: "a posteriori" state estimate
%           P: "a posteriori" state covariance
%
%

% Ve1.3:
%       - includes additional case of no output
%
% Ve1.2:
%       - include cases of position output, or position+heading output
%
function [qp,Pp] = EKF_Ver1_3(q,y,u, dT,P,Q,R)


% The state vector q is
%               q = [ x1   x2   o]^T
% where o is the heading of the robot, and x1,x2 are position on the plane.
%
x1 = q(1);  % x-coordinate
x2 = q(2);  % y-coordinate
o  = q(3);  % Heading angle in degrees

% Input vector is
%               u = [vel  omeg]^T  
% where vel is the linear velocity and omeg is the angular velocity 
%
vel  = u(1);  % Linear velocity input
omeg = u(2);  % Angular velocity input

% Linearized state matrix ( F := df / dq)
F = [1  0  -vel*sind(o)*dT;
     0  1   vel*cosd(o)*dT;
     0  0                1];
 
% Identity matrix
I = eye(size(P));

% The measurement vector x is
%        x = [ x_vis   y_vis   theta_vis ]^T
% or
%        x = [ x_vis   y_vis ]^T
% when there is no reliable theta measurement. 
if length(y) == 3
    H = eye(3);   % Linearized measurement matrix (H := dh / dq) 
    M = eye(3);   % Linearized measurement noise matrix (M := dh / dv)
else
    H = [eye(2), [0;0]];
    R = R(1:2, 1:2);
    M = eye(2);    
end

% Linearized process noise matrix (L := df / dv)
L = eye(3);         

% Time update of state estime
x1m = x1 + dT * vel * cosd(o);
x2m = x2 + dT * vel * sind(o);
om = o + dT * omeg;
qm = [x1m; x2m; om]; % state
ym = H * qm;         % output

% Time update of estimation-error covariance matrix
Pm = F * P * F.' + L * Q * L.';

% Measurement update of the state estimate and estimation error covariance
if ~any(isnan(y))
    K = (Pm * H.') / (H * Pm * H.' + M * R *M.');
    qp = qm + K * (y - ym);
    Pp = (I - K * H) * Pm;
else
    qp = qm;
    Pp = Pm;
end

return























































