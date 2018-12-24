import os
import yaml

from smiler_tools import utils
from smiler_tools.parameters import ParameterMap


class Experiment(object):
    def __init__(self, model_manager, config_parameter_map):
        self._model_manager = model_manager
        self._config_parameter_map = config_parameter_map.clone()
        self._experiment_parameter_map = ParameterMap()

        self._runs = []

        self._yaml_path = None
        self._name = None
        self._description = None

        self._input_path = None
        self._base_output_path = None

    def _realpath_relative_to_yaml(self, file_path_relative_to_yaml):
        if self._yaml_path:
            yaml_path_dirname = os.path.dirname(
                os.path.realpath(self._yaml_path))
            file_path_real = os.path.join(yaml_path_dirname,
                                          file_path_relative_to_yaml)
            return file_path_real

    def set_from_yaml(self, yaml_fp):
        self._yaml_path = yaml_fp.name

        yaml_map = yaml.safe_load(yaml_fp)
        experiment_map = yaml_map['experiment']
        runs_list = yaml_map['runs']

        self._name = experiment_map['name']
        self._description = experiment_map['description']

        self._input_path = self._realpath_relative_to_yaml(
            experiment_map['input_path'])

        self._base_output_path = self._realpath_relative_to_yaml(
            experiment_map['base_output_path'])

        for param_name, param_val in experiment_map.get('parameters',
                                                        {}).items():
            self._experiment_parameter_map.set(param_name, param_val)

        for run_map in runs_list:
            for model in self._model_manager.get_matching(
                    run_map['algorithm']):

                output_path = self._realpath_relative_to_yaml(
                    run_map.get('output_path',
                                os.path.join(self._base_output_path,
                                             model.name)))

                experiment_run_parameter_map = ParameterMap()
                for key, val in run_map.get('parameters', {}).items():
                    experiment_run_parameter_map.set(key, val)

                run = ExperimentRun(model, self._input_path, output_path,
                                    self._config_parameter_map,
                                    experiment_run_parameter_map)
                self._runs.append(run)

    def set_from_models_string(self, models_string, input_path,
                               base_output_path):

        selected_models = self._model_manager.get_matching(models_string)

        for selected_model in selected_models:
            output_path = os.path.join(base_output_path, selected_model.name)
            run = ExperimentRun(selected_model, input_path, output_path,
                                self._config_parameter_map)
            self._runs.append(run)

    def run(self):
        for run in self._runs:
            run.run(self._experiment_parameter_map)


class ExperimentRun(object):
    def __init__(self,
                 model,
                 input_path,
                 output_path,
                 config_parameter_map,
                 experiment_run_parameter_map=None):
        self._model = model
        self._input_path = input_path
        self._output_path = output_path
        self._config_parameter_map = config_parameter_map
        self._experiment_run_parameter_map = experiment_run_parameter_map

    def run(self, experiment_parameter_map):
        if not os.path.exists(self._output_path):
            os.makedirs(self._output_path)
        elif not os.path.isdir(self._output_path):
            raise NotADirectoryError(self._output_path)

        utils.print_pretty_header(self._model.name)

        print("Setting up model...")
        self._model.maybe_run_setup()

        my_run_map = experiment_parameter_map.clone()
        if self._experiment_run_parameter_map:
            my_run_map.update(self._experiment_run_parameter_map)

        print("Running model...")
        self._model.run_batch(self._input_path, self._output_path,
                              self._config_parameter_map, my_run_map)

        print("Done with {}!".format(self._model.name))
