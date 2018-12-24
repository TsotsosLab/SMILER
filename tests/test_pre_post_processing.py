import os
import unittest

import utils

HERE_PATH = os.path.dirname(os.path.realpath(__file__))


class TestBasicSetup(unittest.TestCase):
    def setUp(self):
        self.matlab_engine = utils.init_matlab_engine()
        self.img_path = os.path.join(HERE_PATH, "../examples/input_images/bar_colours.png")

        self.parameter_map = utils.get_parameter_map()
        self.parameter_dict = self.parameter_map.get_pair_dict()
        self.parameter_struct = self.parameter_map.get_matlab_struct(
            self.matlab_engine)

        self.img_matlab = utils.load_image_matlab(self.img_path,
                                                  self.matlab_engine)
        self.img_python = utils.load_image_python(self.img_path)

    def test_equivalence_color_space(self):
        self.parameter_dict['color_space'] = 'HSV'
        self.parameter_struct['color_space'] = 'HSV'

        img_matlab = utils.matlab_pre_and_post(
            self.img_matlab, self.parameter_struct, self.matlab_engine)
        img_py = utils.python_pre_and_post(self.img_python,
                                           self.parameter_dict)

        utils.ensure_matlab_and_python_similar(img_matlab, img_py)

    def test_equivalence_smoothing(self):
        self.parameter_dict['do_smoothing'] = 'proportional'
        self.parameter_struct['do_smoothing'] = 'proportional'

        img_matlab = utils.matlab_pre_and_post(
            self.img_matlab, self.parameter_struct, self.matlab_engine)
        img_py = utils.python_pre_and_post(self.img_python,
                                           self.parameter_dict)

        utils.ensure_matlab_and_python_similar(img_matlab, img_py)

    def test_equivalence_scaling(self):
        self.parameter_dict['scale_output'] = 'min-max'
        self.parameter_struct['scale_output'] = 'min-max'

        img_matlab = utils.matlab_pre_and_post(
            self.img_matlab, self.parameter_struct, self.matlab_engine)
        img_py = utils.python_pre_and_post(self.img_python,
                                           self.parameter_dict)

        utils.ensure_matlab_and_python_similar(img_matlab, img_py)

    def test_equivalence_center_prior(self):
        self.parameter_dict['center_prior'] = 'proportional_add'
        self.parameter_struct['center_prior'] = 'proportional_add'

        img_matlab = utils.matlab_pre_and_post(
            self.img_matlab, self.parameter_struct, self.matlab_engine)
        img_py = utils.python_pre_and_post(self.img_python,
                                           self.parameter_dict)

        utils.ensure_matlab_and_python_similar(img_matlab, img_py)


if __name__ == '__main__':
    unittest.main()
