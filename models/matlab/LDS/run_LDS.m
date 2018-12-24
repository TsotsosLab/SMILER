function run_LDS(input_dir, output_dir)
    imgList = dir([input_dir '/*.jpg']);
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    load('model.mat'); % Chose a fast model.       |
    lab_pca_book = load('LAB_pca.mat');

    for i = 1:numel(imgList)
        imgpath = sprintf('%s/%s', input_dir, imgList(i).name);
        img = imread(imgpath);
        [sm] = GetSaliencyMap(imgpath,x,lab_pca_book);

        %% Post process.
        % First. GBVS normalization.
        sm = imresize(gbvsNorm(sm),size(sm));
        sm = imfilter(sm, fspecial('gaussian', [5,5],2.5));
        MaxValue = max(max(sm));
        MinValue = min(min(sm));
        sm = uint8(round((sm - MinValue) / (MaxValue - MinValue + eps) * 255.0));

        sm = imresize(sm, [size(img,1), size(img, 2)]);
        imwrite(sm, sprintf('%s/%s', output_dir, imgList(i).name));
    end

end
