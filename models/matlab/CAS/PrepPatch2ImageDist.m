function A = PrepPatch2ImageDist(P, I)
% function A = PrepPatch2ImageDist(P, I) calculate the essential
% information from integral image.
% INPUT
% P         m-by-n-by-k
% I         p-by-q-by-k

M = size(P, 1);
N = size(P, 2);

if mod(M, 2) == 0 || mod(N, 2) == 0
    error('Dimension of P should be odd number')
end

hM = (M-1)/2;          % half size of height of P
hN = (N-1)/2;          % half size of width of Pend
    
A = zeros(size(I, 1)-2*hM, size(I, 2)-2*hN);

intImage = zeros(size(I,1)+1, size(I,2)+1);

for k=1:size(I, 3)

    % Calculate |pi|^2 for each patch on I. Use squared integral image.
    sI = I(:, :, k).^2;

    intImage(2:end,2:end) = cumsum(cumsum(double(sI)),2);
    
    % valid region
    T = 1+hM;
    B = size(I,1) - hM;
    L = 1+hN;
    R = size(I,2) - hN;
    
    Ia = intImage(T-hM:B-hM, L-hN:R-hN);
    Ib = intImage(T-hM:B-hM, L+hN+1:R+hN+1);
    Ic = intImage(T+hM+1:B+hM+1, L-hN:R-hN);
    Id = intImage(T+hM+1:B+hM+1, L+hN+1:R+hN+1);    
    
    A = A + Id + Ia - Ib - Ic;
end
