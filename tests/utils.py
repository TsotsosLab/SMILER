import sys
import os

import numpy as np
import PIL

HERE_PATH = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(HERE_PATH, '..', 'smiler_tools'))

import smiler_tools.utils
import smiler_tools.config
import smiler_tools.image_processing


def load_image_matlab(image_path, matlab_engine):
    img = matlab_engine.imread(image_path)
    return img


def load_image_python(image_path):
    img = PIL.Image.open(image_path)
    return img


def init_matlab_engine():
    eng = smiler_tools.utils.maybe_init_matlab_engine(
        matlab_tools_path=os.path.join(HERE_PATH, '..', 'smiler_matlab_tools'),
        init_iSMILER=True)
    return eng


def get_parameter_map():
    config = smiler_tools.config.SmilerConfig(
        os.path.join(HERE_PATH, '..', "config.json"))
    return config.parameter_map


def matlab_pre_and_post(img, parameter_struct, eng):
    img = eng.checkImgInput(img, parameter_struct['color_space'], True)
    img = eng.mean(img, 3)
    img = eng.fmtOutput(img, parameter_struct)
    return img


def python_pre_and_post(img, parameter_dict):
    img = smiler_tools.image_processing.pre_process(img, parameter_dict)
    img = img.mean(axis=2)
    img = smiler_tools.image_processing.post_process(img, parameter_dict)
    return img


def ensure_matlab_and_python_similar(img_matlab, img_python):
    img_matlab = np.asarray(img_matlab)
    assert img_matlab.shape == img_python.shape
