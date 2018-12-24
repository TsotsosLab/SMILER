function myEnergy = im2Energy(curImg, W)
%% Vectorization
curImgVector = im2Vector(curImg);
curFMapVector = W * curImgVector;

%% ICL
curFMapVector = abs(curFMapVector);
curFramePDF = sum(curFMapVector, 2);
wVector = calcICL(curFramePDF);
wVector = repmat(wVector, 1, size(curFMapVector, 2));
myEnergyMat = wVector .* curFMapVector;
myEnergy = sum(myEnergyMat);