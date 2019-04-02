% Common SMILER output formatting
% Internal SMILER function which checks some common output formatting
% parameters for post-processing. This function expects to be called
% by a SMILER wrapper function, and therefore expects that parameter
% structures will have the appropriate fields.
% Author: Calden Wloka
function salmap = fmtOutput(salmap, params)

%% Smoothing
% If do_smoothing is set to a custom or proportional kernel, then it needs
% to be applied
if(strcmp(params.do_smoothing, 'custom'))
    gkern = fspecial('gaussian', params.smooth_size, params.smooth_std);
elseif(strcmp(params.do_smoothing, 'proportional'))
    % set the proportional smoothing size parameter
    ksp = params.smooth_prop*max(size(salmap));
    gkern = fspecial('gaussian', 3*ksp, ksp);
end

if(strcmp(params.do_smoothing, 'custom') || strcmp(params.do_smoothing, 'proportional'))
    salmap = imfilter(salmap,gkern);
end

%% Centre Bias
% Create the Gaussian central prior if needed
if(strcmp(params.center_prior, 'proportional_add') || strcmp(params.center_prior, 'proportional_mult'))
    if(params.center_prior_scale_first)
        min_val = min(salmap(:)); % get the global minimum of the saliency map
        max_val = max(salmap(:)); % get the global maximum of the saliency map

        % linearly rescale to be between 0 and 1
        salmap = ((1/(max_val - min_val))*(salmap - min_val));
    end

    [w,h] = size(salmap);
    sigma = params.center_prior_prop*[w,h];

    if(mod(w,2) == 0)
        xw = -w/2:(w/2)-1;
    else
        xw = ceil(-w/2):floor(w/2);
    end

    if(mod(h,2) == 0)
        xh = -h/2:(h/2)-1;
    else
        xh = ceil(-h/2):floor(h/2);
    end

    g_xw = normpdf(xw,0,sigma(1));
    g_xh = normpdf(xh,0,sigma(2));
    cpmap = g_xw'*g_xh;
end

% Now combine the prior with the saliency map
if(strcmp(params.center_prior, 'proportional_add'))
    salmap = (1-params.center_prior_weight)*salmap + params.center_prior_weight*cpmap;
elseif(strcmp(params.center_prior, 'proportional_mult'))
    salmap = (1-params.center_prior_weight)*salmap + params.center_prior_weight*(salmap.*cpmap);
end

%% Scaling
% check if a value scaling method is specified, and if so apply it
if(strcmp(params.scale_output, 'min-max'))
    min_val = min(salmap(:)); % get the global minimum of the saliency map
    max_val = max(salmap(:)); % get the global maximum of the saliency map

    % a and b are just easier to see and type, so switch to those
    a = params.scale_min;
    b = params.scale_max;

    % linearly rescale between the minimum and maximum values
    salmap = (((b-a)/(max_val - min_val))*(salmap - min_val)) + a;
elseif(strcmp(params.scale_output, 'normalized'))
    salmap = reshape(zscore(double(salmap(:))), size(salmap,1), size(salmap,2));
elseif(strcmp(params.scale_output, 'log-density'))
        min_val = min(salmap(:)); % get the global minimum of the saliency map
        max_val = max(salmap(:)); % get the global maximum of the saliency map

        % linearly rescale to be between 0 and 1 - this is to ensure that
        % all values are positive before transforming into a pdf
        salmap = ((1/(max_val - min_val))*(salmap - min_val));

        % transform to a log-space probability density
        salmap = log(salmap / sum(salmap(:)));
end
