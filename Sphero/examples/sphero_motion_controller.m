function sphero_motion_controller(sph, despoints)


%% Specify the points to be traversed
% Specification of the x and y coordinates of the points to be traversed on
% the plane (in cm):

numpoints = size(despoints, 1);

%Read the current location of the Sphero
[xstart, ystart, ~, ~, groundspeed] = readLocator(sph);

% Plot the points to be traversed
labels = cellstr(num2str([1:numpoints]') );  % labels correspond to the order in which the points are to be traversed
figure(1)
clf
plot(despoints(:, 1), despoints(:,2), 'b+')
text(despoints(:,1), despoints(:,2), labels, 'VerticalAlignment','bottom', ...
                             'HorizontalAlignment','right')
title('Points to be traversed');
axis([min(despoints(:, 1))-20 max(despoints(:, 1))+20 min(despoints(:, 2))-20 max(despoints(:, 2))+20])
hold on
plot(double(xstart), double(ystart), 'ko');
hold off

%%
% Specify the other parameters that are used in controlling the Sphero:

tfinal = 30; % Time limit on the motion of the Sphero
stopRadius = 3;  % Radius of the circle around the point, within which the Sphero should try to stop 
maxspeed = 150; % Max speed for saturation 
minspeed = -150;  % Min speed for saturation
restartspeed = 50; % Minimum speed required to restart the Sphero, if it 
% stops at a point where it is not supposed to stop. This minumum speed is
% required to get the Sphero to start moving again, due to its inertia

% Controller gains
Kp = 3; 
Ki = 0.2; 
Kd = 0.2;

% Initialize the variables to store the x, y coordinates of the points that
% the Sphero actually goes through, and the distance from the desired point 
xlog = []; 
ylog = []; 
distlog = [];

%% Closed loop control of Sphero to traverse specified points
% Initialize the variables for traversing the points:
idx = 1;
xcur = double(xstart);
ycur = double(ystart);
t0 = cputime;

%%
% Run the while loop until the timout occurs, or when all points have been
% traversed. The *control_sphero* function implements the PID
% Controller, which outputs the desired speed of the robot, based on the
% distance between the current point and the next point that has to be
% reached.

while(cputime-t0<tfinal) && idx<=numpoints
    xdes = despoints(idx, 1);
    ydes = despoints(idx, 2);
    
    % Angle and distance calculation
    % Angle by which the Sphero should be rotated and the distance that it 
    % should move by in order to reach desired position. 
    % The angle is measured with respect to the Sphero's y-axis 
    % (or orientation of sphero)
    angle = rad2deg(atan2(double(xdes-xcur), double(ydes-ycur)));
    dist = sqrt((xdes-double(xcur)).^2 + (ydes-double(ycur)).^2); %Distance or the error   
       
    %Clear the persistent variables in the function, from the previous run.
    %If these variables are not cleared, the error values from the previous
    %run will be used, which can cause issues
    control_sphero(dist, double(groundspeed), Kp, Ki, Kd, stopRadius, maxspeed, minspeed, restartspeed, 1);
    
    while dist>stopRadius
        speed = control_sphero(dist, double(groundspeed), Kp, Ki, Kd, stopRadius, maxspeed, minspeed, restartspeed, 0);

        % Move the robot in the desired direction (specified by the 'angle'
        % with regards to the y-orientation of the sphero)
        result = roll(sph, speed, angle);

        % Read the current position and speed of the robot
        [xcur, ycur,~, ~, groundspeed] = readLocator(sph);
        
        % Angle and distance calculation
        angle = rad2deg(atan2(double(xdes-xcur), double(ydes-ycur)));
        dist = sqrt((xdes-double(xcur)).^2 + (ydes-double(ycur)).^2); %Distance or the error

        xlog(end+1) = xcur;
        ylog(end+1) = ycur;
        distlog(end+1) = dist;
    end
    %Increment the index to the next point that has to be traversed
    idx = idx+1;
end

brake(sph);

%% Plot the result
hold on
plot(xlog, ylog, 'rx');
hold off
legend('Desired points for traversal', 'Starting location', 'Motion of Sphero')

%Clear the persistent variables in the control function
control_sphero(dist, groundspeed, Kp, Ki, Kd, stopRadius, maxspeed, minspeed, restartspeed, 1);

end