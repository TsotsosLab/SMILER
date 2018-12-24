%SG_CREATEFILTERF2 - creates a 2-d Gabor filter in frequency domain
%
%   [g, envelope, fhigh]=sg_createfilterf2(f,theta,gamma,eta,N)
%
% Creates a frequency domain Gabor filter with specified arguments.
% Optionally uses effective envelope, so that the created filter
% includes only 'pf' of the total filter energy.  
%
%   f     - the frequency of the filter
%   theta - orientation of the filter
%   gamma - sharpness of the filter along major axis
%   eta   - sharpness of the filter along minor axis
%   N     - size of the filter, [height width]
%
% Optional arguments are:
%   use_envelope - 0 = create a full size filter, 1 = use the envelope
%   pf           - the amount of energy to include inside envelope,
%                  default 0.99
%
% Output arguments are [g, envelope, fhigh], where g is the
% filter, envelope is the effective filter envelope and fhigh
% is the maximum frequency of the filter. Envelope is a vector of
% [xmin,xmax,ymin,ymax] and the coordinates may be negative because
% the zero frequency is located in the upper lefthand corner
% of the frequency space. 
%
% Authors: 
%   Jarmo Ilonen, <ilonen@lut.fi>
%   Joni Kamarainen <Joni.Kamarainen@lut.fi>
%   Ville Kyrki <Ville.Kyrki@lut.fi>

% $Name: V_1_0_0 $ $Id: sg_createfilterf2.m,v 1.7 2006-02-03 09:05:07 ilonen Exp $

function [g, envelope,fhigh]=sg_createfilterf2(f0, theta, gamma, eta, N,varargin)

conf = struct(...
    'use_envelope', 0, ...
    'pf',0.99 ...
    );

conf = getargs(conf, varargin);

alpha=f0/gamma;
beta=f0/eta;

if length(N)==1
  N(2)=N(1);
end;  

% filter size
Nx=N(2);
Ny=N(1);

  
pf=sqrt(conf.pf);

% accurate rectangular envelope
majenv=norminv([1-pf 1+pf]./2,0,f0/(sqrt(2)*pi*gamma));
minenv=norminv([1-pf 1+pf]./2,0,f0/(sqrt(2)*pi*eta));
envelope=accurate_envelope_f(f0,majenv(2),minenv(2),theta);
envelope(1:2)=envelope(1:2)*N(2);
envelope(3:4)=envelope(3:4)*N(1);

fhigh=compute_fhigh(f0,majenv(2),minenv(2));

% envelope area compared to total area
%area=(envelope(2)-envelope(1))*(envelope(4)-envelope(3))/(N(1)*N(2));

envelope=[floor(envelope(1)) ceil(envelope(2)) floor(envelope(3)) ceil(envelope(4))];



if conf.use_envelope>0
  % create filter with envelope
  
  nx=envelope(1):1:envelope(2);
  ny=envelope(3):1:envelope(4);
  
  % feature: the filter envelope could be larger than the image
  
  u = nx/Nx; % frequencies that bank contains
  v = ny/Ny;

  [U,V]=meshgrid(u,v);
  gf = exp(-pi^2*( (-U*sin(theta)+V*cos(theta)).^2/beta^2 + ...
                   (U*cos(theta)+V*sin(theta)-f0).^2/alpha^2 ));
  
  g=gf;

  return

else
  
  % full size filter
  
  nx = -Nx:1:Nx;
  ny = -Ny:1:Ny;

  u = nx/Nx; % frequencies that bank contains
  v = ny/Ny;

  [U,V]=meshgrid(u,v);
  gf = exp(-pi^2*( (-U*sin(theta)+V*cos(theta)).^2/beta^2 + ...
                   (U*cos(theta)+V*sin(theta)-f0).^2/alpha^2 ));
  
  % Calculating the filter using aliasing
  g = zeros(Ny,Nx);
  g = g+gf(1:Ny,1:Nx); % A_1
  g = g+gf(1:Ny,(Nx+1):(2*Nx)); % A_2
  g = g+gf((Ny+1):(2*Ny),1:Nx); % A_3
  g = g+gf((Ny+1):(2*Ny),(Nx+1):(2*Nx)); % A_4
  return;
end;  




% calculates the accurate rectangular envelope when f0, major/minor axes
% of the ellipsode, and 
function envelope=accurate_envelope_f(f0,a,b,theta)


if mod(theta,pi/2)~=0
  
  % solve points with slopes -tan(pi/2-theta) and tan(theta)
  [x1,y1]=ellipsoid_envelope_point(a,b,-tan(pi/2-theta));
  [x2,y2]=ellipsoid_envelope_point(a,b,tan(theta));
  envelope=[x1 y1; -x1 -y1; x2 y2; -x2 -y2];
  % shift by f0
  envelope=envelope+repmat([f0 0],4,1);
  
  % rotate by theta
  envelope=envelope*[cos(theta) sin(theta);-sin(theta) cos(theta)];
  
  xmin=min(envelope(:,1));
  xmax=max(envelope(:,1));
  ymin=min(envelope(:,2));
  ymax=max(envelope(:,2));
  
  envelope=real([xmin xmax ymin ymax]);
  
else 

  envelope=[f0-a 0; f0+a 0 ; f0 b; f0 -b];
  envelope=envelope*[cos(theta) sin(theta);-sin(theta) cos(theta)];
  xmin=min(envelope(:,1));
  xmax=max(envelope(:,1));
  ymin=min(envelope(:,2));
  ymax=max(envelope(:,2));
  envelope=real([xmin xmax ymin ymax]);
  
end;




% tells a point in ellipsoid with major axis a, minor b, where slope (kulmakerroin) is c
function [x,y]=ellipsoid_envelope_point(a,b,c)

x=(c*a^2)/sqrt(b^2+c^2*a^2);
y=b/a*sqrt(a^2-x^2);




% calculate fhigh
function fhigh=compute_fhigh(f0,a,b)


d=f0;

if b>a
  
  foo=-(a^2*d)/(a^2-b^2);
  
  if foo<a
    fhigh2=sqrt((d+foo)^2 + (b/a * sqrt(a^2 - foo^2))^2);
  else
    fhigh2=d+a;
  end;
  
else
  fhigh2=d+a;
end;  

if fhigh2>0.5
  fhigh2=0.5;
end;  

fhigh=fhigh2;



% calculates the inverse of the normal cumulative distribution function
function x = norminv(p,mu,sigma)

x0 = -sqrt(2).*erfcinv(2*p);
x = sigma.*x0 + mu;

