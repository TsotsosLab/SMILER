function S = Saliency(I)
% function S = Saliency(I) calculates the saliency of each pixel.
% Input
% I       Gray image or RGB image.

% 2010.6.25

% Reference
% Context-Aware Saliency Detection, CVPR 2010

% Convert from rgb to lab color space
if size(I, 3)>1
    C = makecform('srgb2lab');
    I = applycform(I, C);
end

I = im2double(I);

% Multiscale
% SCALES = [1 0.8 0.5 0.3];
SCALES = 1;
S = zeros(size(I,1), size(I,2), length(SCALES));

for s=1:length(SCALES)
    if SCALES(s) < 1
        % Smoothing before resizing
        f = fspecial('gaussian', round(5/SCALES(s)), 1/SCALES(s));
        smI = imfilter(I, f);
        
        stmp = Saliency_internal(imresize(smI, SCALES(s), 'bilinear'), SCALES(s));
        S(:,:,s) = imresize(stmp, [size(S,1), size(S,2)], 'bilinear');
    else
        S(:,:,s) = Saliency_internal(I, SCALES(s));
    end
end

% S = mean(S, 3);

function S = Saliency_internal(I, scale)
% Constants
H  = 3;      % half of patch size, patch size is 7x7
PC = 3;      % position constant
K  = 64;     % Select most K similar patches

S = zeros(size(I,1), size(I,2));

% Generate position map
PM{1} = zeros(size(I,1), size(I,2), 2);
len = max(size(I,1), size(I,2));
PM{1}(:,:,1) = repmat(1:size(I,2),    [size(I,1) 1]) / len;
PM{1}(:,:,2) = repmat((1:size(I,1))', [1 size(I,2)]) / len;

I_2 = imresize(I, 0.5,  'bicubic');
I_4 = imresize(I, 0.25, 'bicubic');
PM{2} = imresize(PM{1}, 0.5,  'bicubic');
PM{3} = imresize(PM{1}, 0.25, 'bicubic');

for r=H+1:size(I,1)-H
    for c=H+1:size(I,2)-H
            
        % color distance
        Pi    = I(r-H:r+H, c-H:c+H, :);
        Dc{1} = Patch2ImageDist(Pi, I);
        if scale/2 > 0.2
            Dc{2} = Patch2ImageDist(Pi, I_2);
        end
        if scale/4 > 0.2
            Dc{3} = Patch2ImageDist(Pi, I_4);
        end
               
        Du = [];
        for k=1:length(Dc)
            D{k} = Dc{k} ./ ...
                (1 + PC.*(sqrt( (c/len-PM{k}(:,:,1)).^2 + (r/len-PM{k}(:,:,2)).^2 )));
            D{k} = D{k}(H+1:H:end-H, H+1:H:end-H);
            Du = [Du; D{k}(:)];
        end
       
        val = sort(Du, 'ascend');
        S(r,c) = 1 - exp(-mean(val(1:K)));
    end
end

