import copy


class ParameterMap(object):
    def __init__(self):
        self._parameters = {}

    def set_from_dict(self, parameter_dict):
        for name, properties in parameter_dict.items():
            if not isinstance(properties, dict):
                raise ValueError(
                    "Key '{}' has value '{}', expected dict.".format(
                        name, properties))
            self.set(
                name,
                properties['default'],
                description=properties.get('description'),
                valid_values=properties.get('valid_values'))

    def set(self, name, value, description=None, valid_values=None):
        if name in self._parameters:
            self._parameters[name].update(
                value, description=description, valid_values=valid_values)
        else:
            self._parameters[name] = Parameter(
                name,
                value,
                description=description,
                valid_values=valid_values)

    def update(self, other_parameter_map):
        for name, parameter in other_parameter_map._parameters.items():
            self.set(name, parameter.value, parameter.description,
                     parameter.valid_values)

    def get_val(self, name):
        return self._parameters[name].value

    def get_pair_dict(self):
        pair_dict = {}

        for name, parameter in self._parameters.items():
            pair_dict[name] = parameter.value

        return pair_dict

    def get_parameters(self):
        return self._parameters.values()

    def get_matlab_struct(self, matlab_engine):
        """
        https://www.mathworks.com/help/matlab/matlab_external/handling-data-returned-from-python.html
        """
        struct = self.get_pair_dict()
        for key in struct:
            if isinstance(struct[key], int):
                struct[key] *= 1.0
            if isinstance(struct[key], list):
                if struct[key] and isinstance(struct[key][0], int):
                    struct[key] = matlab_engine.double(
                        matlab_engine.cell2mat(struct[key]))
                elif len(struct[key]) == 0:
                    struct[key] = matlab_engine.double(
                        matlab_engine.cell2mat(struct[key]))
        return struct

    def clone(self):
        return copy.deepcopy(self)


class Parameter(object):
    def __init__(self, name, value, description=None, valid_values=None):
        self.name = name
        self.value = value
        self.description = description
        self.valid_values = valid_values

    def update(self, value, description=None, valid_values=None):
        if description is not None:
            self.description = description
        if valid_values is not None:
            self.valid_values = valid_values

        self.value = value
