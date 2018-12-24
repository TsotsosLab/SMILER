% Model-specific SMILER parameter formatting
% Internal SMILER function which loads the json information for a specific
% model and populates all unspecified parameter fields with default values
% ***** Usage: *****
% out_params = checkCommonParams(in_params)
% ***** Inputs: *****
% params: A structure containing parameter fields which have been
% externally assigned.
% json_path: The path to the model's smiler.json file
% ***** Outputs: *****
% params: The input structure modified to include default values for any
% model parameters not already specified
% ***** Notes: *****
% To see a list of model parameters and their default values, use the
% function smiler_info(MODEL_NAME)
% Author: Calden Wloka
function params = checkModelParams(params, json_path)

% load in the default parameters
info = loadjson(json_path);
default_params = info.parameters;

if(~isempty(default_params))
    param_fields = fieldnames(default_params);
    for i = 1:numel(param_fields)
        % If the parameter has already been specified, take that value,
        % else populate the field with default values
        if(~isfield(params, param_fields{i}))
            params.(param_fields{i}) = default_params.(param_fields{i}).default;
        end
    end
end