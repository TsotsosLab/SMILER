import os
import unittest

import utils

HERE_PATH = os.path.dirname(os.path.realpath(__file__))


class TestPrePostProcessing(unittest.TestCase):
    def setUp(self):
        self.matlab_engine = utils.init_matlab_engine()
        self.img_path = os.path.join(
            HERE_PATH, "../examples/input_images/bar_colours.png")

        self.parameter_map = utils.get_parameter_map()
        self.parameter_dict = self.parameter_map.get_pair_dict()
        self.parameter_struct = self.parameter_map.get_matlab_struct(
            self.matlab_engine)

        self.img_matlab = utils.load_image_matlab(self.img_path,
                                                  self.matlab_engine)
        self.img_python = utils.load_image_python(self.img_path)

    def _assert_parameter_equivalence(self, key, value):
        self.parameter_dict[key] = value
        self.parameter_struct[key] = value

        img_matlab = utils.matlab_pre_and_post(
            self.img_matlab, self.parameter_struct, self.matlab_engine)
        img_py = utils.python_pre_and_post(self.img_python,
                                           self.parameter_dict)

        utils.assert_images_are_similar(img_matlab, img_py)

    ############################################################
    # Color Space.

    def test_equivalence_color_space_default(self):
        self._assert_parameter_equivalence('color_space', 'default')

    def test_equivalence_color_space_rgb(self):
        self._assert_parameter_equivalence('color_space', 'RGB')

    def test_equivalence_color_space_gray(self):
        self._assert_parameter_equivalence('color_space', 'gray')

    def test_equivalence_color_space_ycbcr(self):
        self._assert_parameter_equivalence('color_space', 'YCbCr')

    def test_equivalence_color_space_lab(self):
        self._assert_parameter_equivalence('color_space', 'LAB')

    def test_equivalence_color_space_hsv(self):
        self._assert_parameter_equivalence('color_space', 'HSV')

    ############################################################
    # Smoothing.

    def test_equivalence_do_smoothing_default(self):
        self._assert_parameter_equivalence('do_smoothing', 'default')

    def test_equivalence_do_smoothing_none(self):
        self._assert_parameter_equivalence('do_smoothing', 'none')

    def test_equivalence_do_smoothing_custom(self):
        self._assert_parameter_equivalence('do_smoothing', 'custom')

    def test_equivalence_do_smoothing_proportional(self):
        self._assert_parameter_equivalence('do_smoothing', 'proportional')

    ############################################################
    # Scale Output.

    def test_equivalence_scale_output_default(self):
        self._assert_parameter_equivalence('scale_output', 'default')

    def test_equivalence_scale_output_min_max(self):
        self._assert_parameter_equivalence('scale_output', 'min-max')

    def test_equivalence_scale_output_normalized(self):
        self._assert_parameter_equivalence('scale_output', 'normalized')

    def test_equivalence_scale_output_log_density(self):
        self._assert_parameter_equivalence('scale_output', 'log-density')

    ############################################################
    # Center Prior.

    def test_equivalence_center_prior_default(self):
        self._assert_parameter_equivalence('center_prior', 'default')

    def test_equivalence_center_prior_none(self):
        self._assert_parameter_equivalence('center_prior', 'none')

    def test_equivalence_center_prior_proportional_add(self):
        self._assert_parameter_equivalence('center_prior', 'proportional_add')

    def test_equivalence_center_prior_proportional_mult(self):
        self._assert_parameter_equivalence('center_prior', 'proportional_mult')

    ############################################################
    # CLI vs MATLAB.

    def test_cli_and_matlab_equivalence(self):
        algorithm_name = 'AIM'

        shell_image = utils.saliency_via_shell_interface(
            algorithm_name, self.img_path)
        matlab_image = utils.saliency_via_MATLAB_interface(
            algorithm_name, self.img_path, self.matlab_engine)

        utils.assert_images_are_similar(matlab_image, shell_image)


if __name__ == '__main__':
    unittest.main()
