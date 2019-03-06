% SMILER query function to get more information about the parameters
% available to a particular function.
% ***** Usage: *****
% smiler_info(model)
% ***** Inputs: *****
% model: Optional parameter. If given a string containing the SMILER
% designation of a particular model, this will output the name of any
% model-specific parameters available (as well as parameter description and
% default values). If not specified or set to 'global', any global
% parameters which are common to all models will be described.
% ***** Note: *****
% This function displays much better if text wrapping is turned on in the
% MATLAB Command Window preferences
% Author: Calden Wloka
function smiler_info(model)

% we need to get the root path of SMILER so we know where to look for the
% parameter information regardless of where on the system this is invoked
pathroot = mfilename('fullpath'); 
[pathroot, ~, ~] = fileparts(pathroot);
pathroot = fileparts([pathroot, '..']); % strip off one folder layer for the addpath calls

if(nargin < 1 || strcmp(model, 'global'))
    disp('The following models are available within the MATLAB environment:');
    disp(' '); % spacing to make this more readable
    models = dir([pathroot, '/models/matlab']);
    ismod = [models(:).isdir]; % screen for anything which isn't a subdirectory
    modNames = {models(ismod).name}'; % pull out the model names
    modNames(ismember(modNames,{'.','..'})) = []; % get rid of folder navigation items
    
    % now output all models with their names
    disp('SMILER Code    Full Model Name');
    disp(' '); % spacing to make this more readable
    for i = 1:numel(modNames)
        info = loadjson([pathroot, '/models/matlab/', modNames{i}, '/smiler.json']);
        spaces = blanks(15-length(modNames{i}));
        disp([info.name, spaces, info.long_name]);
    end
    
    disp(' '); % spacing to make this more readable
    disp('To find information on a specific model, run the command smiler_info(SMILER_CODE)')
    disp(' '); % spacing to make this more readable
    
    % now output global parameter information
    info = loadjson([pathroot, '/config.json']);
    disp('The following parameters are globally assigned for all models:');
    param_fields = fieldnames(info.parameters);
    for i = 1:numel(param_fields)
        disp(param_fields{i});
        if(isnumeric(info.parameters.(param_fields{i}).default))
            fprintf('\t%s\n', ['Default value: ', num2str(info.parameters.(param_fields{i}).default)]);
        else
            % MATLAB fprintf doesn't have a conversion from Boolean to
            % character, so we need to do this ourselves
            if(islogical(info.parameters.(param_fields{i}).default))
                if(info.parameters.(param_fields{i}).default)
                    fprintf('Default value: true \n');
                else
                    fprintf('Default value: false \n');
                end
            else
                fprintf('\t%s\n', ['Default value: ', info.parameters.(param_fields{i}).default]);
            end
        end
        if(iscell(info.parameters.(param_fields{i}).valid_values))
            if(islogical(info.parameters.(param_fields{i}).valid_values{1}))
                if(info.parameters.(param_fields{i}).valid_values{1})
                    sout = 'true';
                else
                    sout = 'false';
                end
            elseif(isempty(info.parameters.(param_fields{i}).default))
                fprintf('\t%s\n', 'Default value: []');
            else
                sout = [info.parameters.(param_fields{i}).valid_values{1}];
            end
            for j = 2:numel(info.parameters.(param_fields{i}).valid_values)
                if(islogical(info.parameters.(param_fields{i}).valid_values{j}))
                    if(info.parameters.(param_fields{i}).valid_values{j})
                        sout = [sout, ', true'];
                    else
                        sout = [sout, ', false'];
                    end
                else
                    sout = [sout, ', ', info.parameters.(param_fields{i}).valid_values{j}];
                end
            end
            fprintf('\t%s\n', ['Valid values: ', sout]);
        else
            fprintf('\t%s\n', ['Valid values: ', info.parameters.(param_fields{i}).valid_values]);
        end
        fprintf('\t%s\n', ['Description: ', info.parameters.(param_fields{i}).description]);
        disp(' ');
    end
else
    if(exist([model, '_wrap.m'], 'file') == 2)
        info = loadjson([pathroot, '/models/matlab/', model, '/smiler.json']);
        numast = 60;
        astline = repmat(['*'], 1, numast);
        disp(astline);
        txtlen = length(info.name) + length(info.long_name) + 4;
        if(numast > txtlen)
            diflen = numast - txtlen;
            disp([repmat('*', 1, floor(diflen/2)), ' ', info.name, ': ', info.long_name, ' ', repmat('*', 1, ceil(diflen/2))]);
        else
            disp([info.name, ': ', info.long_name]);
        end
        disp(astline);
        disp(' ');
        disp('Model citation information:');
        disp(info.citation);        
        disp(' ');
        if(~isempty(info.parameters))
            param_fields = fieldnames(info.parameters);
            disp(['The following parameters are available for the ', model, ' model:']);
            for i = 1:numel(param_fields)
                disp(' ');
                disp(param_fields{i});
                if(isnumeric(info.parameters.(param_fields{i}).default))
                    fprintf('\t%s\n', ['Default value: ', num2str(info.parameters.(param_fields{i}).default)]);
                elseif(isempty(info.parameters.(param_fields{i}).default))
                    fprintf('\t%s\n', 'Default value: []');
                else
                    % MATLAB fprintf doesn't have a conversion from Boolean to
                    % character, so we need to do this ourselves
                    if(islogical(info.parameters.(param_fields{i}).default))
                        if(info.parameters.(param_fields{i}).default)
                            fprintf('Default value: true \n');
                        else
                            fprintf('Default value: false \n');
                        end
                    elseif(iscell(info.parameters.(param_fields{i}).default))
                        fprintf('\t%s\n', ['Default value: ', cell2mat(info.parameters.(param_fields{i}).default)]);
                    else
                        fprintf('\t%s\n', ['Default value: ', info.parameters.(param_fields{i}).default]);
                    end
                end
                if(iscell(info.parameters.(param_fields{i}).valid_values))
                    if(islogical(info.parameters.(param_fields{i}).valid_values{1}))
                        if(info.parameters.(param_fields{i}).valid_values{1})
                            sout = 'true';
                        else
                            sout = 'false';
                        end
                    else
                        sout = char(info.parameters.(param_fields{i}).valid_values{1});
                    end
                    for j = 2:numel(info.parameters.(param_fields{i}).valid_values)
                        if(islogical(info.parameters.(param_fields{i}).valid_values{j}))
                            if(info.parameters.(param_fields{i}).valid_values{j})
                                sout = [sout, ', true'];
                            else
                                sout = [sout, ', false'];
                            end
                        else
                            sout = [sout, ', ', char(info.parameters.(param_fields{i}).valid_values{j})];
                        end
                    end
                    fprintf('\t%s\n', ['Valid values: ', sout]);
                else
                    fprintf('\t%s\n', ['Valid values: ', info.parameters.(param_fields{i}).valid_values]);
                end
                fprintf('\t%s\n', ['Description: ', info.parameters.(param_fields{i}).description]);
            end
        else
            disp(['Model ', model, ' has no model-specific parameters.'])
        end
        if(isfield(info, 'notes'))
            disp(['Please note the following additional information:'])
            fprintf('\t%s\n', info.notes);
        end
    else
        disp('Not a valid model specified. Please try again.');
    end
end