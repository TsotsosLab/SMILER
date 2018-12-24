function [ snloginfo, outinfo , nloginfo] = selfinfo( featuremaps , estimatetype)
% Computes the self-information on a per-pixel basis of a stack of feature
% maps using either a histogram, or assuming a Generalized Gaussian
% Distribution

% Feature maps are expected to be X x Y x F where F is number of features

% outinfo   -  Likelihoods
% nloginfo  -  Negative log Likelihoods
% snloginfo -  Sum of -log likelihoods across feature map

% Method

% 1. Maximum likelihood based estimate
% 2. Histogram based estimate
% 3. Method of moments based estimate

%delta = 10e-10;

for i = 1:size(featuremaps,3)
   c = featuremaps(:,:,i);

   switch estimatetype

      case 0    
   % Compute based on a maximum likelihood estimate
   
      [mu2, alpha2, beta2] = ggmle(c(:)); % Estimate parameters of this feature map
      %plot(ggpdf(-0.1:0.001:0.1, mu2, alpha2, beta2))
      %outinfo(:,:,i)=ggcdf(c+delta,mu2,alpha2,beta2)-ggcdf(c-delta,mu2,alpha2,beta2);
      outinfo(:,:,i)=ggpdf(c,mu2,alpha2,beta2); % Map values to likelihoods
   
      case 1
      % Compute using a histogram
      bins = 100;
      minscale = min(min(min(c))); % Scale by all features
      maxscale = max(max(max(c))); % For individual scaling, run selfinfo individually
      Sc = c-minscale;
      Sc = Sc./(maxscale-minscale);
      %Compute histogram
      H = imhist(Sc,bins);
      % Rescale values based on histogram to reflect likelihood
      outinfo(:,:,i) = H(round(Sc*(bins-1)+1))./sum(H);
      
      case 2
      % Compute using method of moments
     [mu2, alpha2, beta2] = ggmme(c(:)); % Estimate parameters of this feature map
     %plot(ggpdf(-0.1:0.001:1, mu2, alpha2, beta2))
     outinfo(:,:,i)=ggpdf(c,mu2,alpha2,beta2); % Map values to likelihoods
     
   
   end
   
   %pause
   
end
nloginfo = -log(outinfo);
snloginfo = sum(nloginfo,3);
   
end

