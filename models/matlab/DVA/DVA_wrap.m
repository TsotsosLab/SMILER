% DVA_wrap executes the Dynamic Visual Attention (DVA) model in the common
% SMILER format. If you use results produced by this model, please cite
% the following paper:
% Hou, Xiaodi, and Liqing Zhang. "Dynamic visual attention:
%   Searching for coding length increments." Advances in neural
%   information processing systems. 2009.
%
% Wrap code written by: Calden Wloka
%
% * Function Syntax:
% salmap = DVA_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('DVA')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the DVA model
function salmap = DVA_wrap(input_image,in_params)

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
img = checkImgInput(input_image, params.color_space, true);

%% Calculating the saliency map

% resize the image
[imgH, imgW, ~] = size(img);
img = imresize(img, params.size);

load('AW.mat', 'A', 'W');


% Building Saliency Map
myEnergy = im2Energy(img, W);
salmap = vector2Im(myEnergy, params.size(1), params.size(2));

%resize to original size
salmap = imresize(salmap, [imgH, imgW]);

% do any final post-processing as specified by the parameters
salmap = fmtOutput(salmap, params);
