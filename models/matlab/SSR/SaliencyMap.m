function FinalS = SaliencyMap(RGB,s,param)

% Compute Saliency Map

% [RETURNS]
% FinalS   : Saliency Map
%
% [PARAMETERS]
% RGB   : the input image
% s     : resize factor
% param : parameters

% [HISTORY]
% Nov 23, 2011 : created by Hae Jong

FinalS = zeros(size(RGB,1),size(RGB,2));

% Code modified to have SMILER perform colour space conversions.
% - Calden Wloka, December 2018
% % Convert RGB to Lab CIE color channel
% if size(RGB,3) > 1
%     Lab = im2double(colorspace('Lab<-RGB',RGB));
% else
%     Lab = im2double(RGB);
% end
Lab = RGB;

for c = 1:size(Lab,3)
    img = Lab(:,:,c);
    img = imresize(img, s, 'bilinear');
    img = img - min(img(:));
    img = img/max(img(:));
    Lab1(:,:,c) = img;
    % Compute LARKs at every pixel points
    LARK{c} = ComputeLARK(img,param.P,param.alpha,param.h); %0.43 0.6 --> 0.6828 %0.43 0.4 --> 0.6842 %0.42, 0.2 --> 0.6914
end
% Generate self-resemblance map

if param.N == inf
    S = ComputeSelfRemblance_global(Lab1,LARK,param);
else
    S = ComputeSelfRemblance(Lab1,LARK,param);
end
FinalS = imresize(mat2gray(S),[size(RGB,1), size(RGB,2)],'bilinear');

end
