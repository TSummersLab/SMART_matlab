function ctrl = FormCtrl_FreeScale(pos, numRob)

persistent L

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
%     posDes = [-1  0  1 -0.5  0.5  0;
%                0  0  0  sqrt(3)/2  sqrt(3)/2  sqrt(3)];

    % % 6 agent rectangle
    % posDes = [0  1  2  0  1  2;
    %           0  0  0  1  1  1];

    %% Adjacancy matrix of all graphs with 4 agents

    numGraphs = 1;  % Number of sensing graphs to consider
    Adj = zeros(numRob,numRob,numGraphs);
    Adj(:,:,1) = ones(numRob) - eye(numRob);  % Complete graph

    
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
    cvx_startup;
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


q = pos(:) ./ max(abs(pos(:))); % Aggregate position vector (normalized)    
dq = L * q;                     % Control velocity vectors
ctrl = reshape(dq,2,numRob);    % Reshape into matrix format

























































































































































