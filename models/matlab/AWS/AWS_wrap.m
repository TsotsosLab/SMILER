% AWS_wrap executes the Adaptive Whitening Saliency (AWS) saliency model 
% in the common SMILER format. If you use results produced by this model,
% please cite the following paper:
% Garcia-Diaz, Antón, et al. (2012) "Saliency from hierarchical adaptation
%   through decorrelation and variance normalization." Image and Vision 
%   Computing 30:51-64.
%
% Wrap code written by: Calden Wloka
% NOTE: AWS does not have the complete source-code available, so it is
% only supported in MATLAB versions older than 2017b and has few tunable
% parameters
%
% * Function Syntax:
% salmap = AWS_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('AWS')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the AWS model
function salmap = AWS_wrap(input_image,in_params)

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

%% Reading image
img = checkImgInput(input_image, params.color_space);

%% Calculating the Saliency Map
% evalc is used to suppress the output from aws.p
% The third argument is smoothing, and represents the standard deviation in
% terms of percent of the largest image dimension.
if(strcmp(params.do_smoothing, 'default'))
	[~, salmap] = evalc('aws(img,1,2.1)');
else
	[~, salmap] = evalc('aws(img,1,0)');
end

% check for post-processing steps such as smoothing and value scaling
salmap = fmtOutput(salmap, params);