% Common SMILER parameter formatting
% Internal SMILER function which checks some common parameters and assigns
% default values if they have not been set.
% ***** Usage: *****
% out_params = checkCommonParams(in_params)
% ***** Inputs: *****
% in_params: A structure containing parameter fields which have been
% externally assigned. If no argument is passed in all fields will be
% occupied by default values.
% ***** Outputs: *****
% out_params: A structure containing all parameter fields specified by
% in_params, along with default values for any non-specified fields
% ***** Notes: *****
% To see a list of common parameters and their default values, use the
% function smiler_info()
% Author: Calden Wloka
function out_params = checkCommonParams(in_params)

% we need to get the root path of SMILER so we know where to look for the
% parameter information regardless of where on the system this is invoked
pathroot = mfilename('fullpath');
[pathroot, ~, ~] = fileparts(pathroot);
pathroot = fileparts([pathroot, '..']); % strip off one folder layer for the addpath calls

% load in the default parameters
info = loadjson([pathroot, '/config.json']);
default_params = info.parameters;

% verify that the parameter variable is a struct; if not throw a warning to
% let the user know it is being overwritten by default values
if(nargin < 1)
    in_params = struct();
elseif(~isstruct(in_params))
    warning('Custom:parameter_format', 'Expected a parameter struct in checkCommonParams; using default values')
    in_params = struct();
end

% copy over all already user-specified parameters to make sure we don't
% lose or overwrite them
out_params = in_params;

param_fields = fieldnames(default_params);
for i = 1:numel(param_fields)
    % If the parameter has been specified by the user, take that value,
    % else populate the field with default values
    if(~isfield(in_params, param_fields{i}))
        out_params.(param_fields{i}) = default_params.(param_fields{i}).default;
    end
end
