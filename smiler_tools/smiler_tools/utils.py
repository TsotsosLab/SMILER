import os
import textwrap

import scipy.misc


def create_dirs_if_none(path, uid=None, gid=None):
    if uid is None:
        uid = os.getuid()

    if gid is None:
        gid = os.getgid()

    parent_path = os.path.dirname(path)
    if not os.path.isdir(parent_path):
        os.makedirs(parent_path)
        os.chown(parent_path, uid, gid)


def save_image(path, image, create_parent=True, uid=None, gid=None):
    if uid is None:
        uid = os.getuid()

    if gid is None:
        gid = os.getgid()

    if create_parent:
        create_dirs_if_none(path, uid=uid, gid=gid)

    scipy.misc.imsave(path, image)
    os.chown(path, uid, gid)


def get_image_path_map(input_dir, output_dir, recursive=False):
    if recursive:
        image_path_map = {}
        for dirpath, dirnames, filenames in os.walk(input_dir):
            for filename in filenames:
                input_path = os.path.join(dirpath, filename)
                output_path = os.path.join(output_dir,
                                           os.path.relpath(dirpath, input_dir),
                                           filename)
                image_path_map[input_path] = output_path
    else:
        image_path_map = {
            os.path.join(input_dir, f): os.path.join(output_dir, f)
            for f in os.listdir(input_dir)
            if os.path.isfile(os.path.join(input_dir, f))
        }

    return image_path_map


def print_pretty_header(header_text, width=60):
    print("*" * width)
    print(" {} ".format(header_text).center(width, "*"))
    print("*" * width)


def pretty_print_parameters(parameter_list):
    parameters = sorted(parameter_list, key=lambda x: x.name)
    for param in parameters:
        print('')
        print(param.name)
        print('    Default:      {}'.format(param.value))
        if (param.description):
            print('    Description:  {}'.format('\n                  '.join(
                textwrap.wrap(param.description, break_on_hyphens=False))))
        if (param.valid_values):
            print('    Valid Values: {}'.format('\n                   '.join(
                textwrap.wrap(str(param.valid_values)))))


def maybe_init_matlab_engine(startup_options="-nodesktop", init_iSMILER=False):
    """
    Only creates a matlab engine and initializes iSMILER the first time it is run.
    """
    NO_MATLAB_WARNING_MSG = """WARNING: MATLAB Engine API for Python not found!
    See here for installation instructions:
    https://www.mathworks.com/help/matlab/matlab_external/get-started-with-matlab-engine-for-python.html
    """

    try:
        import matlab.engine
    except ImportError as e:
        print(NO_MATLAB_WARNING_MSG)
        return None

    if maybe_init_matlab_engine._matlab_engine is None:
        eng = matlab.engine.start_matlab(str(startup_options))
        if init_iSMILER:
            eng.cd('smiler_matlab_tools')
            eng.iSMILER(nargout=0)
        maybe_init_matlab_engine._matlab_engine = eng

    return maybe_init_matlab_engine._matlab_engine


maybe_init_matlab_engine._matlab_engine = None
