function [rob_pos, bboxesOrder, InitFrames, is_mine] = Sphero_Server(ip_clients, gains, Adj, Dd, numRob, Sph, CameraParam, numRobLocal)
%SPHERO_SERVER Server function that communicates with all other computers
%   Detailed explanation goes here
% [num_rob, ~] = size(gains);
s = whos('gains');
num_clients = length(ip_clients);
is_mine = zeros(1, numRob);

% Setup all servers for read and write
servers = {};
for i = 1:num_clients
    servers{i} = tcpip(ip_clients(i), 'NetworkRole', 'Server'); % create array of all servers
    set(servers{i}, 'OutputBufferSize', s.bytes); % set output buffer size for sending data to clients
    set(servers{i}, 'InputBufferSize', s.bytes); % set input buffer size for receiving data from clients
    set(servers{i},'Timeout', 60); % timeout duration (large to not miss anything)
    flushinput(servers{i});
    flushoutput(servers{i});
end

% Connect to all clients and send them the input buffer size, their ID, and
% the number of clients
disp('Start other computers now');
for i = 1:num_clients
    fopen(servers{i});
end
for i = 1:num_clients
    send_over_tcpip(servers{i}, s.bytes);
    send_over_tcpip(servers{i}, i);
    send_over_tcpip(servers{i}, num_clients);
    send_over_tcpip(servers{i}, numRob);
end
for i = 1:num_clients
    fclose(servers{i});
end

% Reconnect to all clients 
for i = 1:num_clients
    fopen(servers{i});
end

% Send gains, adjacency matrix, and desired distance to all clients
for i = 1:num_clients
    send_over_tcpip(servers{i}, gains);
    send_over_tcpip(servers{i}, Adj);
    send_over_tcpip(servers{i}, Dd);
end

% Unify robot tags by sharing robot positions
cam = CameraParam.cam;
col = CameraParam.col;
[posPixOrder, bboxesOrder, InitFrames] = ...
    Detect_Sphero_Initial_Ver2_5(cam, Sph, numRobLocal, col);   % Detect Sphero locations in the order of sph vector
for i = 1:numRobLocal
    Sph{i}.Color = [0,0,0];
end

is_mine(1:size(posPixOrder,2)) = 1;
[pos_server_robots] = reconstruction(CameraParam, posPixOrder, numRobLocal); % Reconstruct the world position

for i = 1:num_clients
    send_over_tcpip(servers{i}, pos_server_robots);
end

rob_pos = pos_server_robots;

for i = 1:num_clients
    pos_robs_client = receive_over_tcpip(servers{i});
    for j = 1:num_clients
        send_over_tcpip(servers{j},pos_robs_client);
    end
    rob_pos = [rob_pos, pos_robs_client]; % append the newly obtained positions
end

% End connection with all clients 
for i = 1:num_clients
    fclose(servers{i});
end

end
