#!/usr/bin/env python

import os
import sys
import numpy as np

os.environ['GLOG_minloglevel'] = '3'  # Suppress logging.

from smiler_tools.runner import run_model

from Salicon import Salicon

if __name__ == "__main__":
    sal = Salicon()

    def compute_saliency(image_path):
        salmap = sal.compute_saliency(image_path)
        salmap /= salmap.max()
        salmap *= 255
        salmap = np.asarray(salmap, dtype=np.uint8)

        return salmap

    run_model(compute_saliency)
