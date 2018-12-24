function wVector = calcICL(myPDF)

nonZeroInd = find(myPDF>0);
nonZeroPDF = myPDF(nonZeroInd);

nonZeroPDF = nonZeroPDF./sum(nonZeroPDF);

baseEntropy = -sum(nonZeroPDF .* log2(nonZeroPDF));
eInc = - baseEntropy - log2(nonZeroPDF) - nonZeroPDF - nonZeroPDF.*log2(nonZeroPDF);
eInc(eInc<0) = 0;
eInc = eInc./sum(eInc);

wVector = zeros(size(myPDF));
wVector(nonZeroInd) = eInc;
