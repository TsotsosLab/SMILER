# coding: utf-8

# DeepGaze expects its input to have a resolution of 35 pixel per degree of
# visual angle. If your stimuli have a different resolution, you have to
# rescale them before processing them with DeepGaze, otherwise you will get
# wrong predictions.

import os
import json

import numpy as np
from scipy.ndimage import zoom, imread
from scipy.misc import logsumexp
import cv2

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' # Suppress logging.
import tensorflow as tf

from smiler_tools.runner import run_model


def main():
    options = json.loads(os.environ['SMILER_PARAMETER_MAP'])
    center_bias_path = 'centerbias.npy'
    use_center_bias = options.get('center_prior', 'default') == 'default'

    # load precomputed log density over a 1024x1024 image
    centerbias_template = np.load(center_bias_path)

    # Now we import the deep gaze model from the tensorflow meta-graph file
    tf.reset_default_graph()

    check_point = 'ICF.ckpt'
    saver = tf.train.import_meta_graph('{}.meta'.format(check_point))

    input_tensor = tf.get_collection('input_tensor')[0]
    centerbias_tensor = tf.get_collection('centerbias_tensor')[0]
    log_density = tf.get_collection('log_density')[0]
    log_density_wo_centerbias = tf.get_collection('log_density_wo_centerbias')[
        0]

    sess = tf.Session()
    saver.restore(sess, check_point)

    def compute_saliency(image_path):
        img = imread(image_path, mode='RGB')

        image_data = img[np.newaxis, :, :, :]  # BHWC, three channels (RGB)

        # Set up center bias
        centerbias = zoom(
            centerbias_template, (img.shape[0] / 1024, img.shape[1] / 1024),
            order=0,
            mode='nearest')

        # Renormalize log density
        centerbias -= logsumexp(centerbias)

        # The model expects all input as 4d tensors of shape `BHWC` (i.e. batch-height-
        # width-channel). It takes two inputs:
        # A batch of images and a batch of centerbias log densities.
        centerbias_data = centerbias[
            np.newaxis, :, :, np.newaxis]  # BHWC, 1 channel (log density)

        # And finally we create a tensorflow session, restore the model parameters from
        # the checkpoint and compute the log density prediction for out input data:
        if use_center_bias:
            log_density_prediction = sess.run(
                log_density, {
                    input_tensor: image_data,
                    centerbias_tensor: centerbias_data,
                })
        else:
            # TODO: In this case, don't calculate centerbias in the first place.
            log_density_prediction = sess.run(
                log_density_wo_centerbias, {
                    input_tensor: image_data,
                    centerbias_tensor: np.zeros_like(centerbias_data),
                })

        # The log density predictions again are of shape `BHWC`. Since the log-densities
        # are just 2d, `C=1`. And since we processed only one image, `B=1`:

        log_density_out = log_density_prediction[0, :, :, 0]
        sm = np.exp(log_density_out)
        sm /= np.sum(sm)
        cv2.normalize(sm, sm, 0, 255, cv2.NORM_MINMAX)

        return sm

    run_model(compute_saliency)


if __name__ == "__main__":
    main()
