% SMILER matlab component installation file
% Function to add common SMILER functions and MATLAB-based models to the
% path.
% **** Syntax ****
% iSMILER(save_path)
% **** Input ****
% * save_path: A Boolean flag which indicates whether to save path
%     modifications (true) or to only make path changes temporarily for the
%     current MATLAB session (false). Defaults to false.
% Author: Calden Wloka
function iSMILER(save_path)

if(nargin < 1)
    save_path = false; % default to not saving any modifications to the path
end

pathroot = mfilename('fullpath');
[pathroot, ~, ~] = fileparts(pathroot);
pathroot = fileparts([pathroot, '..']); % strip off one folder layer for the addpath calls

addpath(genpath([pathroot, '/smiler_matlab_tools']), '-begin'); % add common files to the path
addpath(genpath([pathroot, '/models/matlab']), '-begin'); % add all model files to the path

if(save_path)
    savepath;
end
