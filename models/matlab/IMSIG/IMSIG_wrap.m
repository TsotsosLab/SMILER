% IMSIG_wrap executes the Image Signature saliency model in the common
% SMILER format. If you use results produced by this model, please cite 
% the following paper:
%     X. Hou, J. Harel, and C. Koch. Image signature: Highlighting
%     sparse salient regions. IEEE Transactions on Pattern
%     Analysis and Machine Intelligence, 34:194-201, 2012.
%
% Wrap code written by: Calden Wloka
%
% * Function Syntax:
% salmap = IMSIG_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters defined by the model's authors. To see
% a list of available model-specific parameters, use the function call:
% smiler_info('IMSIG')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the IMSIG model
function salmap = IMSIG_wrap(input_image, in_params)

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
  
% Note that some of the IMSIG parameter fields conflict with SMILER
% parameter formatting; this is handled here
if(~strcmp(params.do_smoothing, 'default'))
    % we do not want default smoothing, so turn off all smoothing in the
    % IMSIG code and allow SMILER functions to handle it
    params.blurSigma = 0;
else
    params.blurSigma = 0.045;
end

% Set IMSIG parameters which are static within SMILER
params.resizeToInput = 1;
params.subtractMin = 0; % Note that this is subsumed by SMILER's normalization procedure

%% Reading image
if(strcmp(params.color_space, 'default'))
    params.color_space = 'LAB'; % IMSIG by default operates over LAB
end
img = checkImgInput(input_image, params.color_space);

%% Calculating the Saliency Map
salmap = signatureSal(img, params);

% check for post-processing steps such as smoothing and value scaling
salmap = fmtOutput(salmap, params);