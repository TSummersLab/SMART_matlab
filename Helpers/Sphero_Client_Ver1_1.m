function [rob_pos, gains, Adj, Dd bboxesOrder, InitFrames, is_mine] = Sphero_Client(ip_server, Sph, CameraParam, numRobLocal)
%UNTITLED Client funciton that communicates with the server only
%   server_ip: ip address of the server

% Setup client read and write
client = tcpip(ip_server(1), 'NetworkRole', 'Client');
set(client, 'InputBufferSize', 8); %initial buffer size until buffer size is obtianed
set(client, 'Timeout', 60);

% Connect to server to find buffer size
fopen(client);
buff_size = receive_over_tcpip(client);
client_id = receive_over_tcpip(client);
num_clients = receive_over_tcpip(client);
numRob = receive_over_tcpip(client);
fclose(client)

is_mine = zeros(1, numRob); % array that indicates is a robot in rob_pos belongs to this client

% Set input buffer size and reconnect to server
set(client, 'InputBufferSize', buff_size)
set(client, 'OutputBufferSize', buff_size)
flushinput(client);
flushoutput(client);
fopen(client)

% Receive gains and position of server robots
gains = receive_over_tcpip(client)
Adj = receive_over_tcpip(client)
Dd = receive_over_tcpip(client)
rob_pos = receive_over_tcpip(client)

% Receive tagged robot positions
for i = 1:num_clients
    if i == client_id
        cam = CameraParam.cam;
        col = CameraParam.col;
        [posPixOrder, bboxesOrder, InitFrames] = ...
            Detect_Sphero_Initial_Ver2_5(cam, Sph, numRobLocal, col);   % Detect Sphero locations in the order of sph vector
        [posWorldOrder] = reconstruction(CameraParam, posPixOrder, numRobLocal); % Reconstruct the world position
        for k = 1:numRobLocal
            Sph{k}.Color = [0,0,0];
        end
        send_over_tcpip(client, posWorldOrder);
        is_mine(size(rob_pos,2)+1:size(rob_pos,2)+size(posWorldOrder,2)) = 1;
    end
    rob_pos = [rob_pos, receive_over_tcpip(client)];
end

% End connection with server
fclose(client);

end

