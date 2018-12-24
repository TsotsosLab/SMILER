function run_FES(input_dir, output_dir, center_bias)

imgList = dir([input_dir '/*.jpg']);
mkdir(output_dir);

for i = 1:numel(imgList)
    %% load a RGB image
    img = imread([input_dir '/' imgList(i).name]);
    [x, y, z] = size(img);
    if z < 3
        img = repmat(img, [1, 1, 3]);
    end

    %% transform it to LAB
    img = RGB2Lab(img);

    %% laod a prior or perform uniform initialization

    if center_bias
        load('prior');
    else
        p1 = 0.5*ones(128, 171); % uncomment for uniform initialization
    end
    
    %% compute the saliency
    % function saliency = computeFinalSaliency(image, pScale, sScale, alpha, sigma0, sigma1, p1)
    saliency = computeFinalSaliency(img, [8 8 8], [13 25 38], 30, 10, 1, p1);
    saliency = (saliency - min(saliency(:))) / (max(saliency(:)) - min(saliency(:)));
    saliency = imresize(saliency, [x,y]);
    imwrite(saliency, strjoin({output_dir, imgList(i).name}, '/'));
    %imshow(saliency);
end
