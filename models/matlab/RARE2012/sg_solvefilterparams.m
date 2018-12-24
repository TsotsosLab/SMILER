%SG_SOLVEFILTERPARAMS  solve Gabor filter parameters
%
% [gamma, eta] = sg_solvefilterparams(k, p, m, n)
%
% This functions is intended for solving filter sharpness parameters
% gamma and eta based on other filter bank parameters. 
%
%   k - spacing of filter frequencies
%   p - filter overlap
%   m - number of filter frequencies
%   n - number of filter orientations
%
% Author: Jarmo Ilonen
%
% $Name: V_1_0_0 $ $Id: sg_solvefilterparams.m,v 1.3 2005-10-12 13:22:40 ilonen Exp $

function [gamma, eta] = sg_solvefilterparams(k, p, m, n)


gamma=solvegamma(k,p);
eta=solveeta(n,p);



function gamma=solvegamma(k,p)

gamma=1/pi*sqrt(-log(p))*(k+1)/(k-1);



function k=solvek(gamma,p)

x=1/(gamma*pi)*sqrt(-log(p));
k=(1+x)/(1-x);



function p=solvep(gamma,k)

p=exp(- ( gamma*pi * (k-1)/(k+1))^2);


function eta=solveeta(n,p)

%ua=tan(pi/(no*2)) * fmax % exact ua
ua=pi/n/2;  % ua based on approximation

eta=1/pi*sqrt(-log(p))/(ua);


