
addpath(genpath('external/gbvs'));

load('model.mat'); % Chose a fast model.       |
lab_pca_book = load('LAB_pca.mat');

imgpath = 'Image_17.png';
tic;
[sm] = GetSaliencyMap(imgpath,x,lab_pca_book);
toc;
imwrite(sm,'salmap.png');
