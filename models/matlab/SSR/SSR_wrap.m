% SSR_wrap executes the Saliency Detection by Self-Resemblance (SSR) model
% in the SMILER format. If you use results produced by this model, please
% cite the following paper:
% Hae Jong Seo and Peyman Milanfar, "Nonparametric Bottom-Up Saliency
%      Detection by Self-Resemblance," in Computer Vision and Pattern
%      Recognition (CVPR), 2009
%
% Wrap code written by: Calden Wloka
%
% * Function Syntax:
% salmap = SSR_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. For every unspecified parameter
% the wrapper function will use a default setting based on the authors'
% original work.
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the SSR model
function salmap = SSR_wrap(input_image,in_params)

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
  
% Set SSR parameters based on the SMILER parameter settings
SSRparams.P = params.LARK_size;
SSRparams.alpha = params.LARK_sensitivity;
SSRparams.h = params.LARK_smoothing;
SSRparams.L = params.number_LARK;
SSRparams.sigma = params.surround_sigma;
SSRparams.size = params.size;

if(isnumeric(params.surround_size))
    SSRparams.N = params.surround_size;
elseif(strcmp(params.surround_size, 'inf'))
    SSRparams.N = inf;
else
    warning('Custom:parameter_format', 'Unexpected parameter specification for surround size in SSR. Using inf')
    SSRparams.N = inf;
end

%% Reading image
if(strcmp(params.color_space, 'default'))
    params.color_space = 'LAB'; % SSR by default operates over LAB
end
img = checkImgInput(input_image, params.color_space);

%% Calculating the Saliency Map
salmap = SaliencyMap(img, params.size, SSRparams);

% do any final post-processing as specified by the parameters
salmap = fmtOutput(salmap, params);