function D = Patch2ImageDistSlow(P, I)
% function Patch2ImageDist(P, I) calculate distance between patch
% P and patches on I.
% INPUT
% P         m-n-k
% I         p-q-k
% OUTPUT
% D         p-q-k

% Distance of 2 patches is defined as the Euclidian distance between their
% vectors.

D = zeros(size(I, 1), size(I, 2));
hM = (size(P, 1)-1)/2;
hN = (size(P, 2)-1)/2;
vP = reshape(P, numel(P), 1);   % vectorize

for r=hM+1:size(I, 1)-hM
    for c=hN+1:size(I, 2)-hN
        tmp = I(r-hM:r+hM, c-hN:c+hN, :);
        vtmp = reshape(tmp, numel(P), 1);
        D(r, c) = norm(vP-vtmp);
    end
end