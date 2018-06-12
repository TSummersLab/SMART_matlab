function [speed] = control_sphero(dist, groundspeed, Kp, Ki, Kd, stopRadius, maxspeed, minspeed, restartspeed, clearvars)
%CONTROL_SPHERO PID Controller for Sphero motion
% CONTROL_SPHERO(DIST, GROUNDSPEED, KP, KI, KD, STOPRADIUS, MAXSPEED, MINSPEED, RESTARTSPEED, CLEARVARS)
% Input Arguments:
%   DIST        : Distance of the current point of Sphero from the desired point
%   GROUNDSPEED : Current speed of the Sphero
%   KP          : Proportional controller gain
%   KI          : Integral controller gain
%   KD          : Derivative controller gain
%   STOPRADIUS  : Maximum desired distance from desired point within which the Sphero should try to stop 
%   MAXSPEED    : Maximum saturation speed for the Sphero
%   MINSPEED    : Minimum saturation speed for the Sphero
%   RESTARTSPEED: Minimum speed required to restart the Sphero, if it stops at a point where it is not supposed to. 
%                 This minumum speed is required to get the Sphero to start moving again, due to its inertia
%   CLEARVARS   : Clear the persistent variables in the function
%
% Output Arguments:
%   SPEED       : Speed to be provided to the Sphero
%
% Copyright 2015, The MathWorks, Inc.

%% Define persistent variables
persistent init prevu preve prevt prev2e prev2t

%% Clear variables if appropriate flag received
if clearvars
    clear init prevu preve prevt prev2e prev2t
    return
end

%% Initialize
if isempty(init)
    prevu = 0;
    preve = 0;
    prev2e = 0;
    prev2t = cputime;
    prevt = cputime;
    init = 1;
end

%% PID Control
t = cputime;
dt = t-prevt;
dt2 = prevt-prev2t;

if dist<stopRadius
    u=0;
else
    if dt<eps || dt2<eps
        u = prevu+Kp*(dist-preve)+Ki*dt*dist;
    else
        u = prevu+Kp*(dist-preve)+Ki*dt*dist + Kd*((dist-preve)/dt - (preve-prev2e)/dt2);
    end
    
    if groundspeed<2 && u<restartspeed
        u = restartspeed;
    end
        
end

prevu = u;
prev2e = preve;
preve = dist;
prev2t = prevt;
prevt = t;

%% Saturate
if u>maxspeed
    speed = maxspeed;
elseif u<minspeed
     speed = minspeed;
else
    speed = u;
end


end

