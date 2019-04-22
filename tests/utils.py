import sys
import os
import subprocess
import tempfile
import shutil

import numpy as np
import scipy
import PIL

HERE_PATH = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(HERE_PATH, '..', 'smiler_tools'))

import smiler_tools.utils
import smiler_tools.config
import smiler_tools.image_processing


def similarity_score(sal_map_1, sal_map_2):
    """Linear correlation coefficient."""
    sal_map_1 = np.asarray(sal_map_1, dtype=np.float32)
    sal_map_2 = np.asarray(sal_map_2, dtype=np.float32)

    if sal_map_1.min() == -np.inf:
        sal_map_1_desired_min = np.nanmin(sal_map_1[sal_map_1 != -np.inf])
        sal_map_1[sal_map_1 == -np.inf] = sal_map_1_desired_min

    if sal_map_2.min() == -np.inf:
        sal_map_2_desired_min = np.nanmin(sal_map_2[sal_map_2 != -np.inf])
        sal_map_2[sal_map_2 == -np.inf] = sal_map_2_desired_min

    if sal_map_1.max() == np.inf:
        sal_map_1_desired_max = np.nanmax(sal_map_1[sal_map_1 != np.inf])
        sal_map_1[sal_map_1 == np.inf] = sal_map_1_desired_max

    if sal_map_2.max() == np.inf:
        sal_map_2_desired_max = np.nanmax(sal_map_2[sal_map_2 != np.inf])
        sal_map_2[sal_map_2 == np.inf] = sal_map_2_desired_max

    if sal_map_1.size != sal_map_2.size:
        sal_map_2 = scipy.misc.imresize(sal_map_2, sal_map_1.shape)

    sal_map_1 = (sal_map_1 - sal_map_1.mean()) / (sal_map_1.std())
    sal_map_2 = (sal_map_2 - sal_map_2.mean()) / (sal_map_2.std())

    score = np.corrcoef(sal_map_1.flatten(), sal_map_2.flatten())[0][1]

    return score


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


def assert_images_are_similar(img1, img2, tolerance=0.99):
    img1 = np.asarray(img1)
    img2 = np.asarray(img2)
    assert img1.shape == img2.shape

    cc_score = similarity_score(img1, img2)
    assert cc_score > tolerance


def saliency_via_shell_interface(algorithm_name, image_path):
    PATH_TO_CLI = os.path.join(HERE_PATH, '../smiler')

    with tempfile.TemporaryDirectory() as tmp_indir:
        image_name = os.path.basename(image_path)
        shutil.copyfile(image_path, os.path.join(tmp_indir, image_name))

        with tempfile.TemporaryDirectory() as tmp_outdir:
            run_command = [
                PATH_TO_CLI, 'run', '-m', algorithm_name, tmp_indir, tmp_outdir
            ]
            subprocess.call(run_command)

            output_path = os.path.join(tmp_outdir, algorithm_name, image_name)
            output_image = load_image_python(output_path)
            return np.asarray(output_image)


def saliency_via_MATLAB_interface(algorithm_name, image_path, matlab_engine):
    algo_wrapper_function = getattr(matlab_engine, algorithm_name + "_wrap")
    image = load_image_matlab(image_path, matlab_engine)

    salmap = algo_wrapper_function(image, {})

    image_name = os.path.basename(image_path)

    # Write image to disk and load it again for consistency with shell interface.
    with tempfile.TemporaryDirectory() as tmp_outdir:
        output_path = os.path.join(tmp_outdir, image_name)
        matlab_engine.imwrite(salmap, output_path, nargout=0)
        return np.asarray(load_image_python(output_path))
