function [pc_subsps,featMaps] = feat_PCAandRCM(img,lab_pca_book_W,lab_pca_book,a,way,featMapSize)

numOfpca = size(lab_pca_book_W,1);
% fid = fopen('randomTime.csv','a');

%%%% PC %%%%
lab = colorspace('lab<-rgb', img);
lab_pca = project3D(lab_pca_book_W,lab, lab_pca_book.mean_v, lab_pca_book.std_v );
pc_subsps = lab_pca;

for k = 1:numOfpca
    tmp_ica = pc_subsps(:,:,k);
    tmp_min = min(tmp_ica(:));
    tmp_max = max(tmp_ica(:));
    pc_subsps(:,:,k)=(tmp_ica-tmp_min)/(tmp_max-tmp_min+eps);
    %imwrite(uint8(round(255*pc_subsps(:,:,k))),['fs\pc_' num2str(k) '.png']);
end

%%%% RCM %%%%
% t2 = tic;
featMaps = zeros(featMapSize(1),featMapSize(2),numOfpca);
for k = 1:numOfpca
    input = uint8(round(255*pc_subsps(:,:,k)));

    % ¼ÆËãintra-scale local Feature map.
    % way == 1,max; way==2,min; way==3,add; way==4,multi.
    featMaps(:,:,k) = imresize(ExtLocalFeat_intraScale_both_adaptive(input,a,0.1,way),featMapSize);
end
% fprintf('2:%d',toc(t2));
% featMaps = normalizePicsRg1(featMaps);
for k = 1:size(featMaps,3)
    tmp_img = double(featMaps(:,:,k));
    tmp_min = min(tmp_img(:));
    tmp_max = max(tmp_img(:));
    if tmp_min==0 && tmp_max==255
        featMaps(:,:,k)=tmp_img/255.0;
    else
        featMaps(:,:,k)=(tmp_img-tmp_min)/(tmp_max-tmp_min+eps);
    end
   
end
% fclose(fid);