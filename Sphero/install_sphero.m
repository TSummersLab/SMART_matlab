%% Install Sphero Connectivity Package
% This installs the MATLAB support package for Sphero
%
% Copyright 2015, The MathWorks, Inc.

% Check for 'sphero' file on the path
ws=which('sphero.m','-all');

% Make sure we are in the right folder and there are no other sphero.m files
if length(ws) < 1, 
    msg=' Cannot find sphero.m, please run this file from the folder containing sphero.m';
    error(msg);
elseif length(ws) > 1,
    msg=[' There is at least one more sphero.m file on the path.', ...
         ' Please type pathtool from the command line to open the Set Path dialog box', ...
         ' then remove all folders belonging to a previous sphero installation,', ...
         ' save the new path, and close the dialog box, before running this file again.'];
    error(msg);
end

% Get the folder which contains sphero.m
ap=ws{1};ap=ap(1:end-9);

% Add target directories and save the updated path
addpath(genpath(ap))
disp(' Sphero folders added to the path');

result = savepath;
if result==1
    nl = char(10);
    msg = [' Unable to save updated MATLAB path (<a href="http://www.mathworks.com/support/solutions/en/data/1-9574H9/index.html?solution=1-9574H9">why?</a>)' nl ...
           ' On Windows, exit MATLAB, right-click on the MATLAB icon, select "Run as administrator", and re-run install_sphero.m' nl];
    error(msg);
else
    disp(' Saved updated MATLAB path');
    disp(' ');
end

clear ws ap result nl msg 