% RARE2012_wrap executes the RARE2012 model in the SMILER format.
% If you use results produced by this model, please cite the following 
% papers:
% N. Riche, M. Mancas, B. Gosselin, and T. Dutoit (2012). RARE: A new
%      bottom-up saliency model. ICIP.
%
% N. Riche, M. Mancas, M. Duvinage, M. Mibulumukini, B. Gosselin, and 
%      T. Dutoit. (2013) RARE2012: A multi-scale rarity-based saliency 
%      detection with its comparative statistical analysis. 
%      Signal Processing: Image Communication, 28:6, 642–658
%
% Wrap code written by: Calden Wloka
% NOTE: RARE2012 does not have the complete source-code available, so it
% has no tunable parameters outside of global pre- and post-processing.
%
% * Function Syntax:
% salmap = RARE2012_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. For every unspecified parameter
% the wrapper function will use a default setting based on the authors'
% original work.
% NOTE: 
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the RARE2012 model
function salmap = RARE2012_wrap(input_image, in_params)

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
img = checkImgInput(input_image, params.color_space, true);

%% Calculating the Saliency Map
salmap = RARE2012(img);

% check for post-processing steps such as smoothing and value scaling
salmap = fmtOutput(salmap, params);

end

