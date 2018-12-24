% [skeleton]_wrap executes the [full model name] ([SMILER name])
% saliency model in the SMILER format. If you use results produced
% by this model, please cite the following paper:
% [citation information for the model]
%
% Wrap code written by: [wrap author]
%
% * Function Syntax:
% salmap = [SMILER name]_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('[SMILER name]')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the AIM model
function salmap = [SMILER name]_wrap(input_image,in_params)

%% Setting up parameters
if(nargin < 2)
    in_params = struct();
end

% check parameter fields which are the same across all models, assign defaults to missing fields
params = checkCommonParams(in_params);

% get the path to smiler.json
pathroot = mfilename('fullpath');
[pathroot, ~, ~] = fileparts(pathroot);

% check the model-specific parameter fields
params = checkModelParams(params, [pathroot, '/smiler.json']);

% if the model has any parameters which conflict with how SMILER handles
% parameters, these should be dealt with here. See GBVS_wrap for an
% example.

%% Reading the image
% if the model expects a three-channel image, it must enforce that by
% passing 'true' as a third argument into the checkImgInput function
% if the model expects a non-RGB colour space by default, this value should
% be assigned to params.color_space before invoking the checkImgInput
% function
img = checkImgInput(input_image, params.color_space);

%% Calculating the saliency map

% make a call to the saliency calculation function, as well as check for 
% any default pre- or post-processing which is not included in the saliency
% calculation function 

% perform any post-processing which is being handled by SMILER
salmap = fmtOutput(salmap, params);
