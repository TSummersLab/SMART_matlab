% getSpheroSetupBlockUserData(modelHandle, spheroVarNumber)
%  Searches the model for the Sphero Name Setup block specified by <spheroVarNumber> (e.g., 'Sphero1')
%  and returns the userdata of that block. Throws an error if there isn't a unique
%  match for the block or if the userdata is empty.
% 
%  modelHandle can be a string or a numeric handle 
%  spheroVarNumber is a string, corresponding to the spheroVarNumber parameter (e.g., 'Sphero1')
%
% Example:
%  customData = getSpheroSetupBlockUserData(bdroot(gcb), 'Sphero1');
%  customData = getSpheroSetupBlockUserData(bdroot(block.BlockHandle), block.DialogPrm(1).Data); % in a M S-fcn

%   Copyright 2015 The MathWorks, Inc.

function data = getSpheroSetupBlockUserData(modelHandle, spheroVarNumber)

blockName = find_system(modelHandle,...
    'SearchDepth', 1, ...
    'MaskType', 'Sphero Name Setup', ...
    'spheroVarNumber', spheroVarNumber);

if numel(blockName) == 0
    error('Cannot find Sphero Name Setup Block for ''%s'' at top level of model', spheroVarNumber);
elseif numel(blockName) > 1
    error('Multiple Sphero Name Setup Blocks for ''%s''', spheroVarNumber);
end

data = get_param(blockName, 'UserData');
if isempty(data)
   error('Sphero Name Setup Block for ''%s'' is not initialized', spheroVarNumber); 
end
