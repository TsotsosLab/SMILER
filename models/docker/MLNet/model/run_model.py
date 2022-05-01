#Modified main.py to run MLNet on single images
#Modified by: Iuliia Kotseruba

from __future__ import division

import os
import json
os.environ['KERAS_BACKEND'] = 'theano'

from keras.optimizers import SGD
from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras import backend as K
import cv2, sys
import numpy as np
from config import *
from utilities import preprocess_images, preprocess_maps, postprocess_predictions
from model import ml_net_model, loss

from smiler_tools.runner import run_model

if __name__ == '__main__':
    options = json.loads(os.environ['SMILER_PARAMETER_MAP'])
    use_default_center_bias = options.get('center_prior',
                                          'default') == 'default'

    model = ml_net_model(
        img_cols=shape_c, img_rows=shape_r, downsampling_factor_product=10)
    sgd = SGD(lr=1e-3, decay=0.0005, momentum=0.9, nesterov=True)

    print("Compiling ML-Net Model...")
    model.compile(sgd, loss)
    print("Done")

    model.load_weights('mlnet_salicon_weights.pkl')

    def compute_saliency(image_path):
        if use_default_center_bias:
            pred = model.predict_on_batch(
                preprocess_images([image_path], shape_r, shape_c))
            sm = pred[0][0]
        else:
            get_unbiased_output = K.function(
                [model.layers[0].input,
                 K.learning_phase()], [model.layers[21].output])
            pred = get_unbiased_output(
                [preprocess_images([image_path], shape_r, shape_c), 0])
            sm = pred[0][0][0]

        original_image = cv2.imread(image_path, 0)
        sm = postprocess_predictions(sm, original_image.shape[0],
                                     original_image.shape[1])
        return sm

    run_model(compute_saliency)
