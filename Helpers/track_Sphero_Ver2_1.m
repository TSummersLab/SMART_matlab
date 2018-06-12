% Sphero tracking by finding the closet neighboring point in a one-to-one 
% fashion.
%
% Inputs:
%
%       - posOld: A 2xM matrix of old positions, each column represents a
%                 position vector.
%       - posNew: A 2xN matrix of new positions. (Must have N >= M)   
%
% 'posNew' will be reordered to match 'posOld' based on the closet
% distance. 'posNew' can have more points than 'posOld', but only the
% closet points to 'posOld' will be returned.
%
function [posOrdered, PtIdx] = track_Sphero_Ver2_1(posOld, posNew)

nOld = size(posOld,2);
nNew = size(posNew,2);

dist = zeros(1, nOld*nNew);
idx = zeros(2, nOld*nNew);
PtIdx = zeros(1, nOld);

% Find distance between all point pairs in posNew and posOld
itr = 0;
for i = 1 : nOld
    for j = 1 : nNew
        itr = itr + 1;
        dist(itr) = sum( (posOld(:,i)-posNew(:,j)).^2 );  % Distance squared
        idx(:,itr) = [i;j];
    end
end

posOrdered = zeros(2,nOld);

for i = 1 : nOld
    % Choose points with the least distance
    [~,sIdx] = sort(dist,'ascend');
    ptIdx = idx(2,sIdx(1));
    id    = idx(1,sIdx(1));
    posOrdered(:,id) = posNew(:,ptIdx);
    PtIdx(i) = ptIdx;
    
    % Remove chosen points from the set of available points
    remIdx = (idx(2,:) == ptIdx) | (idx(1,:) == id);
    idx(:,remIdx) = [];
    dist(remIdx) = [];
end
    












































