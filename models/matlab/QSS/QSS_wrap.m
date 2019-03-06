% QSS_wrap executes the Quaternion-Based Spectral Saliency (QSS) model in
% the SMILER format. If you use results produced by this model, please cite 
% one or both of the following papers:
% B. Schauerte, and R. Stiefelhagen, "Quaternion-based Spectral Saliency
%   Detection for Eye Fixation Prediction," in European Conference on 
% 	Computer Vision (ECCV), 2012
% B. Schauerte, and R. Stiefelhagen, "Predicting Human Gaze using 
%   Quaternion DCT Image Signature Saliency and Face Detection," in IEEE
%   Workshop on Applications in Computer Vision (WACV), 2012
%
% Wrap code written by: Calden Wloka
%
% * Function Syntax:
% salmap = QSS_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors.
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the QSS model
function salmap = QSS_wrap(input_image,in_params)

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

% convert SMILER parameter specifications into the format expected by QSS
if(params.do_channel_smoothing)
    cmap_smoothing_filter_params = {'gaussian', params.ch_smooth_size, params.ch_smooth_std}; % filter parameters for the channel smoothing
else
    cmap_smoothing_filter_params = {}; % empty because we aren't smoothing the channels
end

if(strcmp(params.do_smoothing, 'default'))
    smoothing_filter = {'gaussian',9,2.5}; % default smoothing for QSS
else
    smoothing_filter = {}; % do whatever non-default smoothing is specified through SMILER
end
do_figures = false; % enable/disable spectral_saliency_multichannel's integrated visualizations - this is always off in SMILER
params.do_range_normalization = false; % SMILER will handle saliency value scaling
params.do_separate_scale_filtering = false; % Since SMILER handles custom smoothing, this becomes problematic to integrate. If this option is desired, users should run QSS outside of the wrap function
params.residual_filter = params.residual_filter_length; % This appears to be inconsistently implemented in spectral_saliency_multichannel.m, so make sure the parameter gets read appropriately

%% Reading image
if(strcmp(params.color_space, 'default'))
    params.color_space = 'YCbCr'; % QSS by default operates over YUV, which is specified in MATLAB as YCbCr
end
img = checkImgInput(input_image, params.color_space);

% Some parameters specified through SMILER need to be converted into an
% appropriate format for interpretation by QSS. Now that the image is
% loaded, we can set them here.
imsize = [0, 0]; % initialize the image size tuple
if(params.im_width == 0)
    imsize(2) = size(img, 2);
else
    imsize(2) = params.im_width;
end
if(params.im_height == -1)
    imsize(1) = NaN;
elseif(params.im_height == 0)
    imsize(1) = size(img, 1);
else
    imsize(1) = params.im_height;
end

[out_w, out_h, ~] = size(input_image);

%% Calculating the Saliency Map
salmap = mat2gray(spectral_saliency_multichannel(img,imsize,params.qss_method,smoothing_filter,cmap_smoothing_filter_params,params.channel_normalization,params,do_figures));

% need to rescale the saliency map back to the original image size
salmap = imresize(salmap, [out_w, out_h]);

% check for post-processing steps such as smoothing and value scaling
salmap = fmtOutput(salmap, params);