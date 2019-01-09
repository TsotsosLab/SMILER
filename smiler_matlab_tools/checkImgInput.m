% Verify input image format for SMILER
% Function to indentify the input as either an image filename string, in
% which case the image is loaded and returned, or an image matrix, in which
% case the image is converted to double format and returned.
% Usage: img_out = checkImgInput(img_in, enfrc3)
% **** Input ****
% img_in = An image matrix or a string specifying the path to the image -
% this is assumed to always come in as an RGB image
% color_space = A parameter to specify the colour space which the image
% should be converted to
% enfrc3 = Optional argument to enforce 3 channels.
% **** Output ****
% img_out = an image matrix in double format
% Author: Calden Wloka
function img_out = checkImgInput(img_in, color_space, enfrc3)

if(nargin < 3)
    enfrc3 = false; % default to not checking
end

if(isa(img_in, 'string') || isa(img_in, 'char'))
    % The input is given as a string, so indicates a filename
    img_out = im2double(imread(img_in));
else
    % The input is already in image form; convert to a double image for
    % consistency of format
    img_out = im2double(img_in);
end

% If the color_space is specified as default, then we leave the image
% alone and use the RGB space. It is expected that any model which defaults
% to a non-RGB colour space will detect the default setting inside their
% own wrap function and set the default color_space parameter before
% invoking this function.
if(~strcmp(color_space, 'default'))
    % colour spaces need three channels for the conversion functions
    [~,~,chan] = size(img_out);
    if(chan == 1)
        img_out = repmat(img_out, [1,1,3]);
    end
    if(strcmp(color_space, 'gray'))
        img_out = rgb2gray(img_out);
    elseif(strcmp(color_space, 'YCbCr'))
        img_out = rgb2ycbcr(img_out);
    elseif(strcmp(color_space, 'LAB'))
        img_out = rgb2lab(img_out);
    elseif(strcmp(color_space, 'HSV'))
        img_out = rgb2hsv(img_out);
    elseif(~strcmp(color_space, 'RGB'))
        warning('Custom:parameter_format', 'Unexpected color space specified; using RGB')
    end
end

% some algorithms need three channels, so even when using the default
% colour space we need to replicate single channel gray images to have
% three channels
if(enfrc3)
    [~,~,chan] = size(img_out);
    if(chan == 1)
        img_out = repmat(img_out, [1,1,3]);
    end
end
