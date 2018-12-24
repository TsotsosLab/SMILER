%SG_CREATEFILTERBANK creates Gabor filter bank
% 
% bank = sg_createfilterbank(N, f, m, n)
%
% Creates filterbank with specified frequencies and orientations.
% The same filterbank is usable with normal and multi-resolution
% filtering.
% Note! Only frequency domain filters are created.
%
%   N - size of the image, [height width].
%   f - frequencies, [f_max], a number of them is
%       automagically generated depending on other arguments,
%       or specific frequencies if 'user_freq' is specified.
%   m - number of filter frequencies.
%   n - number or filter orientations, or specific orientations 
%       'user_orientation' specified.
%
% Optional arguments are
%   k         - factor for selecting filter frequencies
%               (1, 1/k, 1/k^2, 1/k^3...), default is sqrt(2)
%   p         - crossing point between two consecutive filters, 
%               default 0.5
%   gamma     - gamma of the filter
%   eta       - eta of the filter'
%   pf        - energy to include in the filters, default 0.99
%   user_freq - filter only at frequencies specified in 'f', you
%               must also specify 'gamma' and 'eta'
%   user_orientation  - filter only at orientations specified in 'n'
%   extra_freq - calculate extra_freq frequencies for scale invariance
%   verbose    - 1 = displays the filter bank, 2 = display all filters
%
% If no optional arguments are specified, filter bank frequencies
% and filter sharpness values are automatically selected.
% If there is no special knowledge that specific filter sharpness
% values (gamma and eta) are wanted, it is most straightforward to
% use the defaults or specify only other 'k' and 'p' values.
% If needed, 'gamma' and 'eta' can be set directly.
%
% Output is a structure which includes 
%   .conf  - parameters (gamma, eta, p, k) of the filters etc
%   .size  - N
%   .fhigh - maximum frequency of the whole filter bank
%   .freq  - a cell array for filters with all different frequencies
%      .f  - frequency of the filter
%      .orient - cell array of filters at different orientations
%         .filter   - the actual filter
%         .envelope - envelope of the filter
%         .fhigh     - maximum frequency of the filter
%         .o        - orientation of the filter
%
% Example:
%   bank=sg_createfilterbank(size(img),1/10, 5, 4,'verbose',1);
%     Creates a filter bank with frequencies starting from 0.1,
%     5 filter frequencies are used and the filters are in 
%     4 orientations (every 45 degrees). The filter bank
%     will be displayed.
%
% See also: SG_FILTERWITHBANK
%
% Authors: 
%   Jarmo Ilonen
%
% $Name: V_1_0_0 $ $Id: sg_createfilterbank.m,v 1.7 2007-01-16 13:03:49 ilonen Exp $

function [bank]=sg_createfilterbank(N, f, m, n, varargin)

conf = struct(...,
       'gamma',0, ...
       'eta',0,...
       'k',sqrt(2),...
       'p',0.5,...
       'verbose',0,...
       'user_freq',0,...
       'user_orientation',0, ...
       'domain',0, ...
       'extra_freq',0, ...
       'pf',0.99 ...
       );

conf = getargs(conf, varargin);       
       
% choosing the frequencies of filters
if conf.user_freq==0 && conf.user_orientation==0
  % select parameters for the filters
  [gamma_,eta_]=sg_solvefilterparams(conf.k, conf.p,m,n);
  
  if conf.gamma==0,
    conf.gamma=gamma_;
  end;
  
  if conf.eta==0
    conf.eta=eta_;
  end;
  
  % select frequencies for the filters using k and m
  freq=f./conf.k.^(0:(m+conf.extra_freq-1));

else
  freq=sort(f);
  freq=freq(end:-1:1);
  if conf.gamma==0 || conf.eta==0
    error('sg_createfilterbank: You must specify gamma and eta with user_freq');
    return;
  end;
end;

% choosing the orientations of filters
if conf.user_orientation==0
  % select orientations based 
  if n==0 || fix(n)~=n
    error('sg_createfilterbank: Zero/broken orientations without user_orientations specified');
  end;
  orientation=0:pi/n:pi;
  orientation=orientation(1:end-1);
else
  orientation=sort(n);
end;  

% choose the domain, which is currently always frequency-domain
if conf.domain==0
  conf.domain=1;
end;  

% warn if the image dimensions are slow to compute for fft
maxfactor=max([factor(N(1)) factor(N(2))]);
if maxfactor>13
  warning('sg_createfilterbank: FFT computations might be slow, largest factor of image dimensions is %d', maxfactor);
end;


bank.conf=conf;
bank.size=N;

bank.fhigh=0;

if conf.domain==1
  
  nf=1;
  for f0=freq,
    no=1;
    
    bank.freq{nf}.f=f0;
    
    for o0=orientation,
      [filt,envelope,fhigh]=sg_createfilterf2(f0,o0,conf.gamma,conf.eta,N,'use_envelope',1,'pf',conf.pf);
      
      bank.freq{nf}.orient{no}.filter=filt;
      bank.freq{nf}.orient{no}.envelope=envelope;
      bank.freq{nf}.orient{no}.fhigh=fhigh;
      
      if fhigh > bank.fhigh
        bank.fhigh=fhigh;
      end;
      
      bank.freq{nf}.orient{no}.o=o0;
      
      no=no+1;
      
    end;
    nf=nf+1;
    
  end;
  
end;

% return unless verbose option was used
if conf.verbose==0
  return
end;  

% coordinates are a bit weird
M(1)=N(2);
M(2)=N(1);

fspace=zeros(M(2),M(1));

for find=1:length(bank.freq),
  for oind=1:length(bank.freq{find}.orient),
    a= bank.freq{find}.orient{oind}.envelope;
    
    lx=a(2)-a(1);
    ly=a(4)-a(3);
    
    % coordinates for the filter area
    xx=mod( (0:lx) + a(1) + M(1) , M(1) ) + 1;
    yy=mod( (0:ly) + a(3) + M(2) , M(2) ) + 1;
    
    fspace(yy,xx) = fspace(yy,xx) + bank.freq{find}.orient{oind}.filter;
    
    % display single filters in both frequency and spatial domain
    if conf.verbose>=2
      f2_=zeros(M(2),M(1));
    
      f2_(yy,xx) = bank.freq{find}.orient{oind}.filter;
      
      % spatial filter
      f2=ifftshift(ifft2((f2_)));
      
      subplot(1,3,1), imagesc(f2_); colormap gray; axis image; title('Frequency space');
      subplot(1,3,2), imagesc(real(f2)); colormap gray; axis image; title('Real')
      subplot(1,3,3), imagesc(imag(f2)); colormap gray; axis image; title('Imag');
      str=sprintf('Filter with frequency %.6f, orientation %.2f degrees [press enter to continue]', bank.freq{find}.f,bank.freq{find}.orient{oind}.o*180/pi );
      input(str);
    end;
    
  end;        
end;

% display the whole filterbank in frequency space
clf
subplot(1,2,1), imagesc(fspace); colormap(gray); axis image; axis off; title('Combined frequency response of the bank');

subplot(1,2,2), imagesc(fftshift(fspace)); colormap(gray); axis image; title('Zero frequency shifted to center');
tick=get(gca,'YTick');
set(gca,'YTickLabel',1-tick/max(tick)-0.5);
tick=get(gca,'XTick');
set(gca,'XTickLabel',tick/max(tick)-0.5);
