% FES_wrap executes the Fast and Efficient Saliency (FES)
% saliency model in the common SMILER format. If you use results produced
% by this model, please cite
% the following paper:
% Tavakoli, Hamed Rezazadegan, Esa Rahtu, and Janne Heikkilä. "Fast and
%    efficient saliency detection using sparse sampling and kernel
%    density estimation." In Scandinavian Conference on Image Analysis,
%    pp. 666-675. Springer, Berlin, Heidelberg, 2011.
%
% Wrap code written by: Iuliia Kotseruba
% Updated by: Calden Wloka, December 2018
%
% * Function Syntax:
% salmap = FES_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('FES')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the FES model
function salmap = FES_wrap(input_image,in_params)

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
% FES expects a three-channel image, so it must enforce three channels
img = checkImgInput(input_image, params.color_space, true);

% FES by default uses a custom LAB conversion
if(strcmp(params.color_space, 'default'))
    img = RGB2Lab(img);
end

%% Calculating the saliency map
if(strcmp(params.center_prior, 'default'))
    load('prior', 'p1');
else
    p1 = 0.5*ones(128, 171); % Creates a uniform prior
end

%% compute the saliency
% function saliency = computeFinalSaliency(image, pScale, sScale, alpha, sigma0, sigma1, p1)
salmap = computeFinalSaliency(img, params.pScale, params.sScale, params.attenuation_factor, params.surround_sigma, params.center_sigma, p1);

[w, h, ~] = size(img);
salmap = imresize(salmap, [w, h]); % we need to resize the map to the dimensions of the original image

% check for post-processing steps such as smoothing and value scaling
salmap = fmtOutput(salmap, params);
