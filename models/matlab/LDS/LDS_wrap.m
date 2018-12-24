% LDS_wrap executes the Saliency based on learning discriminative subspaces (LDS)
% saliency model in the common SMILER format. If you use results produced
% by this model, please cite
% the following paper:
% Fang, S., Li, J., Tian, Y., Huang, T., & Chen, X. (2017). Learning 
%    discriminative subspaces on random contrasts for image saliency 
%    analysis. IEEE transactions on neural networks and learning systems,
%    28(5), 1095-1108.
%
% Wrap code written by: Iuliia Kotseruba
% Original code modified: post-processing step is removed from
% GetSaliencyMap.m
% Updated by: Calden Wloka, December 2018
%
% * Function Syntax:
% salmap = LDS_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('LDS')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the LDS model
function salmap = LDS_wrap(input_image,in_params)

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
if(strcmp(params.color_space, 'default'))
    params.color_space = 'LAB'; % LDS by default operates over LAB
end
% LDS expects a three-channel image, so it must enforce three channels
img = checkImgInput(input_image, params.color_space, true);

%% Calculating the Saliency Map
model = load('model.mat'); % Load pre-designed model information.
lab_pca_book = load('LAB_pca.mat'); % load the learned PCA space for LAB space   
 
salmap = GetSaliencyMap(img,model.x,lab_pca_book);

salmap = imresize(gbvsNorm(salmap),size(salmap)); % normalize the saliency map using GBVS normalization tools

% LDS has some default smoothing applied before resizing the image to its
% original size
if(strcmp(params.do_smoothing, 'default'))
    gkern = fspecial('gaussian', [5,5], 2.5);
    salmap = imfilter(salmap, gkern);
end

% resize to original image size
salmap = imresize(salmap, [size(img,1), size(img, 2)]);

% LDS by default scales the map to the uint8 range [0,255], but in keeping
% with SMILER expected operation we output a double map over [0,1]
if(strcmp(params.scale_output, 'none'))
    MaxValue = max(salmap(:));
    MinValue = min(salmap(:));
    salmap = (salmap - MinValue) / (MaxValue - MinValue + eps);
end

% do any final post-processing as specified by the parameters
salmap = fmtOutput(salmap, params);

