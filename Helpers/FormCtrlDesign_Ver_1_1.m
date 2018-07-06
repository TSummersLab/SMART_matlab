function SpheroState = FormCtrlDesign_Ver_1_1(SpheroState)

numRob      = SpheroState.numRob;       % Number of robots

%% Parameters

% Size of desired formation
scale = 500; % in mm

% Desired formation coordinates
% qDes = [0    1     0.5      ;
%         0    0     sqrt(3)/2] * scale;
% qDes = [0    -2    -2    -4        -4
%         0    -1     1    -2         2]*scale;
% qDes = [0    -2    -2    -4    -4    -4
%         0    -1     1    -2     0     2]*scale;
qDes = [-1    0    1    -1    0    1     -1     0    1;
         1    1    1     0    0    0     -1    -1   -1]*scale;  % Square grid
% qDes = [0    0.5   -0.5   -1    -2    -1    0    0    1    1    2
%         3    2      2      1     0     0    1    0    1    0    0]*scale;
% qDes = [0    0.5   -0.5   -1    -2    -1       1    1    2
%         3    2      2      1     0     0       1    0    0]*scale;


% % Graph adjacency matrix (must be symmetric)
%     Adj = [ 0     1     1     0     0     0
%             1     0     1     1     1     0
%             1     1     0     0     1     1
%             0     1     0     0     1     0
%             0     1     1     1     0     1
%             0     0     1     0     1     0];
% Graph adjacency matrix (must be symmetric)
Adj = [ 0     1     0     1     0     0     0     0     0
        1     0     1     0     1     0     0     0     0
        0     1     0     0     0     1     0     0     0
        1     0     0     0     1     0     1     0     0
        0     1     0     1     0     1     0     1     0
        0     0     1     0     1     0     0     0     1
        0     0     0     1     0     0     0     1     0
        0     0     0     0     1     0     1     0     1
        0     0     0     0     0     1     0     1     0 ];

Adj(:,:,1) = ones(numRob) - eye(numRob); % Complete graph



%%

% Desired inter-agent distances
% Element (i,j) in matrix Dd describes the distance between agents i and j
% in the formation. The diagonals are zero by definition.
Dd = zeros(numRob,numRob); % inter-agent distances in desired formation
for i = 1 : numRob
    for j = i+1 : numRob
        Dd(i,j) = norm(qDes(:,i) - qDes(:,j), 2);
    end
end
Dd = Dd + Dd'; % Inter-agent desired distance matrix


% Find stabilizing formation control gains
% cvx_startup; %% Commented out when moving to redistributable license
A = FindGains(qDes(:) + 1e-15*rand(18,1) , Adj);


% Normalize A to have max element 1
A = A ./ max(abs(A(:)));



%%

SpheroState.posDes  = qDes;            % Desired Formation
SpheroState.Adj     = Adj;             % Graph adjacency matrix
SpheroState.A       = A;               % Formation control gains
SpheroState.Dd      = Dd;              % Desired inter-agent distances


















end
