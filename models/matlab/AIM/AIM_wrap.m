% AIM_wrap executes the Attention by Information Maximization (AIM)
% saliency model in the SMILER format. If you use results produced
% by this model, please cite
% the following paper:
% N.D.B. Bruce and J.K. Tsotsos (2006). Saliency Based on Information
%   Maximization. Proc. Neural Information Processing Systems (NIPS)
%
% Wrap code written by: Calden Wloka
%
% * Function Syntax:
% salmap = AIM_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('AIM')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the AIM model
function salmap = AIM_wrap(input_image,in_params)

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

%% Reading the image
% AIM expects a three-channel image, so it must enforce that
img = checkImgInput(input_image, params.color_space, true);

%% Calculating the saliency map
if(strcmp(params.do_smoothing, 'default'))
    salmap = AIM_convolve(img,1,true,params.AIM_filters,0);
else
    salmap = AIM_convolve(img,1,false,params.AIM_filters,0);
end

% check for post-processing steps such as smoothing and value scaling
salmap = fmtOutput(salmap, params);
