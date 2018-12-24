#!/usr/bin/env python

import os
import sys

os.environ['GLOG_minloglevel'] = '3'  # Suppress logging.

from smiler_tools.runner import run_model

from Salicon import Salicon

if __name__ == "__main__":
    sal = Salicon()

    def compute_saliency(image_path):
        return sal.compute_saliency(image_path)

    run_model(compute_saliency)
