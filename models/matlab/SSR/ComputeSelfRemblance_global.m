function SR = ComputeSelfRemblance_global(varargin)

% Compute Self-Resemblance

% [RETURNS]
% SR   : Saliency Map
%
% [PARAMETERS]
% img   : Input image
% LARK  : A collection of LARK descriptors
% param : parameters

% [HISTORY]
% Nov 23, 2011 : created by Hae Jong

img = varargin{1};
LARK = varargin{2};
param = varargin{3};


[M,N,C] = size(img);
win_N = (param.N-1)/2;
win_L = (param.L-1)/2;

% To avoid edge effect, we use mirror padding.
for k = 1:C
    Temp = LARK{k};
    for i = 1:size(LARK{1},3)
        LARK1{k}(:,:,i) = EdgeMirror(Temp(:,:,i),[win_L,win_L]);
    end
end

Feature = zeros(M*N,param.P^2, 3*param.L^2);

for k = 1:C
    temp = LARK1{k};
    for m = 1:param.L
        for n = 1:param.L
            Feature(:,:,(k-1)*param.L^2+(m-1)*param.L+n) = [reshape(temp(m:m+M-1,n:n+N-1,:),[M*N size(temp,3)])];
        end
    end
end

Feature = reshape(Feature,[M*N 3*param.P^2*param.L^2]);
Feature = Feature./repmat(sqrt(sum(Feature.^2,2)),[1 3*param.P^2*param.L^2]);

SR = reshape(1./sum(exp( (-1+Feature*Feature')/(param.sigma^2)),1),[M N]);

