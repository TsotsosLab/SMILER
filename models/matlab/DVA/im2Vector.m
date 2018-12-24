function vecImg = im2Vector(myImg)
bSize = 8;
[imgH, imgW, imgDim] = size(myImg);

mapW = imgW-bSize+1;
mapH = imgH-bSize+1;

vecImg = zeros(bSize*bSize*imgDim, mapH*mapW);

itrNum = 0;
for itrW = 1:imgW-bSize+1;
	for itrH = 1:imgH-bSize+1
		itrNum=itrNum+1;
		itrPatch = myImg(itrH:itrH+(bSize-1), itrW:itrW+(bSize-1), :);
		vecImg(:, itrNum) = itrPatch(:);
	end
end

