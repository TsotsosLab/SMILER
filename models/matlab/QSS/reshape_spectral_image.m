function X=reshape_spectral_image(I,do_forward_shift)
  % RESHAPE_SPECTRAL_IMAGE reorder the quadrants of an FFT/DCT transformed
  %   image for better visualization, i.e.
  %
  %   +---+---+    +---+---+
  %   | 1 | 2 |    | 4 | 3 |
  %   +---+---+ => +---+---+
  %   | 3 | 4 |    | 2 | 1 |
  %   +---+---+    +---+---+
  %
  % Wrapper around fftshift(.) for backward compatibility.
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

  if nargin < 2, do_forward_shift = true; end
  
  % image size has to be even numbered
%   assert(mod(size(I,1),2) == 0);
%   assert(mod(size(I,2),2) == 0);
%   
%   sh1=floor(size(I,1)/2);
%   sh2=floor(size(I,2)/2);
%   X=zeros(size(I));
%   if size(I,3) == 1
%     X(1:sh1,(sh2+1):end)       = I((sh1+1):end,1:sh2);
%     X((sh1+1):end,1:sh2)       = I(1:sh1,(sh2+1):end);
%     X(1:sh1,1:sh2)             = I((sh1+1):end,(sh2+1):end);
%     X((sh1+1):end,(sh2+1):end) = I(1:sh1,1:sh2);
%   else
%     X(1:sh1,(sh2+1):end,:)       = I((sh1+1):end,1:sh2,:);
%     X((sh1+1):end,1:sh2,:)       = I(1:sh1,(sh2+1):end,:);
%     X(1:sh1,1:sh2,:)             = I((sh1+1):end,(sh2+1):end,:);
%     X((sh1+1):end,(sh2+1):end,:) = I(1:sh1,1:sh2,:);
%   end
  if do_forward_shift
    X=fftshift(I);
  else
    X=ifftshift(I);
  end
