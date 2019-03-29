# -*- coding: utf-8 -*-
import os
import subprocess
import time

import re
import tempfile
import zipfile
import urllib
import json
import grp
import getpass
import distutils.spawn

from smiler_tools import utils
from smiler_tools.parameters import ParameterMap

############################################################
# Constants
############################################################

HERE_PATH = os.path.dirname(os.path.realpath(__file__))
MATLAB_TOOLS_PATH = os.path.join(HERE_PATH, '..', '..', 'smiler_matlab_tools')

MODEL_BASE_URL = "https://www.eecs.yorku.ca/rspace-jtfarm/SMILER/"

NO_NVIDIA_DOCKER_WARNING_MSG = """WARNING: nvidia-docker not found!
See here for installation instructions:
https://github.com/NVIDIA/nvidia-docker
"""

############################################################
# Setup
############################################################

if distutils.spawn.find_executable("nvidia-docker"):
    NVIDIA_DOCKER_INSTALLED = True
else:
    NVIDIA_DOCKER_INSTALLED = False

############################################################
# Smiler Models
############################################################


class SMILERModel(object):
    def __init__(self, **kwargs):
        self.name = kwargs.get('name')
        self.long_name = kwargs.get('long_name')
        self.notes = kwargs.get('notes')

        citation = kwargs.get('citation')
        if isinstance(citation, list):
            citation = '\n'.join(citation)
        self.citation = citation

        self.version = kwargs.get('version')
        self.model_type = kwargs.get('model_type')
        self.invariant = kwargs.get('invariant', False)

        self.model_files = kwargs.get('model_files')
        self.parameter_map = ParameterMap()
        self.parameter_map.set_from_dict(kwargs.get('parameters', {}))

        self.path = kwargs.get('path')

        if None in (self.name, self.long_name, self.citation, self.model_files,
                    self.parameter_map, self.path, self.model_type,
                    self.version):
            raise ValueError("Invalid smiler.json file contents.")

    def run_batch(self,
                  input_dir,
                  output_dir,
                  config_parameter_map,
                  experiment_parameter_map=None):
        raise NotImplementedError()

    def shell(self):
        raise NotImplementedError()

    def maybe_run_setup(self):
        should_redownload = False
        for model_file in self.model_files:
            model_file_path = os.path.join(self.path, "model", model_file)
            if not os.path.exists(model_file_path):
                should_redownload = True
                break

        if should_redownload:
            print("Downloading and extracting model files:")
            for model_file in self.model_files:
                print("    " + model_file)
            self._download_and_extract_model_files()

    def _download_and_extract_model_files(self):
        url = MODEL_BASE_URL + self.name + "/model.zip"

        temp_dir_path = tempfile.mkdtemp()
        temp_file = "model.zip"
        temp_file_path = os.path.join(temp_dir_path, temp_file)

        urlopener = urllib.URLopener()
        try:
            urlopener.retrieve(url, temp_file_path)
            with zipfile.ZipFile(temp_file_path, 'r') as zip_fp:
                zip_fp.extractall(os.path.join(self.path, "model"))
        except IOError as e:
            print("IOError: {}".format(e))
        finally:
            os.remove(temp_file_path)
            os.rmdir(temp_dir_path)

    def remove_model_files(self):
        for model_file in self.model_files:
            model_file_path = os.path.join(self.path, "model", model_file)
            if os.path.exists(model_file_path):
                os.remove(model_file_path)


class DockerModel(SMILERModel):
    def __init__(self, **kwargs):
        super(DockerModel, self).__init__(**kwargs)

        self.docker_image = "{}:{}".format(
            kwargs.get('docker_image'), self.version)
        self.run_command = kwargs.get('run_command')
        self.shell_command = kwargs.get('shell_command')

        if None in (self.docker_image, self.run_command):
            raise ValueError("Invalid smiler.json file contents.")

    def _run_in_shell(self, command, docker_or_sudo=True, verbose=False):
        if docker_or_sudo:
            if getpass.getuser() in grp.getgrnam("docker").gr_mem:
                pass
            else:
                command = ["/usr/bin/sudo"] + command

        if verbose:
            print("Running:\n{}".format(command))
        rc = subprocess.call(command)
        return rc

    def run_batch(self,
                  input_dir,
                  output_dir,
                  config_parameter_map,
                  experiment_parameter_map=None):
        if not NVIDIA_DOCKER_INSTALLED:
            print(NO_NVIDIA_DOCKER_WARNING_MSG)
            print("Skipping...")
            return

        model_dir = os.path.join(self.path, 'model')

        # Override order:
        # config.json < smiler.json < experiment.yaml
        parameter_map = config_parameter_map.clone()
        parameter_map.update(self.parameter_map)
        parameter_map.update(experiment_parameter_map)

        model_run_command = [
            "nvidia-docker", "run", "-it", "--volume",
            "{}:/opt/model".format(model_dir), "--volume",
            "{}:/opt/input_vol".format(input_dir), "--volume",
            "{}:/opt/output_vol".format(output_dir), "--shm-size=128m", "-e",
            "SMILER_PARAMETER_MAP={}".format(
                json.dumps(
                    parameter_map.get_pair_dict())), "--rm", self.docker_image
        ] + self.run_command
        return self._run_in_shell(model_run_command)

    def shell(self):
        if not NVIDIA_DOCKER_INSTALLED:
            print(NO_NVIDIA_DOCKER_WARNING_MSG)
            return

        model_dir = os.path.join(self.path, 'model')

        model_run_command = [
            "nvidia-docker", "run", "-it", "--volume",
            "{}:/opt/model".format(model_dir), "-w", "/opt/model", "--rm",
            self.docker_image
        ] + self.shell_command

        return self._run_in_shell(model_run_command)

    def pull_latest_image(self):
        pull_image_command = ["docker", "pull", self.docker_image]
        return self._run_in_shell(pull_image_command)


class MATLABModel(SMILERModel):
    def run_batch(self,
                  input_dir,
                  output_dir,
                  config_parameter_map,
                  experiment_parameter_map=None):
        # Override order:
        # config.json < smiler.json < experiment.yaml
        parameter_map = config_parameter_map.clone()
        parameter_map.update(self.parameter_map)
        parameter_map.update(experiment_parameter_map)

        options_overwrite = parameter_map.get_val('overwrite')
        options_recursive = parameter_map.get_val('recursive')
        options_verbose = parameter_map.get_val('verbose')
        options_matlab_startup = parameter_map.get_val('matlab_startup')

        matlab_engine = utils.maybe_init_matlab_engine(
            matlab_tools_path=MATLAB_TOOLS_PATH,
            startup_options=options_matlab_startup,
            init_iSMILER=True)
        if matlab_engine is None:
            print("Matlab initialization failed.")
            return

        import matlab  # for catching exception below.

        if not os.path.exists(output_dir):
            os.mkdir(output_dir)

        image_path_tuples = utils.get_image_path_tuples(
            input_dir, output_dir, recursive=options_recursive)

        algo_wrapper_function = getattr(matlab_engine, self.name + "_wrap")

        num_paths = len(image_path_tuples)
        for img_number, path_tuple in enumerate(image_path_tuples):
            input_path = path_tuple[0]
            output_path = path_tuple[1]
            printable_input_path = os.path.relpath(input_path, input_dir)

            if not options_overwrite and os.path.exists(output_path):
                print("SKIP (already exists) image [{}/{}]: {}".format(
                    img_number + 1, num_paths, printable_input_path))
            else:
                try:
                    print("Running image [{}/{}]: {}".format(
                        img_number + 1, num_paths, printable_input_path))
                    img = matlab_engine.imread(input_path)

                    parameter_struct = parameter_map.get_matlab_struct(
                        matlab_engine)
                    salmap = algo_wrapper_function(img, parameter_struct)

                    utils.create_dirs_if_none(output_path)
                    matlab_engine.imwrite(salmap, output_path, nargout=0)
                except matlab.engine.MatlabExecutionError as e:
                    self._handle_error(e, input_path)

    def shell(self):
        matlab_engine = utils.maybe_init_matlab_engine(
            matlab_tools_path=MATLAB_TOOLS_PATH,
            startup_options="-desktop",
            init_iSMILER=True)

        if matlab_engine is None:
            print("Matlab initialization failed.")
            return

        # Hacky, because the MATLAB Python interface is... callow.
        import matlab
        try:
            while True:
                time.sleep(1)
                matlab_engine.eval("false")
        except (matlab.engine.EngineError, SystemError) as e:
            print("MATLAB engine closed.")
            return

    def _handle_error(self, e, img_path):
        print("[{}] Error processing image {}.".format(self.name, img_path))
        print(e)


############################################################
# Model Manager
############################################################


class ModelManager(object):
    MODEL_COLLECTIONS = {
        'all': 'All models except image invariant ones.',
        'docker': 'Deep models using nvidia-docker.',
        'matlab': 'Classical models using MATLAB.',
        'invariant': 'Image invariant models.'
    }

    def __init__(self, models_path):
        self._model_map = self.find_and_load_models(models_path)

    def find_and_load_models(self, start_path):
        def _yield_all_smiler_jsons(start_path):
            for dirpath, dirnames, filenames in os.walk(start_path):
                for filename in filenames:
                    if filename == "smiler.json":
                        yield os.path.join(dirpath, filename)

        models = {}
        for smiler_json_path in _yield_all_smiler_jsons(start_path):
            model = self.load_model(smiler_json_path)
            models[model.name.lower()] = model
        return models

    def load_model(self, smiler_json_path):
        try:
            with open(smiler_json_path) as fp:
                model_data = json.load(fp)
        except Exception as e:
            print("ERROR: Failed to read in {}".format(smiler_json_path))
            print(e)
            exit(2)

        model_path = os.path.realpath(os.path.dirname(smiler_json_path))
        model_data['path'] = model_path

        model_type = model_data.get('model_type')
        if model_type == 'docker':
            return DockerModel(**model_data)
        elif model_type == 'matlab':
            return MATLABModel(**model_data)
        else:
            msg = "Unknown model type {} in {}".format(model_type,
                                                       smiler_json_path)
            print("ERROR: " + msg)
            raise ValueError(msg)

    def get_matching(self, model_names):
        clean_names = [name for name in re.split("[ ,]", model_names) if name]

        result = set()
        for name in clean_names:
            if name in self.MODEL_COLLECTIONS:
                result.update(self.get_model_collection(name))
            elif name.lower() in self._model_map:
                result.add(self._model_map[name.lower()])
            else:
                possible_models = [
                    model.name for model in self._model_map.values()
                ]
                possible_models.sort()
                possible_models = self.MODEL_COLLECTIONS.keys(
                ) + possible_models
                msg = """Unknown model name '{}'
                Model should be one of:\n\t{}""".format(
                    name, ", ".join(possible_models))
                raise ValueError(msg)

        result_list = list(result)
        result_list.sort(key=lambda x: x.name)
        return result_list

    def get(self, model_name):
        return self.get_matching(model_name)[0]

    def get_model_collection(self, kind):
        if kind == 'all':
            return [
                model for key, model in self._model_map.items()
                if not model.invariant
            ]
        elif kind == 'docker':
            return [
                model for name, model in self._model_map.items()
                if model.model_type == "docker" and not model.invariant
            ]
        elif kind == 'matlab':
            return [
                model for name, model in self._model_map.items()
                if model.model_type == "matlab" and not model.invariant
            ]
        elif kind == 'invariant':
            return [
                model for key, model in self._model_map.items()
                if model.invariant
            ]
        else:
            raise ValueError("Unknown collection: {}.".format(kind))
