function [S,DCTIR,IDCTIR]=spectral_dct_saliency_quaternion(I,absexp,dctaxis,L,do_normalize)
  % SPECTRAL_DCT_SALIENCY_QUATERNION implements the calculation of the 
  %   quaternion-based using quaternion-based image signatures.
  % 
  %   For more details on the method see:
  %   [1] B. Schauerte, and R. Stiefelhagen, "Quaternion DCT Spectral 
  %       Saliency: Predicting Human Gaze using Quaternion DCT Image 
  %       Signatures and Face Detection" in IEEE Workshop on Applications
  %       of Computer Vision (WACV), 2012.
  %
  % @author: B. Schauerte
  % @date:   2011
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

  % try to load the QTFM library (from a default path), if it is not 
  % already cached/loaded by Matlab
  if isempty(which('qtfm_root'))
    addpath(genpath('../libs/qtfm')); 
    
    if isempty(which('qtfm_root')), error('The QTFM library is required.'); end
  end 
  
  if ~isfloat(I)
    I=im2double(I);
  end
  
  if nargin < 2, absexp = 2; end % best value yet with 2.1 (heavily influences the result(s))
  if nargin < 3, dctaxis = unit(quaternion(-1,-1,-1)); end % the QDCT axis
  if nargin < 4, L = 'L'; end % Left- ('L') or Right-sided ('R') QDCT
  if nargin < 5, do_normalize = false; end
  
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
  
  mu=unit(dctaxis); % ensure a unit (pure) quaternion as axis
  DCTIR=qdct2(QIR,mu,L);
  IDCTIR=iqdct2(sign(DCTIR),mu,L);
  S=abs(IDCTIR).^absexp;
  
  if do_normalize
    S=S-min(min(S));
    S=S/max(max(S));
  end
