function [ctrl,ctrl1,ctrl2] = FormCtrl_FixedScale(pos, numRob)

persistent L Dd Adj

if isempty(L)  % First run
    %% Desired formation

    % N-gon formation
    qAng = linspace(0,360,numRob+1); % desired locations of agents on the unit circle given in angle
    qAng(end) = [];
    qf = [cosd(qAng); sind(qAng)]; % desired locations in x-y coordinates
    posDes = qf;

    % % Line formation
    % posDes = [(1 : numRob); zeros(1, numRob)];


    % % 6 agent triangle
    % posDes = [-1  0  1 -0.5  0.5  0;
    %            0  0  0  sqrt(3)/2  sqrt(3)/2  sqrt(3)];

    % % 6 agent rectangle
    % posDes = [0  1  2  0  1  2;
    %           0  0  0  1  1  1];


    %% Desired scale (distances are in mm)
    scale = 400;
    posDes = posDes .* scale;


    % Element (i,j) in matrix Dd describes the distance between agents i and j
    % in the formation. The diagonals are zero by definition.
    Dd = zeros(numRob,numRob); % inter-agent distances in desired formation
    for i = 1 : numRob
        for j = i+1 : numRob
            Dd(i,j) = norm(posDes(:,i) - posDes(:,j), 2);
        end
    end
    Dd = Dd + Dd'; % Inter-agent desired distance matrix



    %% Adjacancy matrix of all graphs with 4 agents

    numGraphs = 1;  % Number of sensing graphs to consider
    Adj = zeros(numRob,numRob,numGraphs);
    Adj(:,:,1) = ones(numRob) - eye(numRob); % Complete graph


    %% Rearrange tags (so that robots travel a shorter distance)

    % Retagging indices for the desired formation
    idx = RearrangeTags(posDes, numRob);

    % Retagging indices for the Spheros
    [~, idxLoc] = RearrangeTags(pos, numRob);

    % Rearranging posDes according to idx and idxLoc
    posDes = posDes( : , idx);
    posDes = posDes( : , idxLoc);


    %% Design control gains

    % Find simultaniously stabilizing gains for all adjacency matrices
    % cvx_startup; %% Commented out when moving to redistributable license
    [Ln, x, terms, Lbarn] = DynamicWeightDesign(Adj, posDes);

    LnR = L_C2R(Ln); % Real Laplacian matrix
    L = LnR ./ max(abs(LnR(:)));    % Normalized gain matrix


    %% Display the desired formation
    figure;
    hold on
    for j = 1 : numRob
        scatter3(posDes(1,j),posDes(2,j),0,100,'fill');
        text(posDes(1,j),posDes(2,j),0,['  ',num2str(j)], 'FontSize',16);
    end
    axis equal
    grid on
    title('Desired Formation')
    hold off
end

% Current distances
Dc = zeros(numRob,numRob); % inter-agent distances in current formation
for i = 1 : numRob
    for j = i+1 : numRob
        Dc(i,j) = norm(pos(:,i)-pos(:,j), 2);
    end
end
Dc = Dc + Dc';

sat = 30; % (in mm)

% Control to fix the scale
g = (1/numRob)*(1/pi); % Gain
% g = (1/3)*(1/pi); % Gain
F = g * atan( (1/sat)* Adj.*(Dc-Dd) );

F = F + diag(-sum(F,2));
F2 = L_C2R(F);

q = pos(:) ./ max(abs(pos(:))); % Aggregate position vector (normalized)
dq = L * q + F2 * q;            % Control velocity vectors
ctrl = reshape(dq,2,numRob);    % Reshape into matrix format






dq = L * q;
ctrl1 = reshape(dq,2,numRob);
dq = F2 * q;
ctrl2 = reshape(dq,2,numRob);
