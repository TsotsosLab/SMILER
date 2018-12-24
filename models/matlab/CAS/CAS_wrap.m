% CAS_wrap executes the Context Aware Saliency (CAS) model in the common
% SMILER format. If you use results produced by this model, please cite 
% the following paper:
% Stas Goferman, Lihi Zelnik-Manor, and Ayellet Tal (2012). Context-Aware
%   Saliency Detection. PAMI 34:1915-1926
%
% !IMPORTANT!
% Due to the original study authors releasing only a MATLAB binary rather
% than the complete code at the time of this writing (July 2015), the code
% being used is actually implemented by Jyun-Fan Tsai and Kai-Jeuh Chang,
% retrieved from:
% https://sites.google.com/a/jyunfan.co.cc/site/home
% The code was written as faithfully as possible according to the algorithm
% described in the paper, but may have slight differences.
% The decision to use this version was because the original version only
% accepts a file name, and cannot be called on images directly (which
% breaks the ease of use of SMILER).
%
% Wrap code written by: Calden Wloka
%
% * Function Syntax:
% salmap = CAS_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('CAS')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the CAS model
function salmap = CAS_wrap(input_image, in_params)

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
[w,h,~] = size(img);

salmap = Saliency(img,0);

% CAS resizes the image to have a maximum dimension of 520 pixels; SMILER
% expects to return a saliency map of equivalent size to the input image
salmap = imresize(salmap, [w,h]);

% apply any desired post-processing
salmap = fmtOutput(salmap, params);