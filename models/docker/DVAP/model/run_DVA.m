function run_DVA(input_dir, output_dir)

    if ~exist('input_dir', 'var') || ~exist('output_dir', 'var')
        error('ERROR: did not provide input and/or output directories');
    end

    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    if ~exist(input_dir, 'dir')
        error('ERROR: input directory does not exist!');
    end

    opts.vocal = true;
    opts.caffe_version          = 'caffe_faster_rcnn';
    opts.gpu_id                 = auto_select_gpu;
    active_caffe_mex(opts.gpu_id, opts.caffe_version);
    opts.use_gpu                = true;

    attention_model_dir              = fullfile(pwd, 'models'); %% VGG
    attention_model                  = load_model(attention_model_dir);

    attention_net = caffe.Net(attention_model.attention_net_def, 'test');
    attention_net.copy_from(attention_model.attention_net);


    %read all images, add extensions as needed
    imgList = [dir([input_dir '/*.png']); dir([input_dir '/*.jpg']); dir([input_dir '/*.jpeg'])];


    for i = 1:length(imgList)
        image = imread(sprintf('%s/%s', input_dir, imgList(i).name));
        [w,h,c] = size(image);
        if c ~= 3
            image = repmat(image, [1 1 3]);
        end
%       if opts.use_gpu
%           im = gpuArray(image);
%       end
        [~, ~, ~, final_attentionmap] = fixationmap_detect(attention_model.conf, attention_net, image);
        final_attentionmap  = imresize(final_attentionmap,[w,h]);
        imwrite(final_attentionmap, sprintf('%s/%s', output_dir, imgList(i).name));
    end

end
