% GBVS_wrap executes the Graph-Based Visual Saliency (GBVS) model in the
% SMILER format. If you use results produced by this model, please cite
% the following paper:
% J. Harel, C. Koch, and P. Perona (2006). Graph-Based Visual Saliency.
%   Proc. Neural Information Processing Systems (NIPS)
%
% Wrap code written by: Calden Wloka
%
% * Function Syntax:
% salmap = GBVS_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('GBVS')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the GBVS model
function salmap = GBVS_wrap(input_image,in_params)

%% GBVS pathing
% Add the helper utilities and functions to the path so GBVS can run;
% redundant if gbvs_install has been run with the command to 'savepath'
% uncommented, but retained for completeness and ease of use.
pathroot = mfilename('fullpath');
pathroot = pathroot(1:end-length(mfilename)); % remove the filename from pathroot to give the root folder path
save(strcat(pathroot, '/util/mypath.mat'), 'pathroot', '-mat');
addpath(genpath(pathroot), '-begin'); % add all necessary files

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

% Perform GBVS internal settings to interface GBVS parameters with SMILER
% global parameters or set GBVS parameters which should not change
params.verbose = 0; % We don't want GBVS verbose turned on
params.saveInputImage = 0; % We don't want GBVS to output the input image as part of its output struct
params.cyclic_type = 2; % Should not be changed according to GBVS original authors
params.useIttiKochInsteadOfGBVS = 0; % We want GBVS, not IKN
params.activationType = 1; % It is unclear why this needs to be set if useIttiKochInsteadOfGBVS is set, but this is an expected parameter for gbvs code
params.normalizeTopChannelMaps = 0; % Again, this seems to be something which should be controlled by useIttiKochInsteadOfGBVS, but is specified individually

if(strcmp(params.center_prior, 'default'))
    params.unCenterBias = false; % We want GBVS to run as it normally would
else
    params.unCenterBias = true; % We want to try and control the spatial bias through SMILER, so remove as much as we can from GBVS
end

if(~strcmp(params.do_smoothing, 'default'))
    % we do not want default smoothing, so turn off all smoothing in the
    % GBVS code and allow SMILER functions to handle it
    params.blurfrac = 0;
else
    params.blurfrac = 0.02; % default GBVS smoothing
end

% Note that GBVS by default uses DKL colour space instead of RGB.
% Therefore, if color_space is set to default, use the GBVS recommended
% settings, otherwise we want to use the colour channel specified by
% color_space. In the default case, we need to copy over the color
% parameters to the DKL settings
if(strcmp(params.color_space, 'default'))
    params.channels = strrep(params.channels, 'C', 'D');
end
params.dklcolorWeight = params.colorWeight;

%% Reading the image
img = checkImgInput(input_image, params.color_space);

%% Calculating the saliency map
[out,~] = gbvs(img, params);

salmap = out.master_map_resized;

% do any final post-processing as specified by the parameters
salmap = fmtOutput(salmap, params);
