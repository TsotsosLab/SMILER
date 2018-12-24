#Modified main.py to run MLNet on single images
#Modified by: Iuliia Kotseruba

from __future__ import division

import os
from os import listdir
from os.path import isfile, join
os.environ['KERAS_BACKEND'] = 'theano'

from keras.optimizers import SGD
from keras.callbacks import EarlyStopping, ModelCheckpoint
import cv2, sys
import numpy as np
from config import *
from utilities import preprocess_images, preprocess_maps, postprocess_predictions
from model import ml_net_model, loss

from smiler_tools.runner import run_model


def generator(b_s, phase_gen='train'):
    if phase_gen == 'train':
        images = [
            join(imgs_train_path, f) for f in listdir(imgs_train_path)
            if isfile(join(imgs_train_path, f))
        ]
        maps = [
            join(maps_train_path, f) for f in listdir(maps_train_path)
            if isfile(join(maps_train_path, f))
        ]
    elif phase_gen == 'val':
        images = [
            join(imgs_val_path, f) for f in listdir(imgs_val_path)
            if isfile(join(imgs_val_path, f))
        ]
        maps = [
            join(maps_val_path, f) for f in listdir(maps_val_path)
            if isfile(join(maps_val_path, f))
        ]
    else:
        raise NotImplementedError

    images.sort()
    maps.sort()

    counter = 0
    while True:
        yield preprocess_images(
            images[counter:counter + b_s], shape_r, shape_c), preprocess_maps(
                maps[counter:counter + b_s], shape_r_gt, shape_c_gt)
        counter = (counter + b_s) % len(images)


if __name__ == '__main__':
    phase = 'test'

    model = ml_net_model(
        img_cols=shape_c, img_rows=shape_r, downsampling_factor_product=10)
    sgd = SGD(lr=1e-3, decay=0.0005, momentum=0.9, nesterov=True)
    print("Compiling ML-Net Model...")
    model.compile(sgd, loss)
    print("Done")

    if phase == 'train':
        print("Training ML-Net")
        model.fit_generator(
            generator(b_s=b_s),
            nb_imgs_train,
            nb_epoch=nb_epoch,
            validation_data=generator(b_s=b_s, phase_gen='val'),
            nb_val_samples=nb_imgs_val,
            callbacks=[
                EarlyStopping(patience=5),
                ModelCheckpoint(
                    'weights.mlnet.{epoch:02d}-{val_loss:.4f}.pkl',
                    save_best_only=True)
            ])

    elif phase == "test":
        model.load_weights('mlnet_salicon_weights.pkl')

        def compute_saliency(img_path):
            pred = model.predict_on_batch(
                preprocess_images([img_path], shape_r, shape_c))
            sm = pred[0][0]

            original_image = cv2.imread(img_path, 0)
            sm = postprocess_predictions(sm, original_image.shape[0],
                                         original_image.shape[1])
            return sm

        run_model(compute_saliency)
    else:
        raise NotImplementedError
