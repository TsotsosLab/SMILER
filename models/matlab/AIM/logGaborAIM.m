% A variant of AIM implemented to use a log-Gabor filter bank in lieu of
% the originally proposed learned ICA filter set. log-Gabor filters 
% provide a parametric alternative to ICA filters without a drop in
% performance based on the results in:
% N.D.B. Bruce, X. Shi, E. Simine, and J.K. Tsotsos (2011). Visual
%     Representation in the Determination of Saliency. Proc. Computer and
%     Robot Vision (CRV)
% Function implemented by: Calden Wloka
function salmap = logGaborAIM(inimname)

    lum = imresize(rgb2gray(im2double(imread(inimname))),1.0);
    %lum = rgb2gray(im2double(imread(inimname)));
    nscale = 3; norient = 6;
    Lcounter=0;
    logV1stackL = zeros(size(lum,1),size(lum,2),nscale*norient);
    
    G=gaborconvolve(lum,nscale,norient,3,2,0.65,1);
    
        for i=1:nscale
        for j=1:norient
            Lcounter=Lcounter+1;
            logV1stackL(:,:,Lcounter) = real(G{i,j}); % OPTION - USE REAL OR IMAGE HERE?
        end
        end
        
        [R, C, Z] = size(logV1stackL);
        %salmap = selfinfo(logV1stackL,1);
            
        salmap = zeros(R,C);
        for i = 1:Z
            tempsalmap = selfinfo(logV1stackL(:,:,i), 1);
            salmap = salmap + tempsalmap;
        end
end