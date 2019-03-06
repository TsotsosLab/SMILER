% SMILER example script showing the execution of several SMILER models over
% the example images provided with the SMILER package. Note that relative
% paths are assumed to be preserved within the SMILER project. 
%
% This example executes the AIM, AWS, IKN, IMSIG, and QSS models over the
% images located in
% [path-to-smiler]/SMILER/examples/input_images
% The default output from all models is placed in subfolders of the
% location
% [path-to-smiler]/SMILER/examples/output_maps_default
% Then AIM, AWS, and IMSIG are re-run using a set of custom parameters for
% each, and the output of these runs is placed into subfolders within
% [path-to-smiler]/SMILER/examples/output_maps_custom
%
% The example code itself is commented for clarity
%
% Author: Calden Wloka
% Last Update: December, 2018

%% Check if SMILER is installed

% This call checks to see if iSMILER has been added to the search path;
% this is used as a proxy to check and see if SMILER has already been set
% up for this particular MATLAB session.
% If you are creating your own scripts on a system for which iSMILER(true)
% has been run, you can omit this step.
if(exist('iSMILER.m', 'file') ~= 2)
    pathroot = mfilename('fullpath'); % get the current file location
    [pathroot, ~, ~] = fileparts(pathroot); % trim off the file name so we get the current directory
    cd('../../smiler_matlab_tools'); % navigate to where iSMILER is located
    iSMILER; % add SMILER models to the MATLAB path
    cd(pathroot); % return to our original location to execute this example
end

%% Set up the default experiment
models = {'AIM', 'AWS', 'IKN', 'IMSIG', 'QSS'}; % a cell array of the SMILER model codes which we wish to execute

% The next few lines create a dynamically allocated array of function
% handles to invoke the models specified in the previous line
modfun = cell(length(models),1);
for i = 1:length(models)
    modfun{i} = str2func([models{i}, '_wrap']);
end

input_set = dir('../input_images'); % get the list of images located in the example directory
input_set = input_set(3:end);  % trim folder navigation elements '.' and '..'

% if the output directory does not yet exist, make it
if(~exist('../output_maps_default', 'dir'))
    mkdir('../output_maps_default');
end

% check to see if the output directories exist to save the output maps for
% each model. If the directories do not exist, make them
for j = 1:length(models)
    if(~exist(['../output_maps_default/', models{j}], 'dir'))
        mkdir(['../output_maps_default/', models{j}]);
    end
end
    
%% Calculate default output maps and save them
% loop through images in the outer loop to save on imread commands
disp('Now starting the experiment using default parameters');
for i = 1:length(input_set)
    img = imread(['../input_images/', input_set(i).name]); % read in the image
    for j = 1:length(models)
        disp(['Executing model ', models{j}, ' on image ', num2str(i), ' of ', num2str(length(input_set))]);
        salmap = modfun{j}(img); % execute the jth model on the ith image
        imwrite(salmap, ['../output_maps_default/', models{j}, '/', input_set(i).name]); % save the saliency map
    end
end
disp(' '); % create a space in the display output before starting the next experiment

%% Set up and run custom experimental runs

% In the first experiment, run AWS and IMSIG in different colour spaces to
% see how that affects their output
% Note that for at least one loop through cspaces we will be replicating
% the output of the default run; this is simply being used to demonstrate
% explicit colour space specification
cspaces = {'RGB', 'LAB', 'HSV'};
models = {'AWS', 'IMSIG'};
modfun = cell(length(models),1);
for i = 1:length(models)
    modfun{i} = str2func([models{i}, '_wrap']);
end

% We need a place to store output, so set that up
% if the output directory does not yet exist, make it
if(~exist('../output_maps_custom', 'dir'))
    mkdir('../output_maps_custom');
end

% check to see if the output directories exist to save the output maps for
% each model in each colour space. 
for j = 1:length(models)
    for k = 1:length(cspaces)
        if(~exist(['../output_maps_custom/', models{j}, '_', cspaces{k}], 'dir'))
            mkdir(['../output_maps_custom/', models{j}, '_', cspaces{k}]);
        end
    end
end

% now run the experiment
params = struct();
disp('Now running the colour space experiment');
for i = 1:length(input_set)
    img = imread(['../input_images/', input_set(i).name]); % read in the image
    for j = 1:length(models)
        for k = 1:length(cspaces)
            params.color_space = cspaces{k};
            disp(['Executing model ', models{j}, ' in colour space ', cspaces{k}, ' on image ', num2str(i), ' of ', num2str(length(input_set))]);
            salmap = modfun{j}(img, params); % execute the jth model on the ith image passing in our custom parameter
            imwrite(salmap, ['../output_maps_custom/', models{j}, '_', cspaces{k}, '/', input_set(i).name]); % save the saliency map
        end
    end
end
disp(' '); % space for output readability

% In the second experiment we concentrate on the AIM algorithm and
% investigate what happens when we vary the model-specific parameter field
% and change the set of basis filters used to calculate saliency
bases = {'21infomax975.mat', '31infomax950.mat', '31jade900.mat'};

% check to see if the output directories exist to save the output maps for
% each set of filter bases
for k = 1:length(bases)
    if(~exist(['../output_maps_custom/AIM_', bases{k}], 'dir'))
        mkdir(['../output_maps_custom/AIM_', bases{k}]);
    end
end

params = struct(); % reset params to make sure we don't accidentally assign an unexpected colour space
disp('Now running the AIM basis experiment');
for i = 1:length(input_set)
    img = imread(['../input_images/', input_set(i).name]); % read in the image
    for k = 1:length(bases)
        params.AIM_filters = bases{k};
        disp(['Executing AIM with basis ', bases{k}, ' on image ', num2str(i), ' of ', num2str(length(input_set))]);
        salmap = AIM_wrap(img, params); % since we know which model we are executing here, we don't need function handles and can directly call it's wrapper function
        imwrite(salmap, ['../output_maps_custom/AIM_', bases{k}, '/', input_set(i).name]); % save the saliency map
    end
end