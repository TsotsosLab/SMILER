% Saliency detection Demo
% [HISTORY]
% Nov 23, 2011 : created by Hae Jong Seo

% close all;
clear all;
clc;

% parameters for local self-resemblance

param.P = 3; % LARK window size
param.alpha = 0.42; % LARK sensitivity parameter
param.h = 0.2; % smoothing parameter for LARK
param.L = 7; % # of LARK in the feature matrix 
param.N = 3; % size of a center + surrounding reagion for computing self-resemblance
param.sigma = 0.2; % fall-off parameter for self-resemblamnce

% parameters for global self-resemblance

param1.P = 3; % LARK window size
param1.alpha = 0.42; % LARK sensitivity parameter
param1.h = 0.2; % smoothing parameter for LARK
param1.L = 7; % # of LARK in the feature matrix 
param1.N = inf; % size of a center + surrounding region for computing self-resemblance
param1.sigma = 0.2; % fall-off parameter for self-resemblamnce

%%

for n = 1:5
FN = ['./PsychoPattern/img00' num2str(n) '.bmp'];
RGB = imread(FN);
tic;
smap = SaliencyMap(RGB,[64 64],param); % Resize input images to [64 64]
toc;
tic;
smap_global = SaliencyMap(RGB,[64 64],param1); % Resize input images to [64 64]
toc;

figure(1)
subplot(2,3,1),sc(RGB);
subplot(2,3,2),sc(smap);
subplot(2,3,3),sc(smap_global);
subplot(2,3,5),sc(cat(3,smap,double(RGB(:,:,1))),'prob_jet');
subplot(2,3,6),sc(cat(3,smap_global,double(RGB(:,:,1))),'prob_jet');
end
