function outMap = signatureSal( input_img , param )

%
%  inputs: 
%     img    : either matrix of intensities or filename
%     param  : optional parameters, should have fields as set in default_signature_param
%
%  output
%     outMap : a saliency map for the image 
%
%
%  This algorithm is described in the following paper:
%  "Image Signature: Highlighting sparse salient regions", by Xiaodi Hou, Jonathan Harel, and Christof Koch.
%  IEEE Transactions on Pattern Analysis and Machine Intelligence, 2011.
%  
%  Coding by Xiaodi Hou and Jonathan Harel, 2011
% 
%  License: Code may be copied & used for any purposes as long as the use is acknowledged and cited.
%

% read in file if img is filename
if ( strcmp(class(input_img),'char') == 1 ) input_img = imread(input_img); end

% convert to double if image is uint8
if ( strcmp(class(input_img),'uint8') == 1 ) input_img = double(input_img)/255; end

if ( ~exist( 'param' , 'var' ) )
  param = default_signature_param;
end

img = imresize(input_img, param.mapWidth/size(input_img, 2));

numChannels = size( img , 3  );

% Code removed to allow colour space to be controlled through SMILER
% functions.
% - Calden Wloka, December 2018
% if ( numChannels == 3 )
%   
%   if ( isequal( lower(param.colorChannels) , 'lab' ) )
%     
%     labT = makecform('srgb2lab');
%     tImg = applycform(img, labT);
%     
%   elseif ( isequal( lower(param.colorChannels) , 'rgb' ) )
%     
%     tImg = img;
%     
%   elseif ( isequal( lower(param.colorChannels) , 'dkl' ) )
%     
%     tImg = rgb2dkl( img );
%     
%   end
% 
% else
%   
%   tImg = img;
% 
% end
tImg = img;

cSalMap = zeros(size(img));  

for i = 1:numChannels
  cSalMap(:,:,i) = idct2(sign(dct2(tImg(:,:,i)))).^2;
end

outMap = mean(cSalMap, 3);

if ( param.blurSigma > 0 )
  kSize = size(outMap,2) * param.blurSigma;
  outMap = imfilter(outMap, fspecial('gaussian', round([kSize, kSize]*4), kSize));
end

if ( param.resizeToInput )
  outMap = imresize( outMap , [ size(input_img,1) size(input_img,2) ] );
end
  
outMap = mynorm( outMap , param );
