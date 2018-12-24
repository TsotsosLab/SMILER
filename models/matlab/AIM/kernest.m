% Nonparametric kernel density estimation in 1D
function distr=kernest(inmap,h,precision)

imsize=prod(size(inmap));

% Transform data to 1-D
%x = inmap(1:imsize);
% Length for normalization
x=inmap;
Nx=length(x);

% x-axis for plotting purposes
ax=[0:precision:1]; % x axis



% Gaussian kernel
%h = 0.2;
y=zeros(size(ax));
for i=1:Nx,
   y=y+exp(-0.5*((ax-x(i))).^2/(h^2));
end
%y=y/Nx;
% Forces type 2 scaling?
y=y./sum(y);
%y=y./(sqrt(2*pi)*h); % Actually sum(y) == sqrt(2*pi*h) ?
%figure,plot(ax,y),title(['Estimate for Normal Distribution, Sigma = ' num2str(h)])




distr = y;
