#!/usr/bin/env python

from __future__ import print_function

import os
import sys
import json

import scipy.misc
import PIL

from smiler_tools import utils
from smiler_tools import image_processing


def run_model(compute_saliency,
              input_dir='/opt/input_vol/',
              output_dir='/opt/output_vol/'):
    """
    Parameters:
        compute_saliency: function, (numpy array, PIL image, or
        input_dir
        output_dir
    """

    options = json.loads(os.environ['SMILER_PARAMETER_MAP'])
    options_overwrite = options.get('overwrite', False)
    options_recursive = options.get('recursive', False)
    options_verbose = options.get('verbose', False)
    target_uid = options.get('uid', 1000)
    target_gid = options.get('gid', 1000)

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    image_path_tuples = utils.get_image_path_tuples(
        input_dir, output_dir, recursive=options_recursive)

    real_stdout = sys.stdout
    real_stderr = sys.stdout
    if not options_verbose:
        sys.stdout = open('/dev/null', 'w')
        sys.stderr = open('/dev/null', 'w')

    num_paths = len(image_path_tuples)
    for img_number, path_tuple in enumerate(image_path_tuples):
        input_path = path_tuple[0]
        output_path = path_tuple[1]
        printable_input_path = os.path.relpath(input_path, input_dir)

        # If we aren't overwriting and the file exists, skip it.
        if not options_overwrite and os.path.isfile(output_path):
            print(
                "SKIP (already exists) image [{}/{}]: {}".format(
                    img_number + 1, num_paths, printable_input_path),
                file=real_stdout)
        else:
            print(
                "Running image [{}/{}]: {}".format(img_number + 1, num_paths,
                                                   printable_input_path),
                file=real_stdout)

            shm_image_path = "/dev/shm/smiler_shm_image.png"

            pre_processed_image = image_processing.pre_process(
                PIL.Image.open(input_path), options)
            scipy.misc.toimage(pre_processed_image).save(shm_image_path)

            saliency_map = compute_saliency(shm_image_path)

            post_processed_image = image_processing.post_process(
                saliency_map, options)

            image_processing.save_image(
                output_path,
                post_processed_image,
                uid=target_uid,
                gid=target_gid)
