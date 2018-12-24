function [S,ISI,DI]=spectral_dct_saliency(I,use_uint8)
% SPECTRAL_DCT_SALIENCY implements the calculation of the visual saliency
  %   using DCT-based image signatures as presented in [1].
  %
  %   For more details on the method see:
  %   [1] X. Hou, J. Harel, and C. Koch, "Image Signature: Highlighting 
  %       sparse salient regions," in PAMI, 2011.
  %       (original paper)
  %   [2] B. Schauerte, and R. Stiefelhagen, "Quaternion DCT Spectral 
  %       Saliency: Predicting Human Gaze using Quaternion DCT Image 
  %       Signatures and Face Detection," in IEEE Workshop on Applications
  %       of Computer Vision (WACV) / IEEE Winter Vision Meetings, 2012.
  %       (extension to quaternions; spectral saliency and face detection)
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
  
  assert(size(I,3)==1);
  
  if nargin < 2, use_uint8 = false; end
  
  if use_uint8
    I=im2uint8(I); % @note: this has a significant influence of the AUC result for RGB on the Bruce-Tsotsos data set
  end
  
  DI  = dct2(I);         % DCT of the input image
  ISI = idct2(sign(DI)); % Image Signature (SI) of the Image
  S   = ISI.^2;          % square and filter
  