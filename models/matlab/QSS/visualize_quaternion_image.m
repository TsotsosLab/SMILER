function [eigenangle,eigenaxis,logmod,img_eigenangle,img_eigenaxis,img_logmod]=visualize_quaternion_image(I,quadrant_shift,do_figures)
  % VISUALIZE_QUATERNION_IMAGE provides implementations for visualization
  %   of 2-D Quaternion images. The implemented visualizations are 
  %   according to the (poster) visualizations in "HYPERCOMPLEX AUTO- AND 
  %   CROSS-CORRELATION OF COLOR IMAGES" by Stephen J. Sangwine and 
  %   Todd A. Ell.
  %
  % In the comments:
  %   S(.) is the scalar part (real part of the quaternion)
  %   V(.) is the vector part (imaginary part of the quaternion)
  %   abs  is the Modulus aka absolute value
  %
  % Output:
  %   eigenangle       The eigenangle aka phase
  %   eigenaxis        The eigenaxis
  %   logmod           The log-normalized modulus
  %   img_eigenangle   Image/visualization for the eigenangle
  %   img_eigenaxis    Image/visualization for the eigenaxis
  %   img_logmod       Image/visualization for the (log-normalized) modulus
  %
  % Usage example:
  %   [eigenangle,eigenaxis,logmod,img_eigenangle,img_eigenaxis,...
  %      img_logmod]=visualize_quaternion_image(qfft2(quaternion(...
  %        I(:,:,1),I(:,:,2),I(:,:,3)),axis,'L'),'forward',true);
  %
  % @author: B. Schauerte
  % @date:   2011-2012
  % @url:    http://cvhci.anthropomatik.kit.edu/~bschauer/

  % Copyright 2011 B. Schauerte. All rights reserved.
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
  
  if nargin < 2, quadrant_shift = 'forward'; end % 'forward' or 'backward'; otherwise: no shift!
  if nargin < 3, do_figures = true; end
  
  do_forward_quadrant_shift = strcmpi(quadrant_shift,'forward');
  do_backward_quadrant_shift = strcmpi(quadrant_shift,'backward');
  do_quadrant_shift = do_forward_quadrant_shift || do_backward_quadrant_shift;
  
  if do_figures, figure('name','quaternion visualization'); end
  
  % Display the Eigenaxis, i.e. mu = V(i) / abs(V(i)):
  %vi=v(I);
  %ai=abs(vi);
  %nvi=vi ./ ai;
  %unvi=nvi; % unit(nvi);
  unvi=unit(v(I) ./ abs(v(I)));
  eigenaxis=cat(3,x(unvi),y(unvi),z(unvi));
  img_eigenaxis=eigenaxis;
  m=max(abs(img_eigenaxis),[],3);
  img_eigenaxis = img_eigenaxis ./ cat(3,m,m,m); % this way 1 is the abs. value of at least one component
  img_eigenaxis = (img_eigenaxis / 2); % this way, 0.5 is the max. abs. value of each component
  img_eigenaxis = img_eigenaxis + 0.5; % shift into the center of the RGB cube
  if do_quadrant_shift, img_eigenaxis = reshape_spectral_image(img_eigenaxis,do_forward_quadrant_shift); end
  if do_figures
%     figure('name','eigenaxis(I)');
%     imshow(img_eigenaxis);
      subplot(1,3,1); imshow(img_eigenaxis); title('Eigenaxis');
  end
  
  % Display the phase / eigenangle, i.e. phi = tan^{-1}(abs(V(I)) / S(I)):
  %   Please note that if it is a pure quaternion, then the phase angle
  %   is undefined (division by zero). 
  %   [In this case, the image will appear green]
  %eigenangle=angle(I,unvi)/(2*pi);
  eigenangle=angle(I)/pi;
  if ~exist('imconvert') || ~exist('colorspace')
    img_eigenangle=hsv2rgb(cat(3,eigenangle,ones(size(I)),ones(size(I))));
  else
    img_eigenangle=imconvert(cat(3,eigenangle*360,ones(size(I)),ones(size(I))*0.5),'hsi','rgb');
  end
  if do_quadrant_shift, img_eigenangle=reshape_spectral_image(img_eigenangle,do_forward_quadrant_shift); end
  if do_figures
%     figure('name','eigenangle(I)');
%     imshow(img_eigenangle);
      subplot(1,3,2); imshow(img_eigenangle); title('Eigenangle');
  end
  
  % Display the Modulus in log-grayscale, i.e. M = log(1 + abs(I)) / log(1 + max(abs(I))):
  %   (Modulus aka absolute value)
  maxabs=max(max(abs(I)));
  logmod=log(1 + abs(I)) / log(1 + maxabs);
  img_logmod=mat2gray(logmod);
  if do_quadrant_shift, img_logmod=reshape_spectral_image(img_logmod,do_forward_quadrant_shift); end
  if do_figures
%     figure('name','log-Magnitude');
%     imshow(img_logmod);
      subplot(1,3,3); imshow(img_eigenangle); title('log-Magnitude');
  end
end
