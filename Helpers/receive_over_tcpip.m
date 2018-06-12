function [data] = receive_over_tcpip(link)
%RECEIVE_OVER_TCPIP receives data sent using send_over_tcpip.m
%   Detailed explanation goes here
num_dim = fread(link, 1, 'double'); % number of dimentions of data
shape_data = fread(link, 1, 'double');
for i = 2 : num_dim
    shape_data = [shape_data, fread(link, 1, 'double')]; % shape of data
end
total_size = 1;
for i = 1:length(shape_data)
    total_size = total_size * shape_data(i);
end
data_raw = fread(link, total_size, 'double');
data = reshape(data_raw, shape_data); %reshape data

end

