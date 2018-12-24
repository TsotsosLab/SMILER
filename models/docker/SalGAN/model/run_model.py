import os
import sys
import json

import cv2

from smiler_tools.runner import run_model

HERE_PATH = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(HERE_PATH, 'scripts'))

from utils import *
from constants import *
from models.model_bce import ModelBCE


def main():
    options = json.loads(os.environ['SMILER_PARAMETER_MAP'])
    use_default_blur = options.get('do_smoothing', 'default') == 'default'

    # Create network
    model = ModelBCE(INPUT_SIZE[0], INPUT_SIZE[1], batch_size=8)
    # Here need to specify the epoch of model sanpshot
    load_weights(model.net['output'], path='gen_', epochtoload=90)

    def compute_saliency(image_path):
        img = cv2.cvtColor(
            cv2.imread(image_path, cv2.IMREAD_COLOR), cv2.COLOR_BGR2RGB)

        size = (img.shape[1], img.shape[0])
        blur_size = 5

        if img.shape[:2] != (model.inputHeight, model.inputWidth):
            img = cv2.resize(
                img, (model.inputWidth, model.inputHeight),
                interpolation=cv2.INTER_AREA)

        blob = np.zeros((1, 3, model.inputHeight, model.inputWidth),
                        theano.config.floatX)

        blob[0, ...] = (img.astype(theano.config.floatX).transpose(2, 0, 1))

        result = np.squeeze(model.predictFunction(blob))
        saliency_map = (result * 255).astype(np.uint8)

        # resize back to original size
        saliency_map = cv2.resize(
            saliency_map, size, interpolation=cv2.INTER_CUBIC)
        # blur
        if use_default_blur:
            saliency_map = cv2.GaussianBlur(saliency_map,
                                            (blur_size, blur_size), 0)
        # clip again
        saliency_map = np.clip(saliency_map, 0, 255)

        return saliency_map

    run_model(compute_saliency)


if __name__ == "__main__":
    main()
