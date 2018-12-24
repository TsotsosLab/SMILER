%SG_FILTERWITHBANK - Gabor filtering with filterbank
%
% r = sg_filterwithbank(s, bank)
%
% Filter 2D signal using a filterbank. 
%
%   s - signal (image)
%   bank - filterbank, created with sg_createfilterbank()
%
% Optional arguments are
%   points    - Calculate filter values at only specific points,
%               array of [x0 y0;x1 y1;...].
%   method    - If 1 then the signal will be initially downscaled
%               to include only frequencies up to filterbank's fhigh.
%   max_zoom  - Maximum scaling to be used with method 1. Will be used 
%               only if lower than scaling factor based on highest 
%               frequency of the filter. Default 0 means that the
%               image will be downscaled as much as possible.
%
% Response structure includes
%   .N      - the size of the filtered image
%   .method - 0 or 1 (see optional arguments)
%   .freq   - a cell array of filter responses which contains fields
%      .f    - frequency of the filter
%      .zoom - scaling factor at with this filter frequency (currently
%              always the same as the same field in the main structure)
%      .resp - actual filter responses, [N x X x Y] matrix where 
%              N is number of filter orientations and X and Y are
%              the response resolution
%   [Following fields are mainly relevant with method 1 (however, they are
%   always set)]
%   .zoom       - integer factor of how much the image was downscaled 
%                 during filtering
%   .respSize   - the resolution of responses
%   .actualZoom - actual scaling factors for x and y directions, may differ
%                 slightly to .zoom
%
% Note that with 'method 1 and' different scaling factors the scale
% of the responses changes (actually the total energy of responses
% is the same with all scaling levels). If the responses must be 
% in same scale and different scaling factors are used, the response
% values must be divided by 'r.zoom^2', or for example by
%   r=sg_filterwithbank(image,bank,'method',1);
%   m=sg_resp2samplematrix(r)./prod(r.actualZoom);
%
% See also: SG_CREATEFILTERBANK, SG_RESP2SAMPLEMATRIX
%
% Authors: 
%   Jarmo Ilonen, 2004
%
% $Name: V_1_0_0 $ $Id: sg_filterwithbank.m,v 1.8 2006-02-02 10:44:11 ilonen Exp $

function [m]=sg_filterwithbank(s, bank, varargin)

conf = struct(...,
       'points',[], ...
       'method',0, ...
       'domain',0, ...
       'max_zoom',0 ...
       );

conf = getargs(conf, varargin);

[N(2) N(1)]=size(s);
%N=size(s);

m.N=[N(2) N(1)];
m.method=conf.method;

% method=1 -> initial zoom
% the image is downscaled if the maximum frequency of the filterbank
% allows, no multiresolution but only initial downscaling
if m.method==1  
  
  % power of two zoom factor
  m.zoom=2^floor( log2(0.5/bank.fhigh) );
  
  if conf.max_zoom>0 && m.zoom>conf.max_zoom
    m.zoom=conf.max_zoom;
  end;        
  
  if m.zoom>1
    
    % the responsesize is always wanted to be divisible by two
    m.respSize=round(N/m.zoom/2)*2; 
    
    % actual zoom factor
    m.actualZoom=N./m.respSize;
    
    % shift the points. if some points are very close to image border, they might
    % be shifted "out-of-matrix"
    if ~isempty(conf.points)
      conf.points=round((conf.points-1)./repmat(m.actualZoom,size(conf.points,1),1))+1; 
      % too high value? -> fix
      conf.points(conf.points(:,1)>m.respSize(1),1)=m.respSize(1);
      conf.points(conf.points(:,2)>m.respSize(2),2)=m.respSize(2);
    end;
  else
    % if we cannot downscale the signal, go back to method 0
    m.method=0;
  end;
  
end;

if m.method==0
  m.zoom=1;
  m.respSize=N; %[N(2) N(1)];
  m.actualZoom=[1 1];
end;  



if bank.conf.domain==1
  fs=fft2(ifftshift(s));
  
  % the loop for calculating responses at all frequencies

  %responses=zeros(length(freq),length(orientation),N(2),N(1));
  
  for find=1:length(bank.freq),
    f0=bank.freq{find}.f;
    
    m.freq{find}.f=f0;
    
    % zero memory for filter responses when filtering all points with original resolution
    if isempty(conf.points) && conf.method==0
      m.freq{find}.resp=zeros(length(bank.freq{find}.orient),N(2),N(1));
    end;
    
    % zero memory for filter responses when filtering all points with
    % downscaled (by the highest frequency of the filter bank)
    % resolution
    if isempty(conf.points) && conf.method==1
      m.freq{find}.resp=zeros(length(bank.freq{find}.orient),m.respSize(2),m.respSize(1));
    end;      
    
    if ~isempty(conf.points)
      m.freq{find}.resp=zeros(length(bank.freq{find}.orient),size(conf.points,1));
    end;
    
    % loop through orientations
    for oind=1:length(bank.freq{find}.orient),
      
      a= bank.freq{find}.orient{oind}.envelope;
      fhigh=bank.freq{find}.orient{oind}.fhigh;
      
      % method 0 (full size responses)
      if conf.method==0
        
        m.freq{find}.zoom=1;
        
        f2_=zeros(N(2),N(1));
        
        lx=a(2)-a(1);
        ly=a(4)-a(3);
        
        % coordinates for the filter area
        xx=mod( (0:lx) + a(1) + N(1) , N(1) ) + 1;
        yy=mod( (0:ly) + a(3) + N(2) , N(2) ) + 1;
        
        % filter the image
        f2_(yy,xx) = bank.freq{find}.orient{oind}.filter .* fs(yy,xx);
    
      end;
      
      % method 1 (initial downscale)
      if conf.method==1
        
        m.freq{find}.zoom=m.zoom;
        f2_=zeros(m.respSize(2),m.respSize(1));
        
        lx=a(2)-a(1);
        ly=a(4)-a(3);

        % coordinates for the filter area in filtered fullsize image
        xx=mod( (0:lx) + a(1) + N(1) , N(1) ) + 1;
        yy=mod( (0:ly) + a(3) + N(2) , N(2) ) + 1;
        
        % coordinates for the filter area in downscaled response image
        xx_z=mod( (0:lx) + a(1) + m.respSize(1) , m.respSize(1) ) + 1;
        yy_z=mod( (0:ly) + a(3) + m.respSize(2) , m.respSize(2) ) + 1;
 
        % filter the image
        f2_(yy_z,xx_z) = bank.freq{find}.orient{oind}.filter .* fs(yy,xx);
        
      end;    
      
      if isempty(conf.points)
        m.freq{find}.resp(oind,:,:)=fftshift(ifft2(f2_));
      else
        temp=fftshift(ifft2(f2_));
        for p=1:size(conf.points,1)
          m.freq{find}.resp(oind,p)=temp(conf.points(p,2),conf.points(p,1));
        end;
      end;
    
    end;
    
  end;
  
end;
