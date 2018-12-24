%SG_RESP2SAMPLEMATRIX
%
%   m = sg_resp2samplematrix(r)
%
% Converts response structure returned by sg_filterwithbank to a
% matrix more suitable for e.g. using with classifiers. 
%
% If responses were computer for all points, a [height x width x
% filter_values] matrix will be created. Filter values are arranged in
% [f1o1 f1o2 ... f2o1 f2o2 ... ] order. If responses for only some
% points were computer, matrix will be of format 
% [point x filter_values].
%
% Options:
%   normalize - set to 1 to normalize responses. For info on 
%               normalization see sg_normalizesamplematrix
%
% Example:
%   s = sg_resp2samplematrix(r,'normalize',1);
%
% See also: SG_FILTERWITHBANK, SG_SCALESAMPLES, SG_ROTATESAMPLES,
%           SG_NORMALIZESAMPLEMATRIX
%
% Authors: 
%   Jarmo Ilonen, 2004
%
% $Name: V_1_0_0 $ $Id: sg_resp2samplematrix.m,v 1.2 2005-10-12 14:28:35 ilonen Exp $

function meh=sg_resp2samplematrix(r,varargin)

conf=struct(...
     'normalize',0 ...
         );
     
conf = getargs(conf, varargin);     
     
nf=length(r.freq);
of=length(r.freq{1}.resp(:,1,1));

n=size(r.freq{1}.resp);


% handle case with responses from all points
if length(n)==3
  meh=zeros(n(2),n(3),nf*of);
  
  for i=1:nf
    for u=1:of
      meh(:,:,(i-1)*of+(u-1) + 1)=r.freq{i}.resp(u,:,:);
    end;
  end;
  if conf.normalize>0,
    meh=(1./repmat(sqrt(sum(abs(meh).^2,3)),[1,1,nf*of])).*meh;
  end;
  return;
end;

% case with only some responses
if length(n)==2
  meh=zeros(n(2),nf*of);
  
  for i=1:nf
    for u=1:of
      meh(:,(i-1)*of+(u-1) + 1)=r.freq{i}.resp(u,:);
    end;
  end;
  if conf.normalize>0,
    meh=(1./repmat(sqrt(sum(abs(meh).^2,2)),[1,nf*of])).*meh;
  end;
  return;
end;

error('Could not decipher response structure');


