function [pyr] = feat_myScaleBuild(img,level,downSRatio,winSize, sigma)

% cause
img = double(img);
pyr = cell(level+1,1);



pyr{1} = img;
if level > 0
    filter = fspecial('gaussian',[winSize,winSize],sigma);
    gauss_img = img;
    counter = 2;
    for scaleId = 2:level+1
        gauss_img = imfilter(gauss_img,filter,'replicate');
        pyr{counter} = imresize(gauss_img,downSRatio^(scaleId-1));
        %     imwrite(uint8(round(gauss_img)),['fs\' num2str(scaleId) '.png']);
        %     imshow(pyr{counter},[]);
        %     system('pause');
        counter = counter + 1;
    end
end


