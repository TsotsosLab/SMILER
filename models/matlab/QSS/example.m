% Here is an example of how to call the main function, i.e. how to
% use 'spectral_saliency_multichannel'. Furthermore, this file should
% make it easy to visually compare/inspect the saliency maps of different
% algorithms. Have fun.
%
% @author B. Schauerte
% @date   2011-2012

% Copyright 2009-2012 B. Schauerte. All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%    1. Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
% 
%    2. Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the 
%       distribution.
% 
% THIS SOFTWARE IS PROVIDED BY B. SCHAUERTE ''AS IS'' AND ANY EXPRESS OR 
% IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
% DISCLAIMED. IN NO EVENT SHALL B. SCHAUERTE OR CONTRIBUTORS BE LIABLE 
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
% OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
% The views and conclusions contained in the software and documentation
% are those of the authors and should not be interpreted as representing 
% official policies, either expressed or implied, of B. Schauerte.

% Is the QTFM installed and loaded?
% [Umcomment the following lines if you want to automatically set the 
%  QTFM search path and/or download the patched library]
%if exist('qtfm_test','file')
%  % QTFM is loaded ... nothing to do here
%else
%  if exist('qtfm/qtfm_test.m','file')
%    addpath(genpath('qtfm')); % add the qtfm library to the search path
%  else
%    get_additional_files(); % download the missing files
%    addpath(genpath('qtfm')); % add the qtfm library to the search path
%  end
%end

% load the example image
image_filename = 'example-images/golden_retriever.jpg';
image_orig = imread(image_filename);                % load the image
image = im2double(image_orig);                      % @note: you can of course at this point also convert into another color space, e.g. Lab, YUV or ICOPP
%image = imconvert(image_orig,'rgb','labm[0.8 1 1]');% weighted color space

use_colormap = true;                                % @note: I advise the use of colormaps, because they make it much easier to see the differences than grey scale maps

algorithms = {'fft','dct','quat:dct:fast'};         % @note: specify the names of the algorithms whose saliency maps you would like to see

saliency_map_resolution = [48 64];                  % the target saliency map resolution; the most important parameter for spectral saliency approaches
smap_smoothing_filter_params = {'gaussian',9,2.5};  % filter parameters for the final saliency map
cmap_smoothing_filter_params = {};                  % optionally, you can also smooth the conspicuity maps
cmap_normalization = 1;                             % specify the normalization of the conspicuity map here
extended_parameters = {};                           % @note: here you can specify advanced algorithm parameters for the selected algorithm, e.g. the quaternion axis
do_figures = false;                                 % enable/disable spectral_saliency_multichannel's integrated visualizations

subplot_grid={1,numel(algorithms)+1};

figure('name','saliency maps');
subplot(subplot_grid{:},1); imshow(image_orig);
for i=1:numel(algorithms)
    % calculate the saliency map
    saliency_map = spectral_saliency_multichannel(image,saliency_map_resolution,algorithms{i},smap_smoothing_filter_params,cmap_smoothing_filter_params,cmap_normalization,extended_parameters,do_figures);

    % plot the saliency maps
    subplot(subplot_grid{:},i+1);
    imshow(mat2gray(saliency_map)); 
    if use_colormap, colormap(hot); end
    title(algorithms{i});
end
