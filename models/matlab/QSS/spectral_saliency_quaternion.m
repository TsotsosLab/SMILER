function [S,FQIR,IFQIR]=spectral_saliency_quaternion(I,absexp,fftaxis)
  % SPECTRAL_SALIENCY_QUATERNION implements the calculation of the 
  %   quaternion-based multi-channel visual saliency using pure spectral 
  %   whitening.
  %
  %   For more details on the method see:
  %   [1] C. Guo, Q. Ma, and L. Zhang, “Spatio-temporal saliency detection
  %       using phase spectrum of quaternion fourier transform," in CVPR, 
  %       2008.
  %  
  %   Closely related to this approach, but using DCT image signatures:
  %   [2] B. Schauerte, and R. Stiefelhagen, "Predicting Human Gaze using 
  %       Quaternion DCT Image Signature Saliency and Face Detection," in 
  %       IEEE Workshop on Applications of Computer Vision (WACV) / IEEE 
  %       Winter Vision Meetings, 2012.
  %
  %   It has been applied, e.g., here:
  %   [3] B. Schauerte, B. Kühn, K. Kroschel, R. Stiefelhagen, "Multimodal 
  %       Saliency-based Attention for Object-based Scene Analysis," in 
  %       IROS, 2011.
  %
  %   And evaluated on eye-tracking data, here:
  %   [4] B. Schauerte, and R. Stiefelhagen, "Predicting Human Gaze using 
  %       Quaternion DCT Image Signature Saliency and Face Detection," in 
  %       IEEE Workshop on Applications of Computer Vision (WACV) / IEEE 
  %       Winter Vision Meetings, 2012.
  %   [5] B. Schauerte, and R. Stiefelhagen, "Quaternion-based Spectral
  %       Saliency Detection for Eye Fixation Prediction," in European 
  %       Conference on Computer Vision (ECCV), 2012
  %
  %   However, the underlying principle has been addressed long before:
  %   [6] A. Oppenheim and J. Lim, “The importance of phase in signals,�?
  %       in Proc. IEEE, vol. 69, pp. 529–541, 1981.
  % 
  % @author: B. Schauerte
  % @date:   2011
  % @url:    http://cvhci.anthropomatik.kit.edu/~bschauer/

  % Copyright 2009-2011 B. Schauerte. All rights reserved.
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

  % try to load the QTFM library (from a default path), if it is not 
  % already cached/loaded by Matlab
  if isempty(which('qtfm_root'))
    addpath(genpath('../libs/qtfm')); 
    
    if isempty(which('qtfm_root')), error('The QTFM library is required.'); end
  end 
  
  if nargin < 2, absexp = 2; end % 
  if nargin < 3, fftaxis = unit(quaternion(-1,-1,-1)); end % the FFT axis
  
  if ~isfloat(I)
    I=im2double(I);
  end
  
  nchannels=size(I,3);
  
  % create the quaternion image
  switch nchannels
    case {3}
      QIR=quaternion(I(:,:,1),I(:,:,2),I(:,:,3)); 

    case {4}
      QIR=quaternion(I(:,:,1),I(:,:,2),I(:,:,3),I(:,:,4));

    otherwise
      error('unsupported number of image dimensions/channels')
  end
  
  % transformation / phase-based saliency calculation
  FQIR=fft2(QIR);
  IFQIR=ifft2(exp(fftaxis * angle(FQIR,fftaxis)));
  S=abs(IFQIR).^absexp;
  % with qfft2
  %FQIR=qfft2(QIR,mu,'L');
  %IFQIR=iqfft2(exp(mu * angle(FQIR,mu)),mu,'L');
  %S=abs(IFQIR);

