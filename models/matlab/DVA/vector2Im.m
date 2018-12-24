function mySMap = vector2Im(eVector, imgH, imgW)
bSize = 8;
mapW = imgW-bSize+1;
mapH = imgH-bSize+1;
mySMap = zeros(imgH, imgW);


eVector = reshape(eVector, mapH, mapW);
for cW = 1:mapW
	for cH = 1:mapH
		mySMap(cH:cH-1+bSize, cW:cW-1+bSize) = ...
			mySMap(cH:cH-1+bSize, cW:cW-1+bSize) + eVector(cH, cW);
	end
end

mySMap = mat2gray(mySMap.^2);
end
