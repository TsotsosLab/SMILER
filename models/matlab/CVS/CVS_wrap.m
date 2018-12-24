% CVS_wrap executes the Covariance-based Saliency (CVS) model in the common
% SMILER format. If you use results produced by this model, please cite 
% the following paper:
% Erkut Erdem and Aykut Erdem (2013). Visual saliency estimation by
%   nonlinearly integrating features using region covariances. Journal of
%   Vision, 13(4):11
%
% Wrap code written by: Calden Wloka
% 
% * Function Syntax:
% salmap = CVS_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('CVS')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the CVS model
function  salmap = CVS_wrap(input_image, in_params)

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
% CVS expects a three-channel image, so it must enforce three channels
if(strcmp(params.color_space, 'default'))
    params.color_space = 'LAB'; % CVS by default operates over LAB
end
img = checkImgInput(input_image, params.color_space, true);

%% Calculating the saliency map

% the options specified by the CVS saliencymap function are in a slightly
% different format than SMILER parameters, so replicate the fields to match
if(strcmp(params.center_prior, 'default'))
    params.centerBias = true;
else
    params.centerBias = false;
end

salmap = saliencymap(img, params);

% do any final post-processing as specified by the parameters
salmap = fmtOutput(salmap, params);