clear
clc
load AW.mat;

%% Reading image
inImg = im2double(imread(strcat('testImg.jpg')));
inImg = imresize(inImg, [80,120]);
[imgH, imgW, imgDim] = size(inImg);

%% Building Saliency Saliency
myEnergy = im2Energy(inImg, W);
mySMap = vector2Im(myEnergy, imgH, imgW);

%% Visualization
mySMap = mySMap.^2;
mySMap = imfilter(mySMap, fspecial('gaussian', [8, 8], 8));
figure(1);
subplot(1,2,1)
imshow(mySMap,[]);
subplot(1,2,2)
imshow(inImg);

%% (Optional) Showing basis
figure(2);
showBasis(A);