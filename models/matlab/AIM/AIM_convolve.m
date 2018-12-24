%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                            %%%%%%
%%%%%%           AAAA        IIIIIIIIIIII     MM        MM        %%%%%%
%%%%%%         AAA  AAA      IIIIIIIIIIII     MMM      MMM        %%%%%%
%%%%%%       AAA      AAA        IIII         MMMM    MMMM        %%%%%%
%%%%%%       AAA      AAA        IIII         MMMMMMMMMMMM        %%%%%%
%%%%%%       AAAAAAAAAAAA        IIII         MMM  MM  MMM        %%%%%%
%%%%%%       AAAAAAAAAAAA        IIII         MMM      MMM        %%%%%%
%%%%%%       AAA      AAA        IIII         MMM      MMM        %%%%%%
%%%%%%       AAA      AAA    IIIIIIIIIIII     MMM      MMM        %%%%%%
%%%%%%       AAA      AAA    IIIIIIIIIIII     MMM      MMM        %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%        ATTENTION  based on INFORMATION MAXIMIZATION        %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    MODEL OF ATTENTION BASED ON INFORMATION MAXIMIZATION    %%%%%%
%%%%%%    AUTHOR: NEIL D. B. BRUCE                                %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    CENTRE FOR VISION RESEARCH and                          %%%%%%
%%%%%%    DEPARTMENT OF COMPUTER SCIENCE AND ENGINEERING          %%%%%%
%%%%%%    YORK UNIVERSITY                                         %%%%%%
%%%%%%    Current contact: Neil.Bruce@sophia.inria.fr             %%%%%%
%%%%%%    Last update, April 2009                                 %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    SELECTED REFERENCES:                                    %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%  1. Bruce, N.D.B., Tsotsos, J.K., Saliency,                %%%%%%
%%%%%%     Attention, and Visual Search: An Information Theoretic %%%%%%
%%%%%%     Approach, Journal of Vision 9:3, pp.1-24, 2009,        %%%%%%
%%%%%%     http://journalofvision.org/9/3/5/, doi:10.1167/9.3.5.  %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%  2. Bruce, N.D.B., Tsotsos, J.K., Saliency based on        %%%%%%
%%%%%%     Information Maximization. Advances in Neural           %%%%%%
%%%%%%     Information Processing Systems, 18.                    %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%  3. Bruce, N. Features that draw visual attention: An      %%%%%%
%%%%%%     information theoretic perspective. Neurocomputing,     %%%%%%
%%%%%%     v. 65-66, pp. 125-133, May 2005.                       %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    ***************************************************     %%%%%%
%%%%%%    FOR ADDITIONAL REFERENCES AND SOME TIPS SPECIFIC TO     %%%%%%
%%%%%%    USING THE SOFTWARE FOR PSYCHOPHYSICS STIMULI, SEE THE   %%%%%%
%%%%%%    END OF THIS FILE - IN ADDITION, SOME FUNCTIONALITY      %%%%%%
%%%%%%    MAY REQUIRE FILES NOT INCLUDED IN THE "BASIC"           %%%%%%
%%%%%%    DISTRIBUTION, PLEASE CONTACT THE AUTHOR FOR SUCH        %%%%%%
%%%%%%    QUERIES, OR FOR ADDITIONAL COMMENTS AND BUGS            %%%%%%
%%%%%%    *****************************************************   %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    USE OF THIS SOFTWARE IS SUBJECT TO THE COPYRIGHT        %%%%%%
%%%%%%    NOTICE APPEARING AT THE BOTTOM OF THIS FILE             %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Use: There is a single required argument which is the      %%%%%%
%%%%%%      image name, however there are additional arguments    %%%%%%
%%%%%%      which may slightly alter the behavior since           %%%%%%
%%%%%%      many of these require different sub-arguments         %%%%%%
%%%%%%      they require editing the parameters in the code       %%%%%%
%%%%%%      itself, that said, there are a few parameters that    %%%%%%
%%%%%%      are directly accessible from the command line:        %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                            %%%%%%
%%%%%% Basic usage: out = AIM(imagename); optional arguments are: %%%%%%
%%%%%% out = AIM(imagename,resizesize,convolve,basisname,output); %%%%%%
%%%%%% resizesize - A scaling factor (% original image size)      %%%%%%
%%%%%% convolve - convolve the output with a gaussian?            %%%%%%
%%%%%% basisname - the feature set e.g. 21jade950, 31infomax975   %%%%%%
%%%%%%    The latter 3 digits correspond to the variance retained %%%%%%
%%%%%%    in PCA which precedes the ICA method named.             %%%%%%
%%%%%% output - show some visualization. This may require         %%%%%%
%%%%%%      changing some parameters appearing in the code        %%%%%%
%%%%%%      depending on the desired "look".                      %%%%%%
%%%%%%                                                            %%%%%%
%%%%%% e.g. b = AIM('23.jpg',0.5,1,'21jade950.mat',1);            %%%%%%
%%%%%%                                                            %%%%%%
%%%%%% Additional options are specified in the parameters         %%%%%%
%%%%%% that follow including the ability to modify                %%%%%%
%%%%%% parameters of the computation not available on the         %%%%%%
%%%%%% command line.                                              %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function infomap = AIM_convolve(filename,resizesize,convolve,thebasis,showoutput)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                            %%%%%%
%%%%%%                      GENERAL SETUP                         %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set to defaults or input values
nargs = nargin;
if nargs < 2, resizesize=1.0; end
if nargs < 3, convolve=0; end
if nargs < 4, thebasis='21jade950.mat'; end %others are e.g. 31jade900, 21infomax950 etc.
if nargs < 5, showoutput = 0; end
% Non command-line Defaults - require manual change

% For convolve = 1 set these
sigval = 8; % How many pixels correspond to 1 degree visual angle
sigwin = [30 30]; % What size of window is needed to contain the above

%%%%%%%%% SPECIFY METHOD FOR DENSITY ESTIMATION
method = 1;
% PARAMETERS FOR METHOD 1
bins = 256;
% PARAMETERS FOR METHOD 2
sigma = 0.01; precision = 0.01; % Careful, sigma is variance not std. dev.
                                % Precision fixed at 0.01 for now
                                % Parameters of Parzen estimate
% PARAMETERS FOR METHOD 3 ONLY
psi = fspecial('gaussian',49,20); % Local interaction entirely specified by psi
                                  % Filter dimensions must be odd
                                  % This involves local surround
                                  % suppression so size of the kernel
                                  % depends on scale unlike the previous
                                  % methods


%%%%%%%% SCALING TYPE

scalingtype = 1; % For density estimate, histogram, or Parzen estimate
                 % Created with a minimum and maximum value within certain
                 % bounds and for a particular precision - these bounds may
                 % be determined by the maximum and minimum values across
                 % all features (type 1) or within each feature
                 % domain (type 2) or additionally as in type 2 but based
                 % on learned values from a large number of exemplars across
                 % several images (type 3) - type 3 are loaded from a file

% Output related
% For showoutput=1
dispthresh = 80; % How much is the cutoff percentage wise in the hard threshold
contrastval = 6; % How much contrast in the "transparent" representation
%%%% END OF DEFAULT VALUES                                      %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read image
%fprintf('Reading Image.\n');
if (ischar(filename))
    inimage = (imresize(im2double((imread(filename))),resizesize));
else
    inimage = imresize(im2double(filename), resizesize);
end

if size(inimage, 3) == 1
    inimage = repmat(inimage, [1, 1, 3]);
end
%inimage = (imresize(im2double(img),resizesize));

%imshow(inimage,[])

% Load basis
%fprintf('Loading Basis.\n');
load(thebasis);

inbasis=B;         % B should be the variable holding the unmixing matrix
                   % Be careful of which one is being used and choose
%inbasis=pinv(B)'; % appropriately which may involving uncommenting this line
                   % depending on how you store your learned basis
                   % functions


% Some values precomputed for efficiency
p = sqrt(size(inbasis,2)/3);
pm = p-1;
ph = pm/2; % These two lines assume an odd window size



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                            %%%%%%
%%%%%%      PRODUCE SPARSE REPRESENTATION OF IMAGE CONTENT        %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% If starting with mixing matrix may need pseudoinverse else leave as is
pv = inbasis;


%%fprintf('Projecting local neighbourhoods into basis space.\n');
progress = 0;
%%fprintf('0        25       50       75        100\n');

% s = zeros(size(pv, 1), size(inimage, 1)-pm, size(inimage, 1)-pm);
% for i=ph+1:size(inimage,1)-ph
%
%    % A progress indicator for impatient people ;)
%    progress = progress + 1/(size(inimage,1)-pm);
%    if (progress > 0.025)
%    progress = progress - 0.025;
%    %%fprintf('.')
%    end
%
%     for j=ph+1:size(inimage,2)-ph
%
%        % Build a pxp patch [in column vector form] around the local
%        % coordinate
%        t = inimage(i-ph:i+ph,j-ph:j+ph,:);
%       % Project patch onto basis
%
%       BVpatch=pv*t(:);
%       %clear temppatch % Garbage collection
%
%       % Now add a pixel to each of the 3*patchsize^2 new feature maps
%       s(:,i-ph,j-ph)=BVpatch';
%
%       %clear BVpatch % Garbage collection
%
%     end
%
% end


kernel_size = sqrt(size(inbasis, 2)/size(inimage, 3));
kernels = reshape(inbasis, [size(inbasis, 1), kernel_size,kernel_size, size(inimage, 3)]);
s = zeros(size(kernels, 1), size(inimage, 1)-pm, size(inimage, 2)-pm);


for i = 1:size(kernels, 1)
   temp = imfilter(inimage(:, :, 1), squeeze(kernels(i, :, :, 1)), 'corr');
   aim_temp = temp;
%   save(sprintf('aim_temp%i_%i.mat', i-1, 0), 'aim_temp');
    kernel = squeeze(kernels(i, :, :, 1));
%    save(sprintf('kernels%i_%i.mat', i-1, 0), 'kernel');

   for j = 2:size(inimage, 3)

      aim_temp = imfilter(inimage(:, :, j), squeeze(kernels(i, :, :, j)), 'corr');
%      save(sprintf('aim_temp%i_%i.mat', i-1, j-1), 'aim_temp');

      kernel = squeeze(kernels(i, :, :, j));
%      save(sprintf('kernels%i_%i.mat', i-1, j-1), 'kernel');
      temp = temp + imfilter(inimage(:, :, j), squeeze(kernels(i, :, :, j)), 'corr');
   end
      s(i, :, :) = temp(ph+1:size(inimage, 1)-ph, ph+1:size(inimage, 2)-ph);
    %temp1 = temp(ph+1:size(inimage, 1)-ph, ph+1:size(inimage, 2)-ph);
    %fprintf('feature %i min %f max %f\n', i, min(temp1(:)), max(temp1(:)));
end
% Rescale for efficient density estimation - this grabs values across all
% of the "independent" feature dimenstions - individual scaling may apply
% later depending on parameters specified

minscale = min(min(min(s)));
maxscale = max(max(max(s)));
%fprintf('min %0.5f  max 0.5f\n', minscale, maxscale);

%fprintf('\nPerforming Density Estimation.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                            %%%%%%
%%%%%%   COMPUTE FEATURE LIKELIHOOD BASED ON A DENSITY ESTIMATE   %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

progress = 0;
%fprintf('0        25       50       75        100\n');


for z=1:size(s,1)

   % A progress indicator for impatient people ;)
   progress = progress + 1/size(s,1);
   if (progress > 0.025)
   progress = progress - 0.025;
%   fprintf('.')
   end

   % Translate image from 1xMxN to MxN for ease of processing
   tempim(1:size(inimage,1)-pm,1:size(inimage,2)-pm) = s(z,1:size(inimage,1)-pm,1:size(inimage,2)-pm);

   % If scaling based on values from all feature dimensions, reset for each
   % feature domain
   if (scalingtype == 1)
     % Do nothing, already got the min and max across all dimensions from s
     % above
   end

   if (scalingtype == 2)
      % Scale each domain between 0 and 1 separately
      minscale = min(min(tempim));
      maxscale = max(max(tempim));

   end

   if (scalingtype == 3)
% load learned limits for various basis functions - scaling method 3 only
% load minmax31jade900
  load minmax21jade950
% load thelimits

      minscale = minval(z); % If scaling based on a learned representation of ranges from natural image content
      maxscale = maxval(z); % Note you must load a ranges variable with maxes and mins for each dimension
   end


   % Scale temporary copy of feature plane
   stempim = tempim-minscale;
   stempim = stempim./(maxscale-minscale);

   % This next line can be dangerous - only applies in case 3
   if (scalingtype == 3)
   stempim = max(stempim,0);
   stempim = min(stempim,1);
   end

if (method == 1)
%%% METHOD 1 - HISTOGRAM ESTIMATE OVER ENTIRE IMAGE

   %Compute histogram
   histo = imhist(stempim,bins);

   % Rescale values based on histogram to reflect likelihood
   ts(z,:,:) = histo(round(stempim*(bins-1)+1))./sum(histo);

elseif (method == 2)
%%% METHOD 2 - NON-PARAMETRIC ESTIMATE OVER ENTIRE IMAGE


   % Compute non-parametric density estimate
   dens = kernest(stempim(:),sigma,precision);
   %dens = dens./sum(sum(dens));

   % Re-map values based on probabilities
   % Precision fixed at 100 for the moment
   ts(z,:,:) = dens(round((stempim*99+1)));

elseif (method == 3)
%%% METHOD 3 - NON-PARAMETRIC ESTIMATE OVER LOCAL NEIGHBORHOOD
%%% THIS IMPLEMENTS THE FULL CIRCUIT METHOD LOCALLY USING THE PSI
%%% PARAMETER - THIS IS COMPUTATIONALLY INTENSIVE BUT MIGHT BE MOST ACCURATE
%%% FROM THE PERSPECTIVE OF BIOLOGICAL PLAUSIBILITY

% Psi indicates the contribution of neighbouring elements to the local
% estimate as in [1].

% To deal with edge effects, the external portion of the image is reflected
% about the image boundary, so that the estimate is effectively based on
% support from one side only

halfsupport = (size(psi,1)-1)/2;

% Add support region to image
rstempim = ones(size(stempim,1)+size(psi,1)-1,size(stempim,2)+size(psi,2)-1);
%rstempim(halfsupport+1:size(rstempim,1)-halfsupport,halfsupport+1:size(rstempim,2)-halfsupport)=stempim;

% And reflect inside region
rstempim = padarray(tempim,[halfsupport halfsupport],'both','symmetric');


nor = 1/(sqrt(2*pi)*sigma); % Normalize the kernel

for xx=halfsupport+1:size(rstempim,1)-halfsupport
    for yy=halfsupport+1:size(rstempim,2)-halfsupport

        ts(z,xx-halfsupport,yy-halfsupport)=nor*sum(sum(psi.*exp(-(rstempim(xx-halfsupport:xx+halfsupport,yy-halfsupport:yy+halfsupport)-rstempim(xx,yy)).^2/(2*sigma^2))));

    end
end

end

end

%fprintf('\nTransforming likelihoods into information measures.\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                            %%%%%%
%%%%%%        TRANSFORMATION INTO THE INFORMATION DOMAIN          %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Overall information content is product of individual feature maps with
% Shannon definition of Self-Information applied - Can do a log of products
% or a sum of logs... the former requires too much precision

% When information is being added, tasks specific weights can be introduced
% for each channel allowing top down bias

% Width and height of information map
wid = size(ts,2);
hei = size(ts,3);

% Initialize to information gained from 1st feature domain
infomapt = -log(reshape(ts(1,:,:),wid,hei)+0.000001);

% Add information gained from remaining features
for z=2:size(s,1)
%for z=2:50
infomapt = infomapt - log(reshape(ts(z,:,:),wid,hei)+0.000001);
end


if (convolve == 1)
    infomapt = filter2(fspecial('gaussian',sigwin,sigval),infomapt);
end


% Pad the final map so that its size matches the input image

infomap = zeros(size(inimage,1),size(inimage,2))+min(min(infomapt));
%size(infomap(ph+1:size(inimage,1)-ph,ph+1:size(inimage,2)-ph))
%size(infomapt)
infomap(ph+1:size(inimage,1)-ph,ph+1:size(inimage,2)-ph)=infomapt;

tempim = zeros(size(inimage));

if (showoutput == 1)
   figure(1);
   subplot(2,2,1)
   imshow(inimage,[])
   subplot(2,2,2)
   imshow(infomap(sigwin(1):size(infomap,1)-sigwin(1),sigwin(1):size(infomap,2)-sigwin(1)),[]);
   subplot(2,2,3)
   threshmap2 = min((infomap./prctile(infomap(:),98)),1);
   r=imshow(inimage,[]);
   set(r,'AlphaData',threshmap2.^contrastval);

   subplot(2,2,4)
   threshmap1=(infomap > prctile(infomap(:),dispthresh));
   tempim(:,:,1)=threshmap1.*inimage(:,:,1);
   tempim(:,:,2)=threshmap1.*inimage(:,:,2);
   tempim(:,:,3)=threshmap1.*inimage(:,:,3);
   imshow(tempim,[]);
   drawnow;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    ADDITIONAL REFERENCES:                                  %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    Bruce, N.D.B., Tsotsos, J.K., Spatiotemporal Saliency:  %%%%%%
%%%%%%    Towards a Hierarchical Representation of Visual         %%%%%%
%%%%%%    Saliency, 5th Int. Workshop on Attention in Cognitive   %%%%%%
%%%%%%    Systems, Santorini Greece, May 12, 2008.                %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    Bruce, N.D.B., Tsotsos, J.K., An Information Theoretic  %%%%%%
%%%%%%    Model of Saliency and Visual Search, L. Paletta         %%%%%%
%%%%%%    and E. Rome (Eds.): WAPCV 2007, LNAI 4840,              %%%%%%
%%%%%%    pp. 171�183, 2007.                                      %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    Bruce, N.D.B., Image analysis through local information %%%%%%
%%%%%%    measures. In Proceedings of the 17th International      %%%%%%
%%%%%%    Conference on Pattern Recognition, Cambridge, UK, 2004. %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                            %%%%%%
%%%%%%                   COPYRIGHT NOTICE                         %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%                                                            %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    THIS SOFTWARE IS THE PROPERTY OF ITS AUTHOR             %%%%%%
%%%%%%    NEIL D. B. BRUCE. THE AUTHOR GRANTS PERMISSION TO       %%%%%%
%%%%%%    DISTRIBUTE THE SOFTWARE IN ITS ORIGINAL FORM WITHOUT    %%%%%%
%%%%%%    MODIFICATION. UNDER SUCH CIRCUMSTANCES THE COPYRIGHT    %%%%%%
%%%%%%    NOTICE AND FUNCTIONALITY OF THE SOFTWARE MUST REMAIN    %%%%%%
%%%%%%    ENTIRELY INTACT INCLUDING ALL SYNTACTIC AND             %%%%%%
%%%%%%    SEMANTIC ELEMENTS OF ITS FUNCTION. THE AUTHOR GRANTS    %%%%%%
%%%%%%    A NON-EXLUSIVE LICENSE TO INDIVIDUALS WISHING TO USE    %%%%%%
%%%%%%    THE SOFTWARE FOR NON-PROFIT RESEARCH PURPOSES. THOSE    %%%%%%
%%%%%%    WISHING TO EMPLOY THE SOFTWARE FOR COMMERCIAL OR PROFIT %%%%%%
%%%%%%    SEEKING ENDEAVORS SHOULD CONTACT THE AUTHOR TO DISCUSS  %%%%%%
%%%%%%    LICENSING.                                              %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    DERIVATIVE WORKS ARE ALLOWED BY INDIVIDUALS FOR         %%%%%%
%%%%%%    NON-PROFIT RESEARCH PURPOSES. SUCH DERIVATIVE WORKS     %%%%%%
%%%%%%    MAY NOT BE DISTRIBUTED WITHOUT WRITTEN CONSENT OF THE   %%%%%%
%%%%%%    AUTHOR. ANY WORKS THAT USE THE ABOVE SOFTWARE IN WHOLE  %%%%%%
%%%%%%    OR PART FOR A COMMERCIAL APPLICATION MUST OBTAIN A      %%%%%%
%%%%%%    VALID LICENSE FROM THE AUTHOR.                          %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%    THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS"   AND   %%%%%%
%%%%%%    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT   %%%%%%
%%%%%%    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY   %%%%%%
%%%%%%    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.    %%%%%%
%%%%%%    IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,  %%%%%%
%%%%%%    INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR            %%%%%%
%%%%%%    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,   %%%%%%
%%%%%%    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF    %%%%%%
%%%%%%    USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)        %%%%%%
%%%%%%    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER  %%%%%%
%%%%%%    IN CONTRACT, STRICT LIABILITY, OR TORT                  %%%%%%
%%%%%%    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY  %%%%%%
%%%%%%    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF     %%%%%%
%%%%%%    THE POSSIBILITY OF SUCH DAMAGE.                         %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%                                                            %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
