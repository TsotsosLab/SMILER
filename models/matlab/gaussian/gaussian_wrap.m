% gaussian_wrap produces a centered Gaussian scaled by the height and
% width of the image as the resultant saliency map. It is independent of
% the image appearance, and is meant to serve as a spatial prior baseline.
%
% Code written by: Calden Wloka
%
% * Function Syntax:
% salmap = gaussian_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix; used only to get the return dimensions for the map
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('gaussian')
% **** Output ****
% * salmap = A matrix representing saliency map values according to a
% centered Gaussian spatial prior
function salmap = gaussian_wrap(input_image, in_params)

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
img = checkImgInput(input_image, params.color_space);

%% Calculating the saliency map
[w,h,~] = size(img);

if(params.is_square)
    sigma = [params.sigma*max([w,h]), params.sigma*max([w,h])];
else
    sigma = params.sigma*[w,h];
end

if(mod(w,2) == 0)
    xw = -w/2:(w/2)-1;
else
    xw = ceil(-w/2):floor(w/2);
end

if(mod(h,2) == 0)
    xh = -h/2:(h/2)-1;
else
    xh = ceil(-h/2):floor(h/2);
end

g_xw = normpdf(xw,0,sigma(1));
g_xh = normpdf(xh,0,sigma(2));

salmap = g_xw'*g_xh;

% check for post-processing steps such as smoothing and value scaling
salmap = fmtOutput(salmap, params);
