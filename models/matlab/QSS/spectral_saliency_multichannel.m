function S=spectral_saliency_multichannel(I,imsize,multichannel_method,smap_smoothing_filter_params,cmap_smoothing_filter_params,cmap_normalization,extended_parameters,do_figures,do_channel_image_mattogrey)
  % SPECTRAL_SALIENCY_MULTICHANNEL provides implementations of several
  %   spectral (FFT,DCT) saliency algorithms for images.
  %
  %   The selected image size (imsize) at which the saliency is calculated 
  %   is the most important parameter. Just try different sizes and you 
  %   will see ...
  %
  %   There are several methods (multichannel_method) to calculate the 
  %   multichannel saliency:
  %
  %   'fft':          by default the same as 'fft:whitening'
  %   'fft:whitening' Uses spectral whitening to calculate the saliency of
  %                   each channel separately and then averages the result.
  %   'fft:residual'  Uses the spectral residual to calculate saliency of 
  %                   each channel separately and then averages the result.
  %   'dct'           Uses DCT-based image signatures to calculate saliency
  %                   of each channel separately and then averages the 
  %                   result.
  %   'quat:fft:pqft': Converts the image into a quaternion-based 
  %                   representation, uses quaternion FFT/IFFT operations.
  %   'quat:fft:eigenpqft': Similar to 'quat:fft', but relies on the use of
  %                   the quaternion eigenaxis and eigenangle for 
  %                   calculation.
  %   'quat:fft:eigensr': The principle of 'fft:residual' transferred to
  %                   'quat:fft:eigenpqft'.
  %   'quat:dct'      Converts the image into a quaternion-based 
  %                   representation, uses quaternion DCT/IDCT operations.
  %   'quat:dct:fast' Same as 'quad:dct', but with a fixed image 
  %                   resolution of 64x48 and uses optimized .mex files for
  %                   faster calculation.
  %   'fft:whitening:multi','fft:residual:multi','quat:dct:multi',
  %   'quat:pqft:multi','quat:fft:eigensr:multi','quat:fft:eigenpqft:multi'
  %                   The multi-scale versions of the above described
  %                   algorithms.
  %   [...]           some others, e.g., Itti-Koch, Achanta, region 
  %                   contrast, and GBVS as a reference
  %   'ldrc'          Locally debiased region contrast saliency
  %                   (run get_additional_files.m to get LDRC)
  %   'ldrccb'        Locally debiased region contrast saliency with
  %                   additional, explicit center bias.
  %                   (run get_additional_files.m to get LDRC/CB)
  % 
  %   Usage examples:
  %   - spectral_saliency_multichannel(imread(..image path...))
  %     or as an example for other color spaces (e.g. ICOPP, Lab, ...)
  %   - spectral_saliency_multichannel(rgb2icopp(imread(..image path...)))
  %   Furthermore, 'example' and 'process_folder' are two usage examples.
  %   The former makes it possible to visualizes the saliency maps of 
  %   different algorithms for a given test image. The latter calculates
  %   and saves the saliency maps for all images in a given folder.
  %
  %   If you use any of this work in scientific research or as part of a
  %   larger software system, you are requested to cite the use in any
  %   related publications or technical documentation. The work is based
  %   upon:
  %
  %       B. Schauerte, and R. Stiefelhagen, "Quaternion-based Spectral 
  %       Saliency Detection for Eye Fixation Prediction," in European 
  %       Conference on Computer Vision (ECCV), 2012
  %
  %       B. Schauerte, and R. Stiefelhagen, "Predicting Human Gaze using 
  %       Quaternion DCT Image Signature Saliency and Face Detection," in
  %       IEEE Workshop on Applications of Computer Vision (WACV), 2012.
  %
  %   Notes:
  %   - The implementation of the quaternion-based approach requires the
  %     quaternion toolbox (QTFM) for Matlab.
  %   - I kept the implementations as focused and simple as possible and
  %     thus they lack more advanced functionality, e.g. more complex
  %     normalizations. However, I think that the provided functionality is
  %     more than sufficient for (a) people who want to get started in the
  %     field of visual attention (especially students), (b) practitioners
  %     who have heard about the spectral approach and want to try it, and
  %     (c) people who just need a fast, reliable, well-established visual
  %     saliency algorithm (with a simple interface and not too many
  %     parameters) for their applications.
  %   - GBVS and Itti require the original GBVS Matlab implementation by
  %     J. Harel (see http://www.klab.caltech.edu/~harel/share/gbvs.php)
  %
  %   Installation trouble?
  %   - Please read the README.txt, if you have any trouble to set up the
  %     package 
  %
  %   For more details on the method see:
  %   [1] X. Hou and L. Zhang, "Saliency Detection: A Spectral Residual
  %       Approach", in CVPR, 2007.
  %       (original paper)
  %   [2] C. Guo, Q. Ma, and L. Zhang, "Spatio-temporal saliency detection
  %       using phase spectrum of quaternion fourier transform," in CVPR, 
  %       2008.
  %       (extension to quaternions; importance of the residual)
  %   [3] X. Hou, J. Harel, and C. Koch, "Image Signature: Highlighting 
  %       sparse salient regions," in PAMI, 2011.
  %       (uses DCT-based "image signatures")
  %   [4] B. Schauerte, and R. Stiefelhagen, "Predicting Human Gaze using 
  %       Quaternion DCT Image Signature Saliency and Face Detection," in 
  %       IEEE Workshop on Applications of Computer Vision (WACV) / IEEE 
  %       Winter Vision Meetings, 2012.
  %       (extension to quaternions; spectral saliency and face detection;
  %        evaluation of spectral saliency approaches on eye-tracking data;
  %        achieved the currently best reported results on the CERF/FIFA
  %        eye-tracking data set and Toronto/Bruce-Tsotsos data set)
  %   [5] B. Schauerte, and R. Stiefelhagen, "Quaternion-based Spectral
  %       Saliency Detection for Eye Fixation Prediction," in European 
  %       Conference on Computer Vision (ECCV), 2012
  %       (integration and evaluation of DCT- and FFT-based spectral saliency
  %        detection, quaternion component weights, and the use of multiple
  %        scales; also introduces EigenPQFT and EigenSR; evaluated on the
  %        Bruce-Tsotsos (Toronto), Judd (MIT), and Kootstra-Schomacker 
  %        eye-tracking data sets)
  %
  %   It has been applied quite a lot during the last years, e.g., see:
  %   [6] B. Schauerte, B. Kuehn, K. Kroschel, R. Stiefelhagen, "Multimodal 
  %       Saliency-based Attention for Object-based Scene Analysis," in 
  %       IROS, 2011.
  %       ("simple" multi-channel and quaternion-based; Isophote-based
  %        saliency map segmentation)
  %   [7] B. Schauerte, J. Richarz, G. A. Fink,"Saliency-based 
  %       Identification and Recognition of Pointed-at Objects," in IROS,
  %       2010.
  %       (uses multi-channel on intensity, blue-yellow/red-green opponent)
  %   [8] B. Schauerte, G. A. Fink, "Focusing Computational Visual 
  %       Attention in Multi-Modal Human-Robot Interaction," in Proc. ICMI,
  %       2010
  %       (extended to a multi-scale and neuron-based approach that allows
  %        to incorporate information about the visual search target)
  %
  %   However, the underlying principle has been addressed long before:
  %   [9] A. Oppenheim and J. Lim, "The importance of phase in signals,"
  %       in Proc. IEEE, vol. 69, pp. 529-541, 1981.
  % 
  % @author: B. Schauerte
  % @date:   2009-2012
  % @url:    http://cvhci.anthropomatik.kit.edu/~bschauer/
  
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

  %if nargin<2, imsize=1; end % use original image size
  if nargin<2, imsize=[NaN 64]; end
  if nargin<3, multichannel_method='fft'; end
  %if nargin<4, smap_smoothing_filter_params={'anigauss',2.5}; end
  if nargin<4, smap_smoothing_filter_params={'gaussian',9,2.5}; end
  if nargin<5, cmap_smoothing_filter_params={}; end
  if nargin<6, cmap_normalization=1; end
  if nargin<7, extended_parameters={}; end
  if nargin<8, do_figures=false; end
  if nargin<9, do_channel_image_mattogrey=true; end
  
  do_force_double_image_type=false; % force the image to have type double (this is problematic, e.g., for the results of DCT Image Signatures for RGB on the Bruce-Tsotsos data set)
  
  if ~isfloat(I) && do_force_double_image_type
    I=im2double(I);
  end
  imorigsize=size(I);
  IR=imresize(I, imsize, 'bicubic'); % @note: the resizing method has an influence on the results, take care!
  
  nchannels=size(IR,3);
  channel_saliency=zeros(size(IR));
  channel_saliency_smoothed=zeros(size(IR));
  
  switch multichannel_method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (Quaternion) Fourier Transform (FFT/QFT)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % ====================================================================
    % Spectral Whitening - "simple" single-channel and averaging
    % ====================================================================
    case {'fft','fft:whitening','fft:residual'}
      channel_phase=zeros(size(IR));
      channel_magnitude=zeros(size(IR));
      
      residual_filter_length=0;   % don't use the residual (whitening)
      if strcmp(multichannel_method,'fft:residual')
        if ~isempty(extended_parameters)
          if isstruct(extended_parameters)
            residual_filter_length=3; % use the spectral residual (default value)
            if isfield(extended_parameters,'residual_filter_length'), residual_filter_length = extended_parameters.residual_filter_length; end  
          end
          if iscell(extended_parameters)
            residual_filter_length=extended_parameters{1};
          end
        else
          residual_filter_length=3; % use the spectral residual (default value)
        end
      end
      
      % calculate "saliency" for each channel
      for i=1:1:nchannels
        % calculate the channel saliency / conspicuity map
        [channel_saliency(:,:,i),channel_phase(:,:,i),channel_magnitude(:,:,i)]=spectral_saliency(IR(:,:,i),residual_filter_length);
        
        % filter the conspicuity maps
        if ~isempty(cmap_smoothing_filter_params)
          channel_saliency_smoothed(:,:,i)=imfilter(channel_saliency(:,:,i), fspecial(cmap_smoothing_filter_params{:}));
        else
          channel_saliency_smoothed(:,:,i)=channel_saliency(:,:,i);
        end
        
        % normalize the conspicuity maps
        switch cmap_normalization % simple (range) normalization
          case {1}
            % simply normalize the value range
            cmin=min(channel_saliency_smoothed(:));
            cmax=max(channel_saliency_smoothed(:));
            if (cmin - cmax) > 0
              channel_saliency_smoothed=(channel_saliency_smoothed - cmin) / (cmax - cmin);
            end

          case {0}
            % do nothing
            
          otherwise
            error('unsupported normalization')
        end
      end
          
      % uniform linear combination of the channels
      
      S=mean(channel_saliency_smoothed,3);
      
      % filter the saliency map
      if ~isempty(smap_smoothing_filter_params)
        if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
          S=anigauss(S,smap_smoothing_filter_params{2});
        else
          S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
        end
      end
          
      if do_figures
        figure('name','Saliency / Channel');
        for i=1:1:nchannels
          subplot(4,nchannels,0*nchannels+i);
          if do_channel_image_mattogrey
            subimage(mat2gray(IR(:,:,i))); 
          else
            subimage(IR(:,:,i));
          end
          title(['Channel ' int2str(i)]);
        end
        for i=1:1:nchannels
          subplot(4,nchannels,1*nchannels+i);
          subimage(mat2gray(channel_saliency_smoothed(:,:,i))); 
          title(['Channel ' int2str(i) ' Saliency']);
        end
        for i=1:1:nchannels
          subplot(4,nchannels,2*nchannels+i);
          subimage(mat2gray(channel_phase(:,:,i))); 
          title(['Channel ' int2str(i) ' Phase']);
        end
        for i=1:1:nchannels
          subplot(4,nchannels,3*nchannels+i);
          subimage(mat2gray(channel_magnitude(:,:,i))); 
          title(['Channel ' int2str(i) ' Magnitude']);
        end
      end

    % ====================================================================
    % Multiscale PFT
    % ====================================================================
    case {'fft:pft:multi','pft:multi', ...
          'fft:whitening:multi','pft:whitening:multi', ...
          'fft:residual:multi','residual:multi', ...
          'fft:pft:multi:debug'} 
      % 
      % 
            
      % set default values
      % - multiscale
      do_range_normalization = true; 
      do_downscaling = false; % downscaling vs. upscaling
      do_separate_scale_filtering = false;
      nscales=2;
      scale_factor=1.2; %sqrt(2);
      % - PQFT
      weights = [];
      residual_filter = 3; %fspecial('average',3);
      % set user specified parameters
      if ~isempty(extended_parameters)
        % - multiscale
        if isfield(extended_parameters,'do_range_normalization'), do_range_normalization = extended_parameters.do_range_normalization; end
        if isfield(extended_parameters,'do_downscaling'), do_downscaling = extended_parameters.do_downscaling; end
        if isfield(extended_parameters,'do_separate_scale_filtering'), do_separate_scale_filtering = extended_parameters.do_separate_scale_filtering; end
        if isfield(extended_parameters,'nscales'), nscales = extended_parameters.nscales; end
        if isfield(extended_parameters,'scale_factor'), scale_factor = extended_parameters.scale_factor; end
        % - PQFT
        if isfield(extended_parameters,'weights'), weights = extended_parameters.weights; end
        if isfield(extended_parameters,'residual_filter'), h = extended_parameters.residual_filter; end                            % specify the filter
        if isfield(extended_parameters,'residual_filter_params'), residual_filter = fspecial(extended_parameters.residual_filter_params{:}); end % specify the filter using fspecial parameters
      end
      
      tresolution=[size(IR,1) size(IR,2)];
      nchannels=size(IR,3);
      
      channel_saliency=zeros([tresolution nchannels]);
      channel_saliency_smoothed=zeros([tresolution nchannels]);

      assert(nscales >= 1);
      
      resolutions=cell(1,nscales);
      resolutions{1}=tresolution;
      for r=2:nscales
        if do_downscaling
          resolutions{r}=resolutions{r-1}/scale_factor;
        else
          resolutions{r}=resolutions{r-1}*scale_factor;
        end
      end
      S=zeros([tresolution numel(resolutions)]);
      for r=1:numel(resolutions)
        % calculate "saliency" for each channel
        for i=1:1:nchannels
          % calculate the channel saliency / conspicuity map
          IX=imresize(I,resolutions{r},'bicubic');
          channel_saliency(:,:,i)=imresize(spectral_saliency(imresize(IX(:,:,i),resolutions{r},'bicubic'),residual_filter),tresolution,'bicubic');
          
          % filter the conspicuity maps
          if ~isempty(cmap_smoothing_filter_params)
            channel_saliency_smoothed(:,:,i)=imfilter(channel_saliency(:,:,i), fspecial(cmap_smoothing_filter_params{:}));
          else
            channel_saliency_smoothed(:,:,i)=channel_saliency(:,:,i);
          end

          % normalize the conspicuity maps
          switch cmap_normalization % simple (range) normalization
            case {1}
              % simply normalize the value range
              cmin=min(channel_saliency_smoothed(:));
              cmax=max(channel_saliency_smoothed(:));
              if (cmin - cmax) > 0
                channel_saliency_smoothed=(channel_saliency_smoothed - cmin) / (cmax - cmin);
              end

            case {0}
              % do nothing

            otherwise
              error('unsupported normalization')
          end
        end

        % uniform linear combination of the channels
        S(:,:,r)=mean(channel_saliency_smoothed,3);

        % use a different filter size for each scale (derived from the size of the filter on the target scale)
        if do_separate_scale_filtering
          if ~isempty(smap_smoothing_filter_params)
            if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
              relative_sigma = smap_smoothing_filter_params{2} / tresolution(2);
              resolution = resolutions{r};
              
              S(:,:,r)=anigauss(S(:,:,r),relative_sigma*resolution(2));
            else
              relative_sigma = smap_smoothing_filter_params{3} / tresolution(2);
              resolution = resolutions{r};
              tmp_smoothing_filter_params = smap_smoothing_filter_params;
              tmp_smoothing_filter_params{3} = relative_sigma*resolution(2);
              
              S(:,:,r)=imfilter(S(:,:,r), fspecial(tmp_smoothing_filter_params{:}));
            end
          end
        end
        
        % normalize the range of each map to [0,1]
        if do_range_normalization
          S(:,:,r)=mat2gray(S(:,:,r));
        end
      end
      S=sum(S,3);
      %toc
      
      if ~do_separate_scale_filtering
        if ~isempty(smap_smoothing_filter_params)
          if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
            S=anigauss(S,smap_smoothing_filter_params{2});
          else
            S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
          end
        end
      end

    % ====================================================================
    % PQFT - quaternion-based spectral whitening
    % ====================================================================
    case {'quat:fft:pqft','quaternion:fft:pqft', ...
          'quat:pqft','quaternion:pqft'}
      if isempty(extended_parameters)
        [S,FQIR,IFQIR]=spectral_saliency_quaternion(IR);
      end
      if iscell(extended_parameters)
        [S,FQIR,IFQIR]=spectral_saliency_quaternion(IR,extended_parameters{:});
      end
      if isstruct(extended_parameters)
        % set default values
        absexp = 2;
        fftaxis = unit(quaternion(-1,-1,-1));
        % set user specified parameters
        if isfield(extended_parameters,'absexp'), absexp = extended_parameters.absexp; end             % abs. exponent
        if isfield(extended_parameters,'fftaxis'), fftaxis = extended_parameters.fftaxis; end          % Fourier transform axis
        [S,FQIR,IFQIR]=spectral_saliency_quaternion(IR,absexp,fftaxis);
      end
      
      if ~isempty(smap_smoothing_filter_params)
        if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
          S=anigauss(S,smap_smoothing_filter_params{2});
        else
          S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
        end
      end
      
      if do_figures
        visualize_quaternion_image(FQIR);
        visualize_quaternion_image(IFQIR);
      end

    % ====================================================================
    % Multiscale PQFT
    % ====================================================================
    case {'quat:fft:pqft:multi','quaternion:fft:pqft:multi', ...
          'quat:pqft:multi','quaternion:pqft:multi'} 
      % 
      % 
      
      % set default values
      % - multiscale
      do_range_normalization = true; 
      do_downscaling = false; % downscaling vs. upscaling
      do_separate_scale_filtering = false;
      nscales=2;
      scale_factor=1.2; %sqrt(2);
      % - PQFT
      absexp = 2;
      fftaxis = unit(quaternion(-1,-1,-1));
      % set user specified parameters
      if ~isempty(extended_parameters)
        % - multiscale
        if isfield(extended_parameters,'do_range_normalization'), do_range_normalization = extended_parameters.do_range_normalization; end
        if isfield(extended_parameters,'do_downscaling'), do_downscaling = extended_parameters.do_downscaling; end
        if isfield(extended_parameters,'do_separate_scale_filtering'), do_separate_scale_filtering = extended_parameters.do_separate_scale_filtering; end
        if isfield(extended_parameters,'nscales'), nscales = extended_parameters.nscales; end
        if isfield(extended_parameters,'scale_factor'), scale_factor = extended_parameters.scale_factor; end
        % - PQFT
        if isfield(extended_parameters,'absexp'), absexp = extended_parameters.absexp; end
        if isfield(extended_parameters,'fftaxis'), fftaxis = extended_parameters.fftaxis; end
      end
      
      tresolution=[size(IR,1) size(IR,2)];

      assert(nscales >= 1);
      
      resolutions=cell(1,nscales);
      resolutions{1}=tresolution;
      for r=2:nscales
        if do_downscaling
          resolutions{r}=resolutions{r-1}/scale_factor;
        else
          resolutions{r}=resolutions{r-1}*scale_factor;
        end
      end
      S=zeros([tresolution numel(resolutions)]);
      for r=1:numel(resolutions)
        % normalize the range of the saliency maps
        S(:,:,r)=imresize(spectral_saliency_quaternion(imresize(I,resolutions{r},'bicubic'),absexp,fftaxis),tresolution,'bicubic');
        
        % use a different filter size for each scale (derived from the size of the filter on the target scale)
        if do_separate_scale_filtering
          if ~isempty(smap_smoothing_filter_params)
            if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
              relative_sigma = smap_smoothing_filter_params{2} / tresolution(2);
              resolution = resolutions{r};
              
              S(:,:,r)=anigauss(S(:,:,r),relative_sigma*resolution(2));
            else
              relative_sigma = smap_smoothing_filter_params{3} / tresolution(2);
              resolution = resolutions{r};
              tmp_smoothing_filter_params = smap_smoothing_filter_params;
              tmp_smoothing_filter_params{3} = relative_sigma*resolution(2);
              
              S(:,:,r)=imfilter(S(:,:,r), fspecial(tmp_smoothing_filter_params{:}));
            end
          end
        end
        
        % normalize the range of each map to [0,1]
        if do_range_normalization
          S(:,:,r)=mat2gray(S(:,:,r));
        end
      end
      S=sum(S,3);
      %toc
      
      if ~do_separate_scale_filtering
        if ~isempty(smap_smoothing_filter_params)
          if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
            S=anigauss(S,smap_smoothing_filter_params{2});
          else
            S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
          end
        end
      end

    % ====================================================================
    % Quaternion FFT with Spectral Residual and Eigenaxis (EigenSR)
    % ====================================================================
    case {'quat:fft:eigensr','quaternion:fft:eigensr', ...
          'quat:eigensr','quaternion:eigensr'}
      if isempty(extended_parameters)
        [S,FQIR,IFQIR]=spectral_saliency_quaternion_eigensr(IR);
      end
      if iscell(extended_parameters)
        [S,FQIR,IFQIR]=spectral_saliency_quaternion_eigensr(IR,extended_parameters{:});
      end
      if isstruct(extended_parameters)
        % set default values
        absexp = 2;
        fftaxis = unit(quaternion(-1,-1,-1));
        L = 'L';
        h = fspecial('average', 3);
        % set user specified parameters
        if isfield(extended_parameters,'absexp'), absexp = extended_parameters.absexp; end             % abs. exponent
        if isfield(extended_parameters,'fftaxis'), fftaxis = extended_parameters.fftaxis; end          % Fourier transform axis
        if isfield(extended_parameters,'L'), L = extended_parameters.L; end                            % left- or right-sided quaterion Fourier transform
        if isfield(extended_parameters,'h'), h = extended_parameters.h; end                            % specify the filter
        if isfield(extended_parameters,'h_params'), h = fspecial(extended_parameters.h_params{:}); end % specify the filter using fspecial parameters
        [S,FQIR,IFQIR]=spectral_saliency_quaternion_eigensr(IR,absexp,fftaxis,L,h);
      end  
      
      if ~isempty(smap_smoothing_filter_params)
        if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
          S=anigauss(S,smap_smoothing_filter_params{2});
        else
          S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
        end
      end
      
      if do_figures
        visualize_quaternion_image(FQIR);
        visualize_quaternion_image(IFQIR);
      end

    % ====================================================================
    % Multiscale EigenSR
    % ====================================================================
    case {'quat:fft:eigensr:multi','quaternion:fft:eigensr:multi', ...
          'quat:eigensr:multi','quaternion:eigensr:multi'} 
      % 
      % 
      
      % set default values
      % - multiscale
      do_range_normalization = true; 
      do_downscaling = false; % downscaling vs. upscaling
      do_separate_scale_filtering = false;
      nscales=2;
      scale_factor=1.2; %sqrt(2);
      % - EigenSR
      absexp = 2;
      fftaxis = unit(quaternion(-1,-1,-1));
      L = 'L';
      h = fspecial('average', 3);
      % set user specified parameters
      if ~isempty(extended_parameters)
        % - multiscale
        if isfield(extended_parameters,'do_range_normalization'), do_range_normalization = extended_parameters.do_range_normalization; end
        if isfield(extended_parameters,'do_downscaling'), do_downscaling = extended_parameters.do_downscaling; end
        if isfield(extended_parameters,'do_separate_scale_filtering'), do_separate_scale_filtering = extended_parameters.do_separate_scale_filtering; end
        if isfield(extended_parameters,'nscales'), nscales = extended_parameters.nscales; end
        if isfield(extended_parameters,'scale_factor'), scale_factor = extended_parameters.scale_factor; end
        % - PQFT
        if isfield(extended_parameters,'absexp'), absexp = extended_parameters.absexp; end
        if isfield(extended_parameters,'fftaxis'), fftaxis = extended_parameters.fftaxis; end
        if isfield(extended_parameters,'L'), L = extended_parameters.L; end                            % left- or right-sided quaterion Fourier transform
        if isfield(extended_parameters,'h'), h = extended_parameters.h; end                            % specify the filter
        if isfield(extended_parameters,'h_params'), h = fspecial(extended_parameters.h_params{:}); end % specify the filter using fspecial parameters
      end
      
      tresolution=[size(IR,1) size(IR,2)];

      assert(nscales >= 1);
      
      resolutions=cell(1,nscales);
      resolutions{1}=tresolution;
      for r=2:nscales
        if do_downscaling
          resolutions{r}=resolutions{r-1}/scale_factor;
        else
          resolutions{r}=resolutions{r-1}*scale_factor;
        end
      end
      S=zeros([tresolution numel(resolutions)]);
      for r=1:numel(resolutions)
        % normalize the range of the saliency maps
        S(:,:,r)=imresize(spectral_saliency_quaternion_eigensr(imresize(I,resolutions{r},'bicubic'),absexp,fftaxis,L,h),tresolution,'bicubic');
        
        % use a different filter size for each scale (derived from the size of the filter on the target scale)
        if do_separate_scale_filtering
          if ~isempty(smap_smoothing_filter_params)
            if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
              relative_sigma = smap_smoothing_filter_params{2} / tresolution(2);
              resolution = resolutions{r};
              
              S(:,:,r)=anigauss(S(:,:,r),relative_sigma*resolution(2));
            else
              relative_sigma = smap_smoothing_filter_params{3} / tresolution(2);
              resolution = resolutions{r};
              tmp_smoothing_filter_params = smap_smoothing_filter_params;
              tmp_smoothing_filter_params{3} = relative_sigma*resolution(2);
              
              S(:,:,r)=imfilter(S(:,:,r), fspecial(tmp_smoothing_filter_params{:}));
            end
          end
        end
        
        % normalize the range of each map to [0,1]
        if do_range_normalization
          S(:,:,r)=mat2gray(S(:,:,r));
        end
      end
      S=sum(S,3);
      %toc
      
      if ~do_separate_scale_filtering
        if ~isempty(smap_smoothing_filter_params)
          if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
            S=anigauss(S,smap_smoothing_filter_params{2});
          else
            S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
          end
        end
      end

    % ====================================================================
    % Quaternion FFT w/o Spectral Residual, but with Eigenaxis (EigenPQFT)
    % ====================================================================
    case {'quat:fft:eigenpqft','quaternion:fft:eigenpqft', ...
          'quat:eigenpqft','quaternion:eigenpqft'}
      if isempty(extended_parameters)
        [S,FQIR,IFQIR]=spectral_saliency_quaternion_eigenpqft(IR);
      end
      if iscell(extended_parameters)
        [S,FQIR,IFQIR]=spectral_saliency_quaternion_eigenpqft(IR,extended_parameters{:});
      end
      if isstruct(extended_parameters)
        % set default values
        absexp = 2;
        fftaxis = unit(quaternion(-1,-1,-1));
        L = 'L';
        % set user specified parameters
        if isfield(extended_parameters,'absexp'), absexp = extended_parameters.absexp; end
        if isfield(extended_parameters,'fftaxis'), fftaxis = extended_parameters.fftaxis; end
        if isfield(extended_parameters,'L'), L = extended_parameters.L; end
        [S,FQIR,IFQIR]=spectral_saliency_quaternion_eigenpqft(IR,absexp,fftaxis,L);
      end          
      
      if ~isempty(smap_smoothing_filter_params)
        if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
          S=anigauss(S,smap_smoothing_filter_params{2});
        else
          S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
        end
      end
      
      if do_figures
        visualize_quaternion_image(FQIR);
        visualize_quaternion_image(IFQIR);
      end

    % ====================================================================
    % Multiscale EigenPQFT
    % ====================================================================
    case {'quat:fft:eigenpqft:multi','quaternion:fft:eigenpqft:multi', ...
          'quat:eigenpqft:multi','quaternion:eigenpqft:multi'} 
      % 
      % 
      
      % set default values
      % - multiscale
      do_range_normalization = true; 
      do_downscaling = false; % downscaling vs. upscaling
      do_separate_scale_filtering = false;
      nscales=2;
      scale_factor=1.2; %sqrt(2);
      % - EigenPQFT
      absexp = 2;
      fftaxis = unit(quaternion(-1,-1,-1));
      L = 'L';
      % set user specified parameters
      if ~isempty(extended_parameters)
        % - multiscale
        if isfield(extended_parameters,'do_range_normalization'), do_range_normalization = extended_parameters.do_range_normalization; end
        if isfield(extended_parameters,'do_downscaling'), do_downscaling = extended_parameters.do_downscaling; end
        if isfield(extended_parameters,'do_separate_scale_filtering'), do_separate_scale_filtering = extended_parameters.do_separate_scale_filtering; end
        if isfield(extended_parameters,'nscales'), nscales = extended_parameters.nscales; end
        if isfield(extended_parameters,'scale_factor'), scale_factor = extended_parameters.scale_factor; end
        % - EigenPQFT
        if isfield(extended_parameters,'absexp'), absexp = extended_parameters.absexp; end
        if isfield(extended_parameters,'fftaxis'), fftaxis = extended_parameters.fftaxis; end
        if isfield(extended_parameters,'L'), L = extended_parameters.L; end
      end
      
      tresolution=[size(IR,1) size(IR,2)];

      assert(nscales >= 1);
      
      resolutions=cell(1,nscales);
      resolutions{1}=tresolution;
      for r=2:nscales
        if do_downscaling
          resolutions{r}=resolutions{r-1}/scale_factor;
        else
          resolutions{r}=resolutions{r-1}*scale_factor;
        end
      end
      S=zeros([tresolution numel(resolutions)]);
      for r=1:numel(resolutions)
        % normalize the range of the saliency maps
        S(:,:,r)=imresize(spectral_saliency_quaternion_eigenpqft(imresize(I,resolutions{r},'bicubic'),absexp,fftaxis,L),tresolution,'bicubic');
        
        % use a different filter size for each scale (derived from the size of the filter on the target scale)
        if do_separate_scale_filtering
          if ~isempty(smap_smoothing_filter_params)
            if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
              relative_sigma = smap_smoothing_filter_params{2} / tresolution(2);
              resolution = resolutions{r};
              
              S(:,:,r)=anigauss(S(:,:,r),relative_sigma*resolution(2));
            else
              relative_sigma = smap_smoothing_filter_params{3} / tresolution(2);
              resolution = resolutions{r};
              tmp_smoothing_filter_params = smap_smoothing_filter_params;
              tmp_smoothing_filter_params{3} = relative_sigma*resolution(2);
              
              S(:,:,r)=imfilter(S(:,:,r), fspecial(tmp_smoothing_filter_params{:}));
            end
          end
        end
        
        % normalize the range of each map to [0,1]
        if do_range_normalization
          S(:,:,r)=mat2gray(S(:,:,r));
        end
      end
      S=sum(S,3);
      %toc
      
      if ~do_separate_scale_filtering
        if ~isempty(smap_smoothing_filter_params)
          if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
            S=anigauss(S,smap_smoothing_filter_params{2});
          else
            S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
          end
        end
      end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (Quaternion) Discrete Cosine Transform ((Q)DCT)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % ====================================================================
    % DCT Image Signatures - "simple" single-channel and averaging
    % ====================================================================
    case {'dct'}
      channel_isi=zeros(size(IR));
      channel_di=zeros(size(IR));
      
      % calculate "saliency" for each channel
      for i=1:1:nchannels
        % calculate the channel ssaliency / conspicuity map
        [channel_saliency(:,:,i),channel_isi(:,:,i),channel_di(:,:,i)]=spectral_dct_saliency(IR(:,:,i));
        
        % filter the conspicuity maps
        if ~isempty(cmap_smoothing_filter_params)
          channel_saliency_smoothed(:,:,i)=imfilter(channel_saliency(:,:,i), fspecial(cmap_smoothing_filter_params{:})); % @note: smooth each channel vs. smooth the aggregated/summed map
        else
          channel_saliency_smoothed(:,:,i)=channel_saliency(:,:,i);
        end
        
        % normalize the conspicuity maps
        switch cmap_normalization % simple (range) normalization
          case {1}
            % simply normalize the value range
            cmin=min(channel_saliency_smoothed(:));
            cmax=max(channel_saliency_smoothed(:));
            if (cmin - cmax) > 0
              channel_saliency_smoothed=(channel_saliency_smoothed - cmin) / (cmax - cmin);
            end

          case {0}
            % do nothing
            
          otherwise
            error('unsupported normalization')
        end
      end
          
      % uniform linear combination of the channels
      S=mean(channel_saliency_smoothed,3);
      
      % filter the saliency map
      if ~isempty(smap_smoothing_filter_params)
        if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
          S=anigauss(S,smap_smoothing_filter_params{2});
        else
          S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
        end
      end
          
      if do_figures
        figure('name','Saliency / Channel');
        for i=1:1:nchannels
          subplot(4,nchannels,0*nchannels+i);
          if do_channel_image_mattogrey
            subimage(mat2gray(IR(:,:,i))); 
          else
            subimage(IR(:,:,i));
          end
          title(['Channel ' int2str(i)]);
        end
        for i=1:1:nchannels
          subplot(4,nchannels,1*nchannels+i);
          subimage(mat2gray(channel_saliency_smoothed(:,:,i))); 
          title(['Channel ' int2str(i) ' Saliency']);
        end
        for i=1:1:nchannels
          subplot(4,nchannels,2*nchannels+i);
          subimage(mat2gray(channel_isi(:,:,i))); 
          title(['Channel ' int2str(i) ' Image Signature']);
        end
        for i=1:1:nchannels
          subplot(4,nchannels,3*nchannels+i);
          subimage(mat2gray(channel_di(:,:,i))); 
          title(['Channel ' int2str(i) ' DCT']);
        end
      end

    % ====================================================================
    % Quaternion-based DCT image signatures (QDCT)
    % ====================================================================
    case {'quat:dct','quaternion:dct'}
      if isempty(extended_parameters)
        [S,DCTIR,IDCTIR]=spectral_dct_saliency_quaternion(IR);
      end
      if iscell(extended_parameters)
        [S,DCTIR,IDCTIR]=spectral_dct_saliency_quaternion(IR,extended_parameters{:});
      end
      if isstruct(extended_parameters)
        % set default values
        absexp = 2;
        dctaxis = unit(quaternion(-1,-1,-1));
        L = 'L';
        % set user specified parameters
        if isfield(extended_parameters,'absexp'), absexp = extended_parameters.absexp; end
        if isfield(extended_parameters,'dctaxis'), dctaxis = extended_parameters.dctaxis; end
        if isfield(extended_parameters,'L'), L = extended_parameters.L; end
        [S,DCTIR,IDCTIR]=spectral_dct_saliency_quaternion(IR,absexp,dctaxis,L);
      end
      if ~isempty(smap_smoothing_filter_params)
        if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
          S=anigauss(S,smap_smoothing_filter_params{2});
        else
          S=imfilter(S,fspecial(smap_smoothing_filter_params{:}));
        end
      end

      if do_figures
        visualize_quaternion_image(sign(DCTIR));
        visualize_quaternion_image(IDCTIR);
      end

    % ====================================================================
    % Multi-scale quaternion-based DCT image signatures
    % ====================================================================
    case {'quat:dct:multi','quaternion:dct:multi'} 
      % 
      % 
      
      % set default values
      % - multiscale
      do_range_normalization = true; 
      do_downscaling = false; % downscaling vs. upscaling
      do_separate_scale_filtering = false;
      nscales=2;
      scale_factor=1.2; %sqrt(2);
      % - QDCT
      absexp=2;
      dctaxis=unit(quaternion(-1,-1,-1));
      L='L';
      do_normalize=false;
      % set user specified parameters
      if ~isempty(extended_parameters)
        % - multiscale
        if isfield(extended_parameters,'do_range_normalization'), do_range_normalization = extended_parameters.do_range_normalization; end
        if isfield(extended_parameters,'do_downscaling'), do_downscaling = extended_parameters.do_downscaling; end
        if isfield(extended_parameters,'do_separate_scale_filtering'), do_separate_scale_filtering = extended_parameters.do_separate_scale_filtering; end
        if isfield(extended_parameters,'nscales'), nscales = extended_parameters.nscales; end
        if isfield(extended_parameters,'scale_factor'), scale_factor = extended_parameters.scale_factor; end
        % - QDCT
        if isfield(extended_parameters,'absexp'), absexp = extended_parameters.absexp; end
        if isfield(extended_parameters,'dctaxis'), dctaxis = extended_parameters.dctaxis; end
        if isfield(extended_parameters,'L'), L = extended_parameters.L; end
        if isfield(extended_parameters,'do_normalize'), do_normalize = extended_parameters.do_normalize; end
      end
      
      tresolution=[size(IR,1) size(IR,2)];

      assert(nscales >= 1);
      
      resolutions=cell(1,nscales);
      resolutions{1}=tresolution;
      for r=2:nscales
        if do_downscaling
          resolutions{r}=resolutions{r-1}/scale_factor;
        else
          resolutions{r}=resolutions{r-1}*scale_factor;
        end
      end
      S=zeros([tresolution numel(resolutions)]);
      for r=1:numel(resolutions)
        % normalize the range of the saliency maps
        S(:,:,r)=imresize(spectral_dct_saliency_quaternion(imresize(I,resolutions{r},'bicubic'),absexp,dctaxis,L,do_normalize),tresolution,'bicubic');
        
        % use a different filter size for each scale (derived from the size of the filter on the target scale)
        if do_separate_scale_filtering
          if ~isempty(smap_smoothing_filter_params)
            if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
              relative_sigma = smap_smoothing_filter_params{2} / tresolution(2);
              resolution = resolutions{r};
              
              S(:,:,r)=anigauss(S(:,:,r),relative_sigma*resolution(2));
            else
              relative_sigma = smap_smoothing_filter_params{3} / tresolution(2);
              resolution = resolutions{r};
              tmp_smoothing_filter_params = smap_smoothing_filter_params;
              tmp_smoothing_filter_params{3} = relative_sigma*resolution(2);
              
              S(:,:,r)=imfilter(S(:,:,r), fspecial(tmp_smoothing_filter_params{:}));
            end
          end
        end
        
        % normalize the range of each map to [0,1]
        if do_range_normalization
          S(:,:,r)=mat2gray(S(:,:,r));
        end
      end
      S=sum(S,3);
      %toc
      
      if ~do_separate_scale_filtering
        if ~isempty(smap_smoothing_filter_params)
          if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
            S=anigauss(S,smap_smoothing_filter_params{2});
          else
            S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
          end
        end
      end

    % ====================================================================
    % Quaternion-based DCT image signatures (QDCT)
    % (highly-optimized implementation)
    % ====================================================================
    case {'quat:dct:fast','quaternion:dct:fast'}
      % @note: it is possible that this breaks the anisotropic gauss filter
      %   implementation, because anigauss then is (differently!) in two
      %   locations as .o file
      assert(size(IR,1) == 48 && size(IR,2) == 64);
      
      if ~exist('qdct_saliency_48_64','file')
        addpath(genpath('qdct_impl')); % add the path to the implementation
        if ~exist('qdct_saliency_48_64','file')
          fprintf('Can not find qdct_saliency_48_64 .mex-file. Trying to compile.');
          run('qdct_impl/build.m'); % compile/build the hard-coded interface
        end
        addpath(genpath('qdct_impl')); % add the path to the implementation
        % check for success
        if ~exist('qdct_saliency_48_64','file')
          error('Can not find/build qdct_saliency_48_64');
        end
      end
      
      %tic
      S=qdct_saliency_48_64(IR);
      %toc
      
      if ~isempty(smap_smoothing_filter_params)
        if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
          S=anigauss(S,smap_smoothing_filter_params{2});
        else
          S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
        end
      end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % REFERENCE IMPLEMENTATIONS FOR COMPARISON
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % ====================================================================
    % classic Itti-Koch saliency map (comes with the GBVS package)
    % ====================================================================
    case {'itti'}
      warning('Calculating Itti-Koch saliency maps. Please check that the input color space is RGB!'); % @note: always make sure to use the correct color space with GBVS (i.e., rgb)
      
      %%%
      % Set default parameters
      %%%
      gbvs_params=makeGBVSParams;
      gbvs_params.useIttiKochInsteadOfGBVS=true;
      gbvs_params.blurfrac=0.000; % we do the blurring
      %gbvs_params.ittiblurfrac=0.000; % we do the blurring
      %%%
      % Set user specified parameters
      %%%
      if ~isempty(extended_parameters)
        % general
        if isfield(extended_parameters,'salmapmaxsize'), gbvs_params.salmapmaxsize = extended_parameters.salmapmaxsize; end
        if isfield(extended_parameters,'channels'), gbvs_params.channels = extended_parameters.channels; end
        if isfield(extended_parameters,'blurfrac'), gbvs_params.blurfrac = extended_parameters.blurfrac; end
        % features
        if isfield(extended_parameters,'channels'), gbvs_params.channels = extended_parameters.channels; end
        % itti
        if isfield(extended_parameters,'ittiblurfrac'), gbvs_params.ittiblurfrac = extended_parameters.ittiblurfrac; end
        if isfield(extended_parameters,'activationType'), gbvs_params.activationType = extended_parameters.activationType; end
        if isfield(extended_parameters,'normalizationType'), gbvs_params.normalizationType = extended_parameters.normalizationType; end
        % -- directly set the parameters (OVERRIDES EVERYTHING)
        if isfield(extended_parameters,'gbvs_params'), gbvs_params = extended_parameters.gbvs_params; end
        gbvs_params.useIttiKochInsteadOfGBVS=true;
      end
      
      S=getfield(gbvs(I,gbvs_params),'master_map');
      %S=getfield(ittikochmap(I),'master_map');
      S=imresize(S,imsize);
      if ~isempty(smap_smoothing_filter_params)
        if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
          S=anigauss(S,smap_smoothing_filter_params{2});
        else
          S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
        end
      end

    % ====================================================================
    % Graph-based Visual Saliency (GBVS)
    % ====================================================================
    case {'gbvs'}
      warning('Calculating GBVS saliency maps. Please check that the input color space is RGB!'); % @note: always make sure to use the correct color space with GBVS (i.e., rgb)
      
      %%%
      % Set default parameters
      %%%
      gbvs_params=makeGBVSParams; % create default GBVS parameters
      gbvs_params.salmapmaxsize = 48; % you can get better results with higher values (e.g., 60), but it gets really slow!
      %gbvs_params.channels      = 'DIOR';
      gbvs_params.channels      = 'DIO';
      %gbvs_params.blurfrac      = 0.000; % we do the blurring afterwards
      gbvs_params.levels        = [2 3 4]; 
      %gbvs_params.cyclic_type   = 1; % important to set this when calculating/evaluating center-bias corrected AUCs
      %%%
      % Set user specified parameters
      %%%
      if ~isempty(extended_parameters)
        % general
        if isfield(extended_parameters,'salmapmaxsize'), gbvs_params.salmapmaxsize = extended_parameters.salmapmaxsize; end
        if isfield(extended_parameters,'channels'), gbvs_params.channels = extended_parameters.channels; end
        if isfield(extended_parameters,'blurfrac'), gbvs_params.blurfrac = extended_parameters.blurfrac; end
        % features
        if isfield(extended_parameters,'channels'), gbvs_params.channels = extended_parameters.channels; end
        % gbvs
        if isfield(extended_parameters,'levels'), gbvs_params.levels = extended_parameters.levels; end
        if isfield(extended_parameters,'cyclic_type'), gbvs_params.cyclic_type = extended_parameters.cyclic_type; end
        % -- directly set the parameters (OVERRIDES EVERYTHING)
        if isfield(extended_parameters,'gbvs_params'), gbvs_params = extended_parameters.gbvs_params; end
      end
      
      S=getfield(gbvs(I,gbvs_params),'master_map');
      S=imresize(S,imsize);
      if ~isempty(smap_smoothing_filter_params)
        if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
          S=anigauss(S,smap_smoothing_filter_params{2});
        else
          S=imfilter(S, fspecial(smap_smoothing_filter_params{:}));
        end
      end

    % ====================================================================
    % Achanta et al. - CVPR (2009)
    % ====================================================================
    case {'achanta:2009'}
%       % =================================================================
%       % ORIGINAL CODE taken from Saliency_Achanta_CVPR2009.m
%       img = imread('input_image.jpg');%Provide input image path
%       gfrgb = imfilter(img, fspecial('gaussian', 3, 3), 'symmetric', 'conv');
%       %---------------------------------------------------------
%       % Perform sRGB to CIE Lab color space conversion (using D65)
%       %---------------------------------------------------------
%       cform = makecform('srgb2lab', 'whitepoint', whitepoint('d65'));
%       lab = applycform(gfrgb,cform);
%       %---------------------------------------------------------
%       % Compute Lab average values (note that in the paper this
%       % average is found from the unblurred original image, but
%       % the results are quite similar)
%       %---------------------------------------------------------
%       l = double(lab(:,:,1)); lm = mean(mean(l));
%       a = double(lab(:,:,2)); am = mean(mean(a));
%       b = double(lab(:,:,3)); bm = mean(mean(b));
%       %---------------------------------------------------------
%       % Finally compute the saliency map and display it.
%       %---------------------------------------------------------
%       sm = (l-lm).^2 + (a-am).^2 + (b-bm).^2;
%       imshow(sm,[]);
%       % =================================================================

        assert(size(I,3) == 3);
        
        saliency_resize_method='bicubic';
        if ~isempty(extended_parameters)
          if isfield(extended_parameters,'saliency_resize_method'), saliency_resize_method = extended_parameters.saliency_resize_method; end
        end
        
        % we assume that the color space conversion has been done beforehand
        l = double(I(:,:,1)); lm = mean(mean(l));
        a = double(I(:,:,2)); am = mean(mean(a));
        b = double(I(:,:,3)); bm = mean(mean(b));
        
        % calculate the smoothed image
        if ~isfloat(I)
          IS=im2double(I); %double(zeros(size(I)));
        else
          IS=I;
        end
        if ~isempty(smap_smoothing_filter_params)
          if ischar(smap_smoothing_filter_params{1}) && strcmp('anigauss',smap_smoothing_filter_params{1})
            for i=1:size(I,3)
              IS(:,:,i)=anigauss(IS(:,:,i),smap_smoothing_filter_params{2});
            end
          else
            IS=imfilter(IS,fspecial(smap_smoothing_filter_params{:}));
          end
        end
        %IS = imfilter(I, fspecial('gaussian', 3, 3), 'symmetric', 'conv');
        
        S = (IS(:,:,1) - lm).^2 + (IS(:,:,2) - am).^2 + (IS(:,:,3) - bm).^2;
        S=imresize(S,imsize,saliency_resize_method);

    % ====================================================================
    % Achanta et al. - ICIP (2010)
    % ====================================================================
    case {'achanta:2010'}
%       % =================================================================
%       % ORIGINAL CODE taken from Saliency_MSSS_ICIP2010.m
%       img = imread('input_image.jpg');%Provide input image path
%       dim = size(img);
%       width = dim(2);height = dim(1);
%       gfrgb = imfilter(img, fspecial('gaussian', 3, 3), 'symmetric', 'conv');
%       %---------------------------------------------------------
%       % Perform sRGB to CIE Lab color space conversion (using D65)
%       %---------------------------------------------------------
%       cform = makecform('srgb2lab', 'whitepoint', whitepoint('d65'));
%       lab = applycform(gfrgb,cform);
%       l = double(lab(:,:,1));
%       a = double(lab(:,:,2));
%       b = double(lab(:,:,3));
%       %[l a b] = RGB2Lab(gfrgb(:,:,1),gfrgb(:,:,2), gfrgb(:,:,3));
%       %---------------------------------------------------------
%       % Compute Lab average values (note that in the paper this
%       % averages are found from the unblurred original image, but
%       % the results are quite similar)
%       %---------------------------------------------------------
%       sm = zeros(height, width);
%       for j = 1:height
%           yo = min(j, height-j);
%           for k = 1:width
%               xo = min(k,width-k);
%               lm = mean2(l(max(1,j-yo):min(j+yo,height),max(1,k-xo):min(k+xo,width)));
%               am = mean2(a(max(1,j-yo):min(j+yo,height),max(1,k-xo):min(k+xo,width)));
%               bm = mean2(b(max(1,j-yo):min(j+yo,height),max(1,k-xo):min(k+xo,width)));
%               %---------------------------------------------------------
%               % Compute the saliency map and display it.
%               %---------------------------------------------------------
%               sm(j,k) = (l(j,k)-lm).^2 + (a(j,k)-am).^2 + (b(j,k)-bm).^2;
%           end
%       end
%       imshow(sm,[]);
%       % =================================================================

        assert(size(I,3) == 3);
        
        saliency_resize_method='bicubic';
        if ~isempty(extended_parameters)
          if isfield(extended_parameters,'saliency_resize_method'), saliency_resize_method = extended_parameters.saliency_resize_method; end
        end
        
        % width and height
        dim = size(I);
        width = dim(2);
        height = dim(1);
        
        % we assume that the color space conversion has been done beforehand
        l = double(I(:,:,1));
        a = double(I(:,:,2));
        b = double(I(:,:,3));
      
        S = zeros(height, width);
        for j = 1:height
            yo = min(j, height-j);
            for k = 1:width
                xo = min(k,width-k);
                
                lm = mean2(l(max(1,j-yo):min(j+yo,height),max(1,k-xo):min(k+xo,width)));
                am = mean2(a(max(1,j-yo):min(j+yo,height),max(1,k-xo):min(k+xo,width)));
                bm = mean2(b(max(1,j-yo):min(j+yo,height),max(1,k-xo):min(k+xo,width)));

                S(j,k) = (l(j,k)-lm).^2 + (a(j,k)-am).^2 + (b(j,k)-bm).^2;
            end
        end
        S=imresize(S,imsize,saliency_resize_method);

    % ==================================================================
    % Cheng et al. - CVPR (2012)
    % see Schauerte et al. - ICIP (2013)
    % ==================================================================
    case {'contrast:region','rc'}
      if ~exist('region_saliency_mex','file'), addpath(genpath('region_saliency')); end

      sigma_dist=0.5;%0.4;
      seg_k=50;
      seg_min_size=50;
      seg_sigma=0.5;
      if ~isempty(extended_parameters)
        if isfield(extended_parameters,'sigma_dist'), sigma_dist = extended_parameters.sigma_dist; end
        if isfield(extended_parameters,'seg_k'), seg_k = extended_parameters.seg_k; end
        if isfield(extended_parameters,'seg_min_size'), seg_min_size = extended_parameters.seg_min_size; end
        if isfield(extended_parameters,'seg_sigma'), seg_sigma = extended_parameters.seg_sigma; end
      end

      saliency_resize_method='bicubic';
      S=double(region_saliency_mex(single(I),'RC',sigma_dist,seg_k,seg_min_size,seg_sigma));
      S=imresize(S,imsize,saliency_resize_method);
      
    % ==================================================================
    % Schauerte et al. - ICIP (2013)
    %
    % Region contrast (RC/CB) with an explicit additional center bias.
    % ==================================================================
    case {'contrast:region:centerbias','rccb'}
      if ~exist('region_saliency_mex','file'), addpath(genpath('region_saliency')); end
      
      % Center-Bias Combination Type IDs
      %   CB_LINEAR  = 0
      %   CB_PRODUCT = 1
      %   CB_MAX     = 2
      %   CB_MIN     = 3
      cbctids={'CB_LINEAR','CB_PRODUCT','CB_MAX','CB_MIN'};   % the combination types
      f_cbctids_idx=@(s) sum(strcmp(s,cbctids) .* [1 2 3 4]); % get the index of the string
      
      sigma_dist=0.5;%0.4;
      seg_k=50;
      seg_min_size=50;
      seg_sigma=0.5;
      center_bias_weight=0.5;
      center_bias_height_sigma=0.5;
      center_bias_width_sigma=0.5;
      center_bias_combination_type=0;
      if ~isempty(extended_parameters)
        if isfield(extended_parameters,'sigma_dist'), sigma_dist = extended_parameters.sigma_dist; end
        if isfield(extended_parameters,'seg_k'), seg_k = extended_parameters.seg_k; end
        if isfield(extended_parameters,'seg_min_size'), seg_min_size = extended_parameters.seg_min_size; end
        if isfield(extended_parameters,'seg_sigma'), seg_sigma = extended_parameters.seg_sigma; end
        if isfield(extended_parameters,'center_bias_weight'), center_bias_weight = extended_parameters.center_bias_weight; end
        if isfield(extended_parameters,'center_bias_height_sigma'), center_bias_height_sigma = extended_parameters.center_bias_height_sigma; end
        if isfield(extended_parameters,'center_bias_width_sigma'), center_bias_width_sigma = extended_parameters.center_bias_width_sigma; end
        if isfield(extended_parameters,'center_bias_combination_type'), center_bias_combination_type = extended_parameters.center_bias_combination_type; end
      end
      
      if ischar(center_bias_combination_type)
        center_bias_combination_type=f_cbctids_idx(center_bias_combination_type)-1;
      end
      
      saliency_resize_method='bicubic';
      S=double(region_saliency_mex(single(I),'RCCB',sigma_dist,seg_k,seg_min_size,seg_sigma,center_bias_weight,center_bias_height_sigma,center_bias_width_sigma,center_bias_combination_type));
      S=imresize(S,imsize,saliency_resize_method);
      
    % ==================================================================
    % Schauerte et al. - ICIP (2013)
    %
    % Locally debiased region contrast (LDRC).
    % ==================================================================
    case {'locally:debiased:contrast:region','ldrc','ldcr'}
      if ~exist('region_saliency_mex','file'), addpath(genpath('region_saliency')); end
      
      sigma_dist=0.4; % @note: always take care that the sigma_dist fits the debias table in region_saliency.cpp
      seg_k=50;
      seg_min_size=50;
      seg_sigma=0.5;
      if ~isempty(extended_parameters)
        if isfield(extended_parameters,'sigma_dist'), sigma_dist = extended_parameters.sigma_dist; end
        if isfield(extended_parameters,'seg_k'), seg_k = extended_parameters.seg_k; end
        if isfield(extended_parameters,'seg_min_size'), seg_min_size = extended_parameters.seg_min_size; end
        if isfield(extended_parameters,'seg_sigma'), seg_sigma = extended_parameters.seg_sigma; end
      end

      saliency_resize_method='bicubic';
      S=double(region_saliency_mex(single(I),'LDRC',sigma_dist,seg_k,seg_min_size,seg_sigma));
      S=imresize(S,imsize,saliency_resize_method);
      
    % ==================================================================
    % Schauerte et al. - ICIP (2013)
    %
    % Locally debiased region contrast (LDRC) with an explicit additional
    % center bias (LDRC/CB).
    % ==================================================================
    case {'locally:debiased:contrast:region:centerbias','ldcrb','ldrccb'}
      if ~exist('region_saliency_mex','file'), addpath(genpath('region_saliency')); end
      
      % Center-Bias Combination Type IDs
      %   CB_LINEAR  = 0
      %   CB_PRODUCT = 1
      %   CB_MAX     = 2
      %   CB_MIN     = 3
      cbctids={'CB_LINEAR','CB_PRODUCT','CB_MAX','CB_MIN'};   % the combination types
      f_cbctids_idx=@(s) sum(strcmp(s,cbctids) .* [1 2 3 4]); % get the index of the string

      sigma_dist=0.4; % @note: always take care that the sigma_dist fits the debias table in region_saliency.cpp
      seg_k=50;
      seg_min_size=50;
      seg_sigma=0.5;
      center_bias_weight=0.5;
      center_bias_height_sigma=0.5;
      center_bias_width_sigma=0.5;
      center_bias_combination_type=0;
      if ~isempty(extended_parameters)
        if isfield(extended_parameters,'sigma_dist'), sigma_dist = extended_parameters.sigma_dist; end
        if isfield(extended_parameters,'seg_k'), seg_k = extended_parameters.seg_k; end
        if isfield(extended_parameters,'seg_min_size'), seg_min_size = extended_parameters.seg_min_size; end
        if isfield(extended_parameters,'seg_sigma'), seg_sigma = extended_parameters.seg_sigma; end
        if isfield(extended_parameters,'center_bias_weight'), center_bias_weight = extended_parameters.center_bias_weight; end
        if isfield(extended_parameters,'center_bias_height_sigma'), center_bias_height_sigma = extended_parameters.center_bias_height_sigma; end
        if isfield(extended_parameters,'center_bias_width_sigma'), center_bias_width_sigma = extended_parameters.center_bias_width_sigma; end
        if isfield(extended_parameters,'center_bias_combination_type'), center_bias_combination_type = extended_parameters.center_bias_combination_type; end
      end

      if ischar(center_bias_combination_type)
        center_bias_combination_type=f_cbctids_idx(center_bias_combination_type)-1;
      end

      saliency_resize_method='bicubic';
      S=double(region_saliency_mex(single(I),'LDRCCB',sigma_dist,seg_k,seg_min_size,seg_sigma,center_bias_weight,center_bias_height_sigma,center_bias_width_sigma,center_bias_combination_type));
      S=imresize(S,imsize,saliency_resize_method);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DUMMY IMPLEMENTATIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case {'ones'}
      S=double(ones(imsize));
      
    case {'zeros'}
      S=double(ones(imsize));
      
    case {'random'}
      S=rand(imsize);
      
    case {'center-bias','centerbias'}
      if numel(imsize) == 1
        imsize=[size(I,1) size(I,2)];
      end
      
      x = ones(imsize(1),1)*[1:imsize(2)];
      y = [1:imsize(1)]'*ones(1,imsize(2));
      
      S=double(zeros(imsize));
      
      % center the Gaussian in the image
      y0 = imsize(1)/2;
      x0 = imsize(2)/2;
      
      % define width/height std. dev.
      h0 = imsize(1)/4;
      w0 = imsize(2)/4;      
      
      S  = S + ( exp((-(x-x0).^2)/w0^2) .* exp((-(y-y0).^2)/h0^2) );

    %%%
    %%%
    % FAIL
    %%%
    %%%

    otherwise
      error('unsupported multichannel saliency calculation mode')

  end
  
  if do_figures
    figure('name',['Saliency (' multichannel_method ')']);
    subplot(1,2,1); imshow(I);
    subplot(1,2,2); imshow(mat2gray(imresize(S, imorigsize(1:2))));
  end
