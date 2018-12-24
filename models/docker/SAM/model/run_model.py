from __future__ import division
import os
import sys
import getopt
import json

import numpy as np
from keras.optimizers import RMSprop
from keras.layers import Input
from keras.models import Model
import cv2

from config import *
from utilities import preprocess_images, preprocess_maps, preprocess_fixmaps, postprocess_predictions
from models import sam_vgg, sam_resnet, kl_divergence, correlation_coefficient, nss

from smiler_tools.runner import run_model


def generator_test(b_s, imgs_test_path):
    images = [
        imgs_test_path + f for f in os.listdir(imgs_test_path)
        if f.endswith(('.jpg', '.jpeg', '.png'))
    ]
    images.sort()

    gaussian = np.zeros((b_s, nb_gaussian, shape_r_gt, shape_c_gt))

    counter = 0
    while True:
        yield [
            preprocess_images(images[counter:counter + b_s], shape_r, shape_c),
            gaussian
        ]
        counter = (counter + b_s) % len(images)


def main():
    options = json.loads(os.environ['SMILER_PARAMETER_MAP'])
    network_string = options.get('network', 'SAM-VGG')

    imgs_test_path = '/opt/input_vol/'
    output_folder = '/opt/output_vol/'

    os.makedirs(output_folder, exist_ok=True)

    x = Input((3, shape_r, shape_c))
    x_maps = Input((nb_gaussian, shape_r_gt, shape_c_gt))

    if network_string == "SAM-VGG":
        m = Model(input=[x, x_maps], output=sam_vgg([x, x_maps]))
        print("Compiling SAM-VGG...")
        m.compile(
            RMSprop(lr=1e-4),
            loss=[kl_divergence, correlation_coefficient, nss])

        print("Loading SAM-VGG weights...")
        m.load_weights('weights/sam-vgg_salicon_weights.pkl')
    elif network_string == "SAM-ResNet":
        m = Model(input=[x, x_maps], output=sam_resnet([x, x_maps]))
        print("Compiling SAM-ResNet...")
        m.compile(
            RMSprop(lr=1e-4),
            loss=[kl_divergence, correlation_coefficient, nss])

        print("Loading SAM-ResNet weights...")
        m.load_weights('weights/sam-resnet_salicon_weights.pkl')
    else:
        raise NotImplementedError(
            "The only supported network strings are SAM-VGG and SAM-ResNet! '{}' is unknown.".
            format(network_string))

    def compute_saliency(image_path):
        gaussian = np.zeros((b_s, nb_gaussian, shape_r_gt, shape_c_gt))


        predictions = m.predict_on_batch(
            preprocess_images([image_path], shape_r, shape_c))
        sm = predictions[0][0]

        original_image = cv2.imread(image_path, 0)
        res = postprocess_predictions(sm, original_image.shape[0],
                                      original_image.shape[1])
        return res

    run_model(compute_saliency)


if __name__ == "__main__":
    main()
