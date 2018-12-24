% SMILER uninstall file
% This function will undo the actions of iSMILER by removing all SMILER
% components from the MATLAB path.
% Author: Calden Wloka
function unSMILER()

filepath = mfilename('fullpath');
[pathroot, ~, ~] = fileparts(filepath);
pathroot = fileparts([pathroot, '..']); % strip off one folder layer for the remove path calls

rmpath(genpath([pathroot, '/smiler_matlab_tools'])); % remove common files from the path
rmpath(genpath([pathroot, '/models/matlab'])); % remove all model files from the path

savepath;
