#!/usr/bin/env python

import os
import sys
import subprocess
import json

import numpy as np
import PIL

from smiler_tools.runner import run_model

if __name__ == "__main__":
    output_path = "/dev/shm/bms_output.png"

    options = json.loads(os.environ['SMILER_PARAMETER_MAP'])
    sample_step = options.get('sample_step', 8)

    dilation_width_1 = options.get('dilation_width_1', 7)
    dilation_width_2 = options.get('dilation_width_2', 9)

    do_smoothing = options.get('do_smoothing', 'default')

    color_space = options.get('color_space', 'default')
    whitening = options.get('whitening', True)

    max_dim = options.get('max_dim', 400)

    whitening = 1 if whitening else 0

    if color_space == 'default':
        colorspace = 2
    else:
        colorspace = 1

    if do_smoothing == 'default':
        blur_std = 9
    else:
        blur_std = 0

    def compute_saliency(image_path):
        command = [
            "./build/BMS", image_path, output_path, sample_step,
            dilation_width_1, dilation_width_2, blur_std, colorspace,
            whitening, max_dim
        ]
        command = list(map(str, command))
        rc = subprocess.call(command)

        if rc != 0:
            return

        # TODO: FIXME a hack for SMILER integration.
        output_img = PIL.Image.open(output_path)
        return np.array(output_img)

    run_model(compute_saliency)
