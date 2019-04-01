from os import listdir, makedirs
from os.path import isfile, join
import sys, getopt

import numpy as np
import os
import sys
import time
import cv2

sys.path.insert(0, '/opt/caffe/python')

import caffe

from smiler_tools.runner import run_model

EPSILON = 1e-8
IMAGE_DIM = 224


def prepare_image(img):
    im = np.array(img, dtype=np.float32)
    im -= np.array((103.9390, 116.7790, 123.6800))
    im = cv2.resize(im, (IMAGE_DIM, IMAGE_DIM), interpolation=cv2.INTER_LINEAR)
    im = im[..., ::-1]
    im = np.transpose(im, (2, 0, 1))
    return im


def main():
    #remove the following two lines if testing with cpu
    caffe.set_mode_gpu()
    # choose which GPU you want to use
    caffe.set_device(0)
    caffe.SGDSolver.display = 0
    # load net
    net = caffe.Net('models/attention_test.prototxt', 'models/attention_final',
                    caffe.TEST)

    def compute_saliency(image_path):
        img = cv2.imread(image_path, cv2.IMREAD_COLOR)
        im = prepare_image(img)

        # shape for input (data blob is N x C x H x W), set data
        net.blobs['data'].reshape(1, *im.shape)
        net.blobs['data'].data[...] = im
        # run net and take argmax for prediction
        res = net.forward()
        salmap = np.squeeze(res['final_attentionmap'])
        salmap /= np.max(salmap)
        im = cv2.resize(
            salmap, (IMAGE_DIM, IMAGE_DIM), interpolation=cv2.INTER_LINEAR)
        salmap = cv2.resize(
            salmap, (img.shape[1], img.shape[0]),
            interpolation=cv2.INTER_LINEAR)

        return (salmap * 255).astype(np.uint8)

    run_model(compute_saliency)


if __name__ == "__main__":
    main()
