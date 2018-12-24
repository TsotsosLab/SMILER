function D = Patch2ImageDist(P, I, A)
% function Patch2ImageDist(P, I) calculate distance between patch
% P and patches on I.
% INPUT
% P         m-by-n-by-k
% I         p-by-q-by-k
% OUTPUT
% D         p-by-q-by-k

% 2010.6.25

% Distance of 2 patches is defined as the Euclidian distance between their
% vectors.
% ALGORITHM
% Definition: D(pi, pj) = sqrt( (pi-pj)^T (pi-pj) )
%                       = sqrt( |pi|^2 + |pj|^2 - 2*dot(pi, pj) )

M = size(P, 1);
N = size(P, 2);

if mod(M, 2) == 0 || mod(N, 2) == 0
    error('Dimension of P should be odd number')
end

hM = (M-1)/2;          % half size of height of P
hN = (N-1)/2;          % half size of width of Pend
    
Ds = A;

for k=1:size(I, 3)
    % Use convolution to calculate inner product
    C = conv2(I(:, :, k), fliplr(flipud(P(:,:,k))), 'valid');

    % Calulate |P|^2
    nP = sum(sum(P(:,:,k).^2));
  
    Ds = Ds + nP - 2*C;
end

Ds(Ds<0) = 0;
Ds = sqrt(Ds);

% Padding border zero
D = zeros(size(I,1), size(I,2));
D(hM+1:end-hM, hN+1:end-hN) = Ds;
