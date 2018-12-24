function [featMaps,weight] = feat_extractFeatPart(img,featInfo)
%featInfo.x
%featInfo.feat_d1
%featInfo.feat_d2
%featInfo.lab_pca_book
%featInfo.a
%featInfo.way


if ischar(img) == 1
    img = imread(img);
end

if size(img,3)==1
    fsImg = zeros(size(img,1),size(img,2),3);
    fsImg(:,:,1)= img;
    fsImg(:,:,2)= img;
    fsImg(:,:,3)= img;
    img = fsImg;
end

x = featInfo.x;

d1 = 3;
d2 = 192;
% since ->
% % extrFeatInfo.feat_d1 = 3;
% % extrFeatInfo.feat_d2 = 192;


% thre = featInfo.thre;
idx = find(x>1e-5);
[levelIds,pcaIds] = getBelongs(d1,d2,idx);
weight = x(idx);

numOfSubspaces = length(pcaIds); 
lab_pca_book = featInfo.lab_pca_book;

a = 0; % not been used.
way=featInfo.way;

%% Scale
% Line modified to keep colour conversion as part of SMILER control; by
% default images will be passed in as LAB
%    - Calden Wloka, December 2018
%lab = colorspace('lab<-rgb', img); % old line
lab = img; % new line
level_max = max(levelIds);
[pyr] = feat_myScaleBuild(lab,level_max-1,0.5,5,2.5); 
%% PCA and RCM
h = size(lab,1);
w = size(lab,2);
featMapSize = [floor(h/8),floor(w/8)];
featMaps = zeros(featMapSize(1),featMapSize(2),numOfSubspaces); % 5:scale number
counter = 1;
for subspaceId = 1:numOfSubspaces
    %fprintf('subspace:%d,',subspaceId);
    level_img = pyr{levelIds(subspaceId)};
    lab_pca_book_W = lab_pca_book.U(:,pcaIds(subspaceId))';
    
    [~,levPCsRCMs] = feat_PCAandRCM(level_img,lab_pca_book_W,lab_pca_book,a,way,featMapSize);
    featMaps(:,:,counter) = levPCsRCMs;
    counter = counter+1;
    clear level_img
end