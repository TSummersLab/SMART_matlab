function [] = send_over_tcpip(link, data)
%SEND_OVER_TCPIP Sends data over TCP/IP
%   Detailed explanation goes here
num_data_dim = length(size(data)); % number of dimention of data to be sent
dims_data = size(data); % shape of data

% send num_data_dim to receiver
fwrite(link, num_data_dim, 'double');

% send shape of data
fwrite(link, dims_data, 'double');

% send data
fwrite(link, data(:), 'double')

end

