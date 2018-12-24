function [S,P,M]=spectral_saliency(I,residual_filter_length,enable_var_zero_protection)
  % SPECTRAL_SALIENCY implements the calculation of the visual saliency
  %   using pure spectral whitening (residual_filter_length=0) or
  %   the spectral residual (residual_filter_length>0).
  %
  %   For more details on the method see:
  %   [1] X. Hou and L. Zhang, "Saliency Detection: A Spectral Residual
  %       Approach," in CVPR, 2007.
  %       (original paper)
  %
  %   It has been applied quite a lot through the last years, e.g., see:
  %   [2] B. Schauerte, B. Kuehn, K. Kroschel, R. Stiefelhagen, "Multimodal 
  %       Saliency-based Attention for Object-based Scene Analysis," in 
  %       IROS, 2011.
  %       ("simple" multi-channel and quaternion-based)
  %   [3] B. Schauerte, J. Richarz, G. A. Fink,"Saliency-based 
  %       Identification and Recognition of Pointed-at Objects," in IROS,
  %       2010.
  %       (uses multi-channel on intensity, blue-yellow/red-green opponent)
  %   [4] B. Schauerte, G. A. Fink, "Focusing Computational Visual 
  %       Attention in Multi-Modal Human-Robot Interaction," in Proc. ICMI,
  %       2010
  %       (extended multi-scale and neuron-based approach that allows
  %        to incorporate information about the visual search target)
  %
  %   However, the underlying principle has been addressed long before:
  %   [5] A. Oppenheim and J. Lim, "The importance of phase in signals,"
  %       in Proc. IEEE, vol. 69, pp. 529-541, 1981.
  % 
  % @author: B. Schauerte
  % @date:   2009-2011
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
  
  assert(size(I,3)==1);
  
  if nargin<2, residual_filter_length=0; end
  if nargin<3, enable_var_zero_protection=true; end
  
  % allow to specify the residual filter using a (a) filter length, (b)
  % a set of parameters for fspecial, or (c) a filter matrix
  if iscell(residual_filter_length)
    h = fspecial(residual_filter_length{:});
  else
    if numel(residual_filter_length) == 1
      if residual_filter_length == 0
        h = fspecial('average', 3);
      else
        h = fspecial('average', residual_filter_length);
      end
    else
      h = residual_filter_length;
    end
  end
  
  % Protect the saliency maps (especially in case of the spectral residual
  % this will otherwise lead to saliency maps consisting of NaN. This is,
  % e.g., necessary to produce valid results on some psychological test
  % pattern in which this can happen (although this should never happen
  % on natural images in practical applications)
  if enable_var_zero_protection && var(double(I(:))) == 0
    S = zeros(size(I));
    P = zeros(size(I));
    M = zeros(size(I));
    return;
  end
    
  FI = fft2(I);   % Fourier-transformed image representation
  P = angle(FI);  % Phase
  M = abs(FI);    % Magnitude
  if ~iscell(residual_filter_length) && ~(numel(residual_filter_length) > 1) && ~residual_filter_length
    % perform pure spectral whitening (see [2] and [1])
    S = abs(ifft2(exp(1i*P))).^2;
  else
    % perform spectral residual (see [1])
    L  = log(M);
    SR = L - imfilter(L, h, 'replicate');
    S  = abs(ifft2(exp(SR + 1i*P))) .^ 2;
  end
