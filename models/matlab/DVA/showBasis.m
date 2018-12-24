function basisBack = showBasis(A)

patchSize = 8;
dim = 14;
gap = 2;
mapSize = (patchSize + gap)*dim - gap;
basisNum = size(A, 1);
basisBack = ones(mapSize, mapSize, 3);

curBasis = 0;
for curW = 1:patchSize+gap:mapSize
	for curH = 1:patchSize+gap:mapSize;
		if (curBasis < basisNum)
			curBasis = curBasis + 1;
			myBasis = A(:, curBasis);
			myBasis = myBasis./max(myBasis(:));
			basisBack(curH:curH+patchSize-1,curW:curW+patchSize-1, :) = ...
				reshape(myBasis, patchSize, patchSize, 3);
		end
	end
end

imshow(basisBack);
