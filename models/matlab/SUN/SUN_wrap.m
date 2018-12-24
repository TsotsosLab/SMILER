% SUN_wrap executes the Saliency Using Natural statistics (SUN) model in
% the SMILER format. If you use results produced by this model, please cite 
% the following paper:
% Lingyun Zhang, Matthew H. Tong, Tim K. Marks, Honghao Shan, and Garrison
%       W. Cottrell (2008). SUN: A Bayesian Framework for Saliency Using
%       Natural Image Statistics. Journal of Vision, 8(7):32, 1-20
%
% * Function Syntax:
% salmap = SUN_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('SUN')
% **** Output ****
% * mySMap = A matrix representing saliency map values across the visual
% field produced by the SUN model
function salmap = SUN_wrap(input_image,in_params)

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
% SUN expects a three-channel image, so it must enforce that
img = checkImgInput(input_image, params.color_space, true);

%% Calculating the saliency map
if(params.sun_convolution)
    salmap=saliencyimage_convolution(img,1)/255; % use the convolution form of SUN; slower, but can take larger input
else
    salmap=saliencyimage(img,1)/255; % this is the default version of SUN; it should be numerically the same, but executes faster
end

% SUN defaults to returning an image with pixels that don't have a fully
% defined convolution trimmed, removing the kernel half-width from each
% image border. However, by default SMILER should return the 
% pad the array with zeros to return it to the original image size
if(params.pad_results)
    [h, ~, ~] = size(img);
    [sh, ~] = size(salmap);
    salmap = padarray(salmap, [(h-sh)/2, (h-sh)/2], 0, 'both');
end

% check for post-processing steps such as smoothing and value scaling
salmap = fmtOutput(salmap, params);
