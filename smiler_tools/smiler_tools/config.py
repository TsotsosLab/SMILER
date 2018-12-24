import json

from smiler_tools.parameters import ParameterMap


class SmilerConfig(object):
    def __init__(self, config_path):
        with open(config_path, 'rb') as fp:
            self._config = json.load(fp)

        self.parameter_map = ParameterMap()
        self.parameter_map.set_from_dict(self._config['parameters'])
