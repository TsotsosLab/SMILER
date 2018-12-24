function [out,intervals] = imconvert(in,from,to)
  % IMCONVERT provides a generic interface to convert between image formats
  %   (e.g. rgb -> Lab).
  %
  %   Input:
  %     in:   the input image
  %     from: the input image's color space
  %     to:   the desired output image's color space
  %   Output:
  %     out:  the convert image in the desired color space
  %     intervals: the value range of the colorspace
  %
  %   The interface also allows a simple weighting of the color channels
  %   after the conversion. For example, imconvert(image,'rgb','lab[0.5 1 1]')
  %   would convert the RGB image 'image' into and Lab image in which L, a,
  %   and b have the weights 0.5, 1, and 1, respectively.
  %
  %   Furthermore, we allow transformation chains, e.g. 'rgb2xyz:lab' would
  %   first transform the image from RGB to XYZ and then from XYZ to LAB.
  %
  %   Note: In order to allow all color space conversion, the "Colorspace
  %   Transformations" package (available from Mathwork's file exchange)
  %   is supported and can be used.
  %
  % @author: B. Schauerte
  % @date:   2009-2013
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

% let's allow weighted color spaces
% Usage example: imconvert(image,'rgb','lab[0.5 1 1]') would convert the
%   RGB image 'image' into and Lab image in which L, a, and b have the
%   weights 0.5, 1, and 1, respectively.
has_weights = false;
if ~isempty(strfind(to,']'))
  in = im2double(in); % force double
  % determine the weights
  t = strfind(to,'[');
  weights = to(t:end);
  to = to(1:t-1);
  % convert weights to real numbers
  weights = str2num(weights);
  has_weights = true;
end


in_excess=[];
if size(in,3) > 3
  warning('imconvert: more than 3 image channels. Just processing the first three channels.');
  in_excess = in(:,:,4:end);
  in = in(:,:,1:3);
end

switch lower(from)
  case 'rgb'
    switch lower(to)
      case 'rgb8'
        out = im2uint8(in);
        intervals =[0,255; 0,255; 0,255];
      case 'rgb'
        out = im2double(in);
        intervals = [0,1; 0,1; 0,1];
        %out=in;
        %if strcmp(class(in), 'uint8') || ((max(max(in(:,:,3))) > 1.0 || max(max(in(:,:,2))) > 1.0 || max(max(in(:,:,1))) > 1.0))
        %	intervals=[0,255; 0,255; 0,255];
        %else
        %	intervals=[0,1; 0,1; 0,1];
        %end
      case 'lab'
        out = rgb2Lab(in);
        intervals = [0,100; -110,110; -110,110];
      case 'rgblab'
        out(:,:,1:3) = im2double(in);
        out(:,:,4:6) = rgb2Lab(in);
        intervals = [0,1; 0,1; 0,1; 0,100; -110,110; -110,110];
      case 'nlab' % normalized lab
        out = rgb2Lab(in);
        out(:,:,1) = out(:,:,1)-min(min(out(:,:,1)));
        out(:,:,2) = out(:,:,2)-min(min(out(:,:,2)));
        out(:,:,3) = out(:,:,3)-min(min(out(:,:,3)));
        out(:,:,1) = out(:,:,1)/(max(max(out(:,:,1)))+eps);
        out(:,:,2) = out(:,:,2)/(max(max(out(:,:,2)))+eps);
        out(:,:,3) = out(:,:,3)/(max(max(out(:,:,3)))+eps);
        intervals = [0,1; 0,1; 0,1];
      case 'labn' % normalized value range with respect to the original value range
        out = rgb2Lab(in);
        out(:,:,1) = out(:,:,1) / 100;
        out(:,:,2) = (out(:,:,2) + 110) / 220;
        out(:,:,3) = (out(:,:,3) + 110) / 220;
        intervals = [0,1; 0,1; 0,1];
        %out(:,:,2) = (out(:,:,2) + 110) / 2.2;
        %out(:,:,3) = (out(:,:,3) + 110) / 2.2;
        %intervals=[0,100; 0,100; 0,100];
        %out(:,:,2) = out(:,:,2) * 2; %+ 110) / 2.2;
        %out(:,:,3) = out(:,:,3) * 2; %+ 110) / 2.2;
        %intervals=[0,100; -220,220; -220,220];
      case 'labm' % use Matlab's conversion
        C = makecform('srgb2lab');
        out = applycform(in,C);
        intervals = [0,100; -128,127; -128,127];
      case 'hsv'
        out = rgb2hsv(in);
        intervals = [0,1; 0,1; 0,1];
      case 'hsl'
        out = colorspace([to '<-' from],im2double(in));
        out(:,:,1) = out(:,:,1) / 360;
        mx = max(max(out(:,:,2)));
        if mx > 1
          out(:,:,2) = out(:,:,2) / (mx + eps);
        end
        mx = max(max(out(:,:,3)));
        if mx > 1
          out(:,:,3) = out(:,:,3) / (mx + eps);
        end
        intervals = [0,1; 0,1; 0,1];
      case 'lch'
        out = colorspace([to '<-' from],im2double(in));
        intervals = [0,100; -156,156; 0,360];
      case 'icopp'
        out = rgb2icopp2(in);
        intervals = [NaN,NaN; NaN,NaN; NaN,NaN];
      otherwise
%         if ~isempty(strfind(to,':'))
%           %%%
%           % Some convenient recursive conversions
%           %%%
%           [to1,to2] = strtok(to,':');
%           to2 = to2(2:end);
%           [out,intervals] = imconvert(imconvert(in,from,to1),to1,to2);
%         else
%           if exist('colorspace','file')
%             out = colorspace([to '<-' from],im2double(in));
%             intervals = [0,1; 0,1; 0,1];
%           else
%             error('%s -> %s: unsupported conversion\n', from, to);
%           end
%         end
          if exist('colorspace','file')
            out = colorspace([to '<-' from],im2double(in));
            intervals = [0,1; 0,1; 0,1];
          else
            error('%s -> %s: unsupported conversion\n', from, to);
          end
    end
  case 'lab'
    switch lower(to)
      case 'rgb'
        out = Lab2rgb(in);
        intervals = [0,255; 0,255; 0,255];
      case 'lab'
        out = in;
        intervals = [0,100; -110,110; -110,110];
      otherwise
        if exist('colorspace','file')
          out = colorspace([to '<-' from],in);
          intervals = [0,1; 0,1; 0,1];
        else
          error('%s -> %s: unsupported conversion\n', from, to);
        end
    end
  case 'hsv'
    switch lower(to)
      case 'rgb'
        out = hsv2rgb(in);
        intervals = [0,1; 0,1; 0,1];
      case 'hsv'
        out = in;
        if isa(in, 'uint8') || ((max(max(in(:,:,3))) > 1.0 || max(max(in(:,:,2))) > 1.0 || max(max(in(:,:,1))) > 1.0))
          intervals = [0,255; 0,255; 0,255];
        else
          intervals = [0,1; 0,1; 0,1];
        end
      otherwise
        if exist('colorspace','file')
          out = colorspace([to '<-' from],in);
          intervals = [0,1; 0,1; 0,1];
        else
          error('%s -> %s: unsupported conversion\n', from, to);
        end
    end
  otherwise
    if exist('colorspace','file')
      out = colorspace([to '<-' from],in);
      intervals = [0,1; 0,1; 0,1];
    else
      error('%s -> %s: unsupported conversion\n', from, to);
    end
end

if ~isempty(in_excess)
  out = cat(3,out,in_excess);
end

% scale/weight the image channels with the specified weights
if has_weights
  assert(numel(weights) == size(out,3));
  for i = 1:numel(weights)
    out(:,:,i) = out(:,:,i) * weights(i); % scale/weights the channels
    intervals(i,:) = intervals(i,:) * weights(i); % also scale the range intervals to reflect the weights
  end
end
