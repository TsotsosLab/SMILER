% IKN_wrap executes the Itti-Koch-Niebur (IKN) model in the
% SMILER format. If you use results produced by this model, please cite 
% the following paper:
% L. Itti, C. Koch, and E. Niebur (1998). A Model of Saliency-Based Visual
%   Attention for Rapid Scene Analysis. IEEE Transactions on Pattern
%   Analysis and Machine Intelligence. 20:1254-1259
%
% Wrap code written by: Calden Wloka
%
% * Function Syntax:
% salmap = IKN_wrap(input_image, params)
% **** Input ****
% * input_image = Either the file name of an image to analyze or the image
% matrix
% * params = A structure variable that allows the user to control any
% algorithm-specific tunable parameters. The algorithm will default to
% using a set of default parameters. Note that these default parameters do
% not fully reflect the original 1998 paper, but are rather based on best
% recommended settings from the code released by Harel from:
% http://www.klab.caltech.edu/~harel/share/gbvs.php
% To see a list of available model-specific parameters, use the function 
% call: smiler_info('IKN')
% **** Output ****
% * salmap = A matrix representing saliency map values across the visual
% field produced by the IKN model
function salmap = IKN_wrap(input_image, in_params)

%% GBVS pathing
% IKN relies on code bundled with GBVS, so needs to have the helper
% utilities and functions from the GBVS folder available on the path;
% redundant if gbvs_install has been run with the command to 'savepath'
% uncommented, but retained for completeness and ease of use.
pathroot = mfilename('fullpath');
pathfolders = strsplit(pathroot,{'/','\'},'CollapseDelimiters',true);
pathroot = pathroot(1:end-(length(pathfolders{end})+length(pathfolders{end-1})+2));
pathroot = strcat(pathroot, '/GBVS');
save(strcat(pathroot, '/util/mypath.mat'), 'pathroot', '-mat');
addpath(genpath(strcat(pathroot)), '-begin');

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

% Perform IKN internal settings to interface IKN parameters with SMILER
% global parameters or set IKN parameters which should not change
params.useIttiKochInsteadOfGBVS = 1; % We want IKN, not GBVS
params.verbose = 0; % We don't want verbose turned on
params.saveInputImage = 0; % We don't want to output the input image as part of its output struct
params.activationType = 2; % It is unclear why this needs to be set if useIttiKochInsteadOfGBVS is set, but this is an expected parameter for gbvs code
params.normalizeTopChannelMaps = 1; % Again, this seems to be something which should be controlled by useIttiKochInsteadOfGBVS, but is specified individually
params.unCenterBias = false; % The unCenterBias step is designed for GBVS, so turn off for IKN
params.levels = [2,3,4]; % it is unclear why this must be specified for IKN since it is expressly designated a GBVS parameter, but the code does not work without it
params.salmapmaxsize = 32; % it is unclear why this must be specified for IKN since it is a GBVS parameter, but the code does not work without it

if(~strcmp(params.do_smoothing, 'default'))
    % we do not want default smoothing, so turn off all smoothing in the
    % IKN code and allow SMILER functions to handle it
    params.ittiblurfrac = 0;
else
    params.ittiblurfrac = 0.03; % default IKN smoothing, not in original paper
end

% Note that IKN by default uses DKL colour space instead of RGB (not in the
% original paper, but in the code released with GBVS).
% Therefore, if color_space is set to default, use the recommended
% settings, otherwise we want to use the colour channel specified by
% color_space. In the default case, we need to copy over the color
% parameters to the DKL settings
if(strcmp(params.color_space, 'default'))
    params.channels = strrep(params.channels, 'C', 'D');
end
params.dklcolorWeight = params.colorWeight;

%% Reading the image
img = checkImgInput(input_image, params.color_space);

%% Calculating the saliency map
[out,~] = gbvs(img, params);

salmap = out.master_map_resized;

% do any final post-processing as specified by the parameters
salmap = fmtOutput(salmap, params);