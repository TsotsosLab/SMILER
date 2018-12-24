function [rlt] = normalizeOnePicRg1(pic)
%Normalize each matric in a picMtrxs.
%Namely, nomalize picMtrxs(:,:,k) { k = 1:size(picMtrxs,3) }
%results are stored in rlt_picMtrxs, remember to release it when need.

pic = double(pic);
tmp_min = min(pic(:));
tmp_max = max(pic(:));
rlt = (pic-tmp_min)/(tmp_max-tmp_min+eps);