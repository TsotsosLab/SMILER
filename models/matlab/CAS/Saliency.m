function S = Saliency(I, VERBOSE)
% function S = Saliency(I, VERBOSE) calculates the saliency of each pixel.
% Input
% I         Gray image or RGB image.
% VERBOSE   Set 1 to show the progress.
% OUTPUT
% S         Saliency value in [0,1].

% Implemented by Jyun-Fan Tsai and Kai-Jeuh Chang.
% Note: The implementation may have some difference to the paper [1] 
% since some detail information is not provided.
% If you find bugs, please send to jyunfan@gmail.com.

% 2010.7.16 Fix the bug: I is a gray image
% 2010.7.9

% Reference
% [1] Stas Goferman, Lihi Zelnik-Manor, and Ayellet Tal. Context-Aware Saliency Detection. CVPR 2010

if ~exist('VERBOSE', 'var')
    VERBOSE = 0;
end

% Resize the input image so that longest edge has 250 pixels
H = size(I,1);
W = size(I,2);
I = imresize(I, [H W]/max(H,W)*250, 'bilinear');

% Convert from rgb to lab color space
[h, w, ch] = size(I);
if size(I, 3)>1
    C = makecform('srgb2lab');
    I = applycform(I, C);
end

% Normalize each plane to [0,1]
I = double(I);
tmpI = reshape(I, [], ch);
tmpMin = min(tmpI);  tmpLen = max(tmpI) - tmpMin + eps;
tmpI = (tmpI - repmat(tmpMin, size(tmpI,1), 1)) ./ repmat(tmpLen, size(tmpI,1), 1);
I = reshape(tmpI, [h, w, ch]);

% Multiscale
SCALES = [1 0.8 0.5 0.3];   % 4 scales defined in [1]
HSIZE  = [3 2 1 1];         % Patch size in each scale.
FACTOR = 49 ./ [7^2 5^2 3^2 3^2];   % Adjust distance according to patch size.

S = zeros(size(I,1), size(I,2), length(SCALES));

for s=1:length(SCALES)
    if SCALES(s) < 1
        stmp = Saliency_internal(imresize(I, SCALES(s), 'bilinear'), SCALES(s), HSIZE(s), FACTOR(s), VERBOSE);
        S(:,:,s) = imresize(stmp, [size(S,1), size(S,2)], 'bilinear');
    else
        S(:,:,s) = Saliency_internal(I, SCALES(s), HSIZE(s), FACTOR(s), VERBOSE);
    end
end

S = mean(S, 3);

% Find attended areas
SS = S > max(max(S))*0.8;   % magic number!

% Equation (5) in [1]
D  = bwdist(SS);
D  = D / max(max(D));
S  = S .* (1-D);

function S = Saliency_internal(I, scale, H, FACTOR, VERBOSE)
% Constants
PC = 3;         % position constant
SCALE = [1 0.5 0.25];
STH = 0.2;      % minimum scale

% Generate position map
PM = zeros(size(I,1), size(I,2));
len = max(size(I,1), size(I,2));
PM(:,:,1) = repmat(1:size(I,2),    [size(I,1) 1]) / len;
PM(:,:,2) = repmat((1:size(I,1))', [1 size(I,2)]) / len;

% Three different scales
Img{1} = I;
Img{2} = imresize(I, 0.5,  'bicubic');
Img{3} = imresize(I, 0.25, 'bicubic');

% sample patches
nHeight = size(I,1);
nWidth  = size(I,2);
ch      = size(I,3);

nSamPatch = 0;
for s=1:3
    if scale*SCALE(s) < STH
        break
    end
    nSamPatch = nSamPatch + length(H+1:H:size(Img{s},1)-H) * length(H+1:H:size(Img{s},2)-H);
end

samPatch = zeros(2*H+1, 2*H+1, ch, nSamPatch);
posPatch = zeros(2, nSamPatch);
nPatchIdx = 1;
for s=1:3
    if scale*SCALE(s) < STH
        break
    end
    for k = H+1:H:size(Img{s},1)-H
        for l = H+1:H:size(Img{s},2)-H
            samPatch(:,:,:,nPatchIdx) = Img{s}((k-H):(k+H), (l-H):(l+H), :);
            posPatch(1, nPatchIdx) = l / (len*SCALE(s));
            posPatch(2, nPatchIdx) = k / (len*SCALE(s));
            nPatchIdx = nPatchIdx+1;
        end
    end
end

nTop = 64;          % Select most K similar patches
nMaxKeep = 500;     % Trick for saving memory

A = PrepPatch2ImageDist(samPatch(:,:,:,1), I);

distanceTable = zeros(nHeight*nWidth, nMaxKeep);
      
for k = 1:nTop
    D = Patch2ImageDist(samPatch(:,:,:,k), I, A);

    Dp = sqrt((PM(:,:,1) - posPatch(1,k)).^2 + (PM(:,:,2) - posPatch(2,k)).^2);
    D = D ./ (1 + PC*Dp);
    distanceTable(:, k) = D(:);
end
nBufIdx = nTop+1;

if VERBOSE
    fprintf('total patch = %d, k =      ', nSamPatch);
end
for k = nTop+1:nSamPatch
    D = Patch2ImageDist(samPatch(:,:,:,k), I, A);
    
    if VERBOSE
        fprintf('\b\b\b\b\b\b%6d', k);
    end

    Dp = sqrt((PM(:,:,1) - posPatch(1,k)).^2 + (PM(:,:,2) - posPatch(2,k)).^2);
    D = D ./ (1 + PC*Dp);

    distanceTable(:, nBufIdx) = D(:);

    nBufIdx = nBufIdx+1;
    if(nBufIdx>nMaxKeep)
        distanceTable = sort(distanceTable, 2, 'ascend');
        nBufIdx = nTop+1;
    end
end

if VERBOSE
    fprintf('\n');
end

distanceTable = sort(distanceTable, 2, 'ascend');
distanceTable(distanceTable<0) = 0;
distanceTable = 1 - exp(-mean(distanceTable(:, 1:nTop), 2) * FACTOR);

S = reshape(distanceTable, [nHeight nWidth]);
