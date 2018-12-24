function [sm] = GetSaliencyMap(imgpath,model,lab_pca_book)


extrFeatInfo.lab_pca_book = lab_pca_book;
extrFeatInfo.way = 2;
extrFeatInfo.x = model;

[featMaps,weightOfFeatMaps] = feat_extractFeatPart(imgpath,extrFeatInfo);

weight = weightOfFeatMaps;

height = size(featMaps,1);
width = size(featMaps,2);
sm = zeros(height,width);
% *
%weight = weight(weight>1e-5);
% *
for m = 1:height
    for n = 1:width
        Fea = featMaps(m,n,:);
        sm(m,n) = weight'*Fea(:);
    end
end
